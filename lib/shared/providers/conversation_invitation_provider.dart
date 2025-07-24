import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'auth_provider.dart';
import '../../features/guided_conversation/data/repositories/conversation_invitation_repository.dart';
import '../../features/guided_conversation/domain/models/conversation_invitation.dart';
import '../../core/services/notification_service.dart';

class ConversationInvitationProvider extends ChangeNotifier {
  final ConversationInvitationRepository _repository = ConversationInvitationRepository();
  final AuthProvider _authProvider;
  final NotificationService _notificationService = NotificationService();

  List<ConversationInvitation> _pendingInvitations = [];
  List<ConversationInvitation> _sentInvitations = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<RealtimeMessage>? _invitationSubscription;

  ConversationInvitationProvider(this._authProvider) {
    _initialize();
  }

  // Getters
  List<ConversationInvitation> get pendingInvitations => _pendingInvitations;
  List<ConversationInvitation> get sentInvitations => _sentInvitations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingCount => _pendingInvitations.length;
  bool get hasUnreadInvitations => _pendingInvitations.isNotEmpty;

  Future<void> _initialize() async {
    if (_authProvider.currentUser?.id != null) {
      await loadInvitations();
      _subscribeToInvitations();
    }
  }

  /// Enviar una invitación de conversación guiada
  Future<bool> sendInvitation({
    required String toUserId,
    required String toUserName,
    required Map<String, dynamic> topic,
    String? message,
  }) async {
    if (_authProvider.currentUser?.id == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Verificar si ya existe una invitación pendiente
      final existingInvitation = await _repository.getExistingInvitation(
        _authProvider.currentUser!.id!,
        toUserId,
      );

      if (existingInvitation != null) {
        _errorMessage = 'Ya tienes una invitación pendiente con este usuario';
        notifyListeners();
        return false;
      }

      // Crear la invitación
      final invitation = ConversationInvitation(
        fromUserId: _authProvider.currentUser!.id!,
        fromUserName: _authProvider.currentUser!.name,
        toUserId: toUserId,
        toUserName: toUserName,
        topic: topic,
        status: 'pending',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        message: message,
      );

      final createdInvitation = await _repository.createInvitation(invitation);

      // Agregar a la lista de enviadas
      _sentInvitations.insert(0, createdInvitation);

      // Enviar notificación push al destinatario
      await _sendPushNotification(createdInvitation);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al enviar invitación: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Aceptar una invitación
  Future<bool> acceptInvitation(ConversationInvitation invitation) async {
    _setLoading(true);
    _clearError();

    try {
      if (!invitation.canRespond) {
        _errorMessage = 'Esta invitación ya no es válida';
        notifyListeners();
        return false;
      }

      // Actualizar el estado de la invitación
      final updatedInvitation = await _repository.updateInvitationStatus(
        invitation.id!,
        'accepted',
      );

      // Remover de pendientes
      _pendingInvitations.removeWhere((inv) => inv.id == invitation.id);

      // Notificar al remitente que se aceptó
      await _notifyInvitationResponse(updatedInvitation, true);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al aceptar invitación: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Rechazar una invitación
  Future<bool> rejectInvitation(ConversationInvitation invitation, {String? reason}) async {
    _setLoading(true);
    _clearError();

    try {
      if (!invitation.canRespond) {
        _errorMessage = 'Esta invitación ya no es válida';
        notifyListeners();
        return false;
      }

      // Actualizar el estado de la invitación
      final updatedInvitation = await _repository.updateInvitationStatus(
        invitation.id!,
        'rejected',
        responseMessage: reason,
      );

      // Remover de pendientes
      _pendingInvitations.removeWhere((inv) => inv.id == invitation.id);

      // Notificar al remitente que se rechazó
      await _notifyInvitationResponse(updatedInvitation, false);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al rechazar invitación: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar todas las invitaciones
  Future<void> loadInvitations() async {
    if (_authProvider.currentUser?.id == null) return;

    _setLoading(true);

    try {
      // Marcar invitaciones expiradas primero
      await _repository.markExpiredInvitations();

      // Cargar invitaciones pendientes
      _pendingInvitations = await _repository.getPendingInvitations(
        _authProvider.currentUser!.id!,
      );

      // Cargar invitaciones enviadas
      _sentInvitations = await _repository.getSentInvitations(
        _authProvider.currentUser!.id!,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar invitaciones: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Generar link de invitación compartible
  String generateInvitationLink(ConversationInvitation invitation) {
    // Este link podría abrir la app o una página web que maneje la invitación
    return 'https://aura-app.com/invitation/${invitation.id}';
  }

  /// Procesar link de invitación
  Future<ConversationInvitation?> processInvitationLink(String invitationId) async {
    try {
      // Aquí deberías implementar la lógica para obtener la invitación por ID
      // y verificar si el usuario actual puede responderla
      return null; // Implementar según necesidades
    } catch (e) {
      _errorMessage = 'Error al procesar link de invitación: $e';
      notifyListeners();
      return null;
    }
  }

  /// Enviar notificación push al destinatario
  Future<void> _sendPushNotification(ConversationInvitation invitation) async {
    try {
      await _notificationService.sendConversationInvitationNotification(
        toUserId: invitation.toUserId,
        fromUserName: invitation.fromUserName,
        topicTitle: invitation.topicTitle,
        invitationId: invitation.id!,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error enviando notificación push: $e');
      }
    }
  }

  /// Notificar respuesta a invitación
  Future<void> _notifyInvitationResponse(ConversationInvitation invitation, bool accepted) async {
    try {
      await _notificationService.sendInvitationResponseNotification(
        toUserId: invitation.fromUserId,
        responderName: invitation.toUserName,
        topicTitle: invitation.topicTitle,
        accepted: accepted,
        invitationId: invitation.id!,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error enviando notificación de respuesta: $e');
      }
    }
  }

  /// Suscribirse a cambios en tiempo real
  void _subscribeToInvitations() {
    if (_authProvider.currentUser?.id == null) return;

    _invitationSubscription?.cancel();
    _invitationSubscription = _repository
        .subscribeToInvitations(_authProvider.currentUser!.id!)
        .listen((message) {
      _handleRealtimeUpdate(message);
    });
  }

  /// Manejar actualizaciones en tiempo real
  void _handleRealtimeUpdate(RealtimeMessage message) {
    try {
      final invitation = ConversationInvitation.fromMap(message.payload);
      final currentUserId = _authProvider.currentUser?.id;

      if (currentUserId == null) return;

      switch (message.events.first) {
        case 'databases.*.collections.*.documents.*.create':
          // Nueva invitación recibida
          if (invitation.toUserId == currentUserId && invitation.isPending) {
            _pendingInvitations.insert(0, invitation);
            _showInAppNotification(invitation);
          }
          // Nueva invitación enviada
          else if (invitation.fromUserId == currentUserId) {
            _sentInvitations.insert(0, invitation);
          }
          break;

        case 'databases.*.collections.*.documents.*.update':
          // Actualización de invitación
          _updateInvitationInLists(invitation);
          break;

        case 'databases.*.collections.*.documents.*.delete':
          // Invitación eliminada
          _removeInvitationFromLists(invitation.id!);
          break;
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error procesando actualización en tiempo real: $e');
      }
    }
  }

  /// Actualizar invitación en las listas
  void _updateInvitationInLists(ConversationInvitation invitation) {
    final currentUserId = _authProvider.currentUser?.id;
    if (currentUserId == null) return;

    // Actualizar en pendientes
    if (invitation.toUserId == currentUserId) {
      final index = _pendingInvitations.indexWhere((inv) => inv.id == invitation.id);
      if (index != -1) {
        if (invitation.isPending) {
          _pendingInvitations[index] = invitation;
        } else {
          _pendingInvitations.removeAt(index);
        }
      }
    }

    // Actualizar en enviadas
    if (invitation.fromUserId == currentUserId) {
      final index = _sentInvitations.indexWhere((inv) => inv.id == invitation.id);
      if (index != -1) {
        _sentInvitations[index] = invitation;
      }
    }
  }

  /// Remover invitación de las listas
  void _removeInvitationFromLists(String invitationId) {
    _pendingInvitations.removeWhere((inv) => inv.id == invitationId);
    _sentInvitations.removeWhere((inv) => inv.id == invitationId);
  }

  /// Mostrar notificación in-app
  void _showInAppNotification(ConversationInvitation invitation) {
    // Aquí puedes mostrar una notificación dentro de la app
    // Por ejemplo, usando un SnackBar o un overlay
    if (kDebugMode) {
      print('📩 Nueva invitación de ${invitation.fromUserName}: ${invitation.topicTitle}');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _invitationSubscription?.cancel();
    super.dispose();
  }
}
