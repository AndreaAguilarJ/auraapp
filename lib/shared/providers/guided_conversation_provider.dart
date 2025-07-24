import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Agregar para SocketException
import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import '../../features/guided_conversation/domain/models/guided_conversation.dart';
import '../../features/guided_conversation/domain/models/conversation_turn.dart';
import '../../features/guided_conversation/domain/services/accusation_detector.dart';
import '../../features/guided_conversation/data/repositories/guided_conversation_repository.dart';
import 'auth_provider.dart';

/// Provider para gestionar conversaciones guiadas entre parejas
class GuidedConversationProvider extends ChangeNotifier {
  final GuidedConversationRepository _repository = GuidedConversationRepository();
  final AuthProvider _authProvider;

  GuidedConversation? _currentConversation;
  bool _isLoading = false;
  String? _errorMessage;
  List<GuidedConversation> _conversationHistory = [];
  StreamSubscription<RealtimeMessage>? _conversationSubscription;

  GuidedConversationProvider(this._authProvider);

  // Getters
  GuidedConversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<GuidedConversation> get conversationHistory => _conversationHistory;

  bool get isMyTurn => _currentConversation?.currentTurn == _authProvider.currentUser?.id;

  /// Verifica si un mensaje pertenece al usuario actual
  bool isMyMessage(String speakerId) {
    return speakerId == _authProvider.currentUser?.id;
  }

  /// Inicia una nueva conversación guiada
  Future<void> startConversation({
    required String partnerUserId,
    required Map<String, dynamic> topic,
  }) async {
    _setLoading(true);

    try {
      final conversation = GuidedConversation(
        relationshipId: '${_authProvider.currentUser?.id}_$partnerUserId',
        initiatorUserId: _authProvider.currentUser?.id ?? '',
        partnerUserId: partnerUserId,
        topic: topic,
        status: 'active',
        currentTurn: _authProvider.currentUser?.id ?? '',
        totalTurns: 0,
        turns: [],
      );

      _currentConversation = await _repository.createConversation(conversation);

      // Suscribirse a cambios en tiempo real
      _subscribeToCurrentConversation();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al iniciar conversación: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Envía un mensaje en el turno actual
  Future<bool> sendMessage(String message) async {
    if (_currentConversation == null || !isMyTurn) return false;

    // Detectar acusaciones antes de enviar
    final accusation = AccusationDetector.detectAccusation(message);
    if (accusation != null) {
      _errorMessage = accusation;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    clearError(); // Limpiar errores previos

    try {
      final newTurn = ConversationTurn(
        turnNumber: _currentConversation!.totalTurns + 1,
        speakerId: _authProvider.currentUser?.id ?? '',
        speakerMessage: message,
        listenerUserId: _getPartnerUserId(),
        timestamp: DateTime.now(),
        isValidated: false,
      );

      final updatedTurns = [..._currentConversation!.turns, newTurn];

      _currentConversation = await _repository.updateConversation(
        _currentConversation!.id!,
        {
          'turns': jsonEncode(updatedTurns.map((t) => t.toMap()).toList()),
          'totalTurns': updatedTurns.length,
          'currentTurn': _getPartnerUserId(),
        },
      );

      notifyListeners();
      return true;
    } on SocketException {
      _errorMessage = 'Sin conexión a internet. Verifica tu conectividad y reintenta.';
      notifyListeners();
      return false;
    } on AppwriteException catch (e) {
      // Mejor manejo de errores específicos de Appwrite
      if (kDebugMode) {
        print('AppwriteException details: ${e.message}, Code: ${e.code}, Type: ${e.type}');
      }

      switch (e.code) {
        case 401:
          _errorMessage = 'Error de autenticación. Por favor, inicia sesión nuevamente.';
          break;
        case 403:
          _errorMessage = 'No tienes permisos para realizar esta acción.';
          break;
        case 404:
          _errorMessage = 'La conversación no fue encontrada. Puede haber sido eliminada.';
          break;
        case 500:
          _errorMessage = 'Error interno del servidor. Reintenta en unos momentos.';
          break;
        case 503:
          _errorMessage = 'Servicio temporalmente no disponible. Reintenta más tarde.';
          break;
        default:
          _errorMessage = 'Error del servidor (${e.code}): ${e.message}. Reintenta en unos momentos.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in sendMessage: $e');
      }

      String errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') || errorMsg.contains('SocketException')) {
        _errorMessage = 'Problema de conectividad. Verifica tu conexión a internet.';
      } else if (errorMsg.contains('TimeoutException')) {
        _errorMessage = 'La solicitud ha tardado demasiado. Verifica tu conexión.';
      } else {
        _errorMessage = 'Error inesperado al enviar mensaje. Reintenta por favor.';
      }
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Valida el resumen del oyente
  Future<bool> submitListenerSummary(String summary) async {
    if (_currentConversation == null || isMyTurn) return false;

    final lastTurn = _currentConversation!.turns.last;
    if (lastTurn.listenerUserId != (_authProvider.currentUser?.id ?? '')) return false;

    _setLoading(true);

    try {
      final updatedTurn = lastTurn.copyWith(
        listenerSummary: summary,
        isValidated: true,
      );

      final updatedTurns = [..._currentConversation!.turns];
      updatedTurns[updatedTurns.length - 1] = updatedTurn;

      _currentConversation = await _repository.updateConversation(
        _currentConversation!.id!,
        {
          'turns': jsonEncode(updatedTurns.map((t) => t.toMap()).toList()),
          'currentTurn': _authProvider.currentUser?.id ?? '', // Ahora puede responder
        },
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al validar resumen: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Finaliza la conversación actual
  Future<void> endConversation({
    List<String>? keyPoints,
    List<String>? commitments,
    String? nextSteps,
  }) async {
    if (_currentConversation == null) return;

    _setLoading(true);

    try {
      _currentConversation = await _repository.updateConversation(
        _currentConversation!.id!,
        {
          'status': 'completed',
          'finalSummary': {
            'keyPoints': keyPoints ?? [],
            'commitments': commitments ?? [],
            'nextSteps': nextSteps ?? '',
          },
        },
      );

      _conversationHistory.insert(0, _currentConversation!);
      _conversationSubscription?.cancel();
      _currentConversation = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al finalizar conversación: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Carga las conversaciones activas del usuario
  Future<void> loadActiveConversations() async {
    if (_authProvider.currentUser?.id == null) return;

    _setLoading(true);

    try {
      final activeConversations = await _repository.getActiveConversations(
        _authProvider.currentUser!.id!,
      );

      if (activeConversations.isNotEmpty) {
        _currentConversation = activeConversations.first;
        _subscribeToCurrentConversation();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar conversaciones: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Carga el historial de conversaciones
  Future<void> loadConversationHistory() async {
    if (_authProvider.currentUser?.id == null) return;

    try {
      _conversationHistory = await _repository.getConversationHistory(
        _authProvider.currentUser!.id!,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar historial: $e';
    }
  }

  /// Se suscribe a los cambios en tiempo real de la conversación actual
  void _subscribeToCurrentConversation() {
    if (_currentConversation?.id == null) return;

    _conversationSubscription?.cancel();
    _conversationSubscription = _repository.subscribeToConversation(
      _currentConversation!.id!,
      (updatedConversation) {
        _currentConversation = updatedConversation as GuidedConversation?;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _conversationSubscription?.cancel();
    super.dispose();
  }

  String _getPartnerUserId() {
    final currentUserId = _authProvider.currentUser!.id!;
    return _currentConversation!.initiatorUserId == currentUserId
        ? _currentConversation!.partnerUserId
        : _currentConversation!.initiatorUserId;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
