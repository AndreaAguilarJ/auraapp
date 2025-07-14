import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/shared_space/domain/models/mood_compass_data.dart';
import '../../features/shared_space/domain/models/mood_coordinates.dart';
import '../../features/shared_space/domain/models/user_status.dart';
import '../../features/shared_space/domain/models/thought_pulse.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/constants/app_constants.dart'; // Importar constantes
import 'package:appwrite/appwrite.dart'; // Para ID y otras utilidades
import 'auth_provider.dart'; // Para obtener info del usuario

/// Provider que gestiona el estado del Widget Aura y la brújula emocional
class MoodCompassProvider extends ChangeNotifier {
  // Estado de carga y errores
  bool _isLoading = false;
  String? _errorMessage;

  // Estado actual del usuario
  UserStatus _selectedStatus = UserStatus.available;
  MoodCoordinates _selectedMood = const MoodCoordinates(energy: 0.0, positivity: 0.0);
  MoodCompassData? _currentData;
  MoodCompassData? _partnerData;

  // Estado de la conexión
  bool _isConnected = false;
  DateTime? _lastConnection;

  // Sistema de pulsos de pensamiento
  List<ThoughtPulse> _recentPulses = [];
  DateTime? _lastThoughtPulse;
  bool _canSendPulse = true;
  int _dailyPulseCount = 0;
  
  // Configuración de cooldown
  static const Duration _pulseCooldown = Duration(minutes: 5);
  static const int _maxDailyPulses = 10;

  // Servicios
  final AppwriteService _appwriteService = AppwriteService.instance;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserStatus get selectedStatus => _selectedStatus;
  MoodCoordinates get selectedMood => _selectedMood;
  MoodCompassData? get currentData => _currentData;
  MoodCompassData? get partnerData => _partnerData;
  bool get isConnected => _isConnected;
  DateTime? get lastConnection => _lastConnection;
  List<ThoughtPulse> get recentPulses => List.unmodifiable(_recentPulses);
  DateTime? get lastThoughtPulse => _lastThoughtPulse;
  bool get canSendPulse => _canSendPulse && _dailyPulseCount < _maxDailyPulses;

  /// Tiempo restante para el cooldown del pulso actual
  Duration? get cooldownRemaining {
    if (_lastThoughtPulse == null) return null;
    final elapsed = DateTime.now().difference(_lastThoughtPulse!);
    final remaining = _pulseCooldown - elapsed;
    return remaining > Duration.zero ? remaining : null;
  }

  /// Cantidad de pulsos enviados hoy
  int get dailyPulseCount => _dailyPulseCount;

  /// Inicializa el provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Cargar datos existentes del usuario
      await _loadCurrentUserData();

      // Configurar listeners en tiempo real si está conectado
      if (_isConnected) {
        await _setupRealtimeListeners();
      }

    } catch (e) {
      _setError('Error al inicializar: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Establece el estado del usuario
  void setStatus(UserStatus status) {
    _selectedStatus = status;
    notifyListeners();
  }

  /// Establece el ánimo del usuario
  void setMood(MoodCoordinates mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  /// Actualiza la brújula de estado y ánimo
  Future<void> updateMoodCompass({String? contextNote}) async {
    _setLoading(true);
    _clearError();

    try {
      // Obtener el AuthProvider para acceder al usuario actual
      final AuthProvider? authProvider = _findAuthProvider();
      if (authProvider == null || authProvider.currentUser == null) {
        throw Exception("Usuario no autenticado");
      }

      final currentUser = authProvider.currentUser!;
      final userId = currentUser.id;

      // 1. Crear/actualizar el estado de ánimo en Appwrite
      final newData = MoodCompassData(
        id: ID.unique(), // Appwrite generará el ID
        userId: userId, // ID real del usuario autenticado
        status: _selectedStatus,
        mood: _selectedMood,
        contextNote: contextNote ?? '',
        lastUpdated: DateTime.now(),
        isManualUpdate: true,
        confidenceScore: 1.0,
      );

      // Guardar en Appwrite - colección de estados de ánimo
      await _appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.moodEntriesCollectionId,
        documentId: ID.unique(),
        data: newData.toAppwriteData(),
      );

      // 2. Si hay una nota de contexto, enviarla como mensaje
      if (contextNote != null && contextNote.trim().isNotEmpty) {
        // Verificar si el usuario tiene pareja
        if (currentUser.partnerId != null) {
          // Enviar mensaje a la pareja
          await _sendMessageToPartner(
            senderId: userId,
            receiverId: currentUser.partnerId!,
            content: contextNote,
          );
        }
      }

      _currentData = newData;
      notifyListeners();

    } catch (e) {
      _setError('Error al actualizar: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Envía un mensaje a la pareja
  Future<void> _sendMessageToPartner({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      // Crear documento en la colección de mensajes
      await _appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.messagesCollectionId, // Usar la colección messages que creaste
        documentId: ID.unique(),
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'type': 'text', // Tipo de mensaje: texto
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false, // No leído inicialmente
        },
      );

      print('✅ Mensaje enviado exitosamente a la pareja');
    } catch (e) {
      print('❌ Error enviando mensaje: $e');
      rethrow;
    }
  }

  /// Envía un pulso de pensamiento a la pareja
  Future<void> sendThoughtPulse({required ThoughtPulseType type, String? message}) async {
    _setLoading(true);
    _clearError();

    try {
      // Verificar si se puede enviar un pulso
      if (!canSendPulse) {
        throw Exception("No puedes enviar un pulso en este momento. Espera el cooldown.");
      }

      // Obtener el AuthProvider para acceder al usuario actual
      final AuthProvider? authProvider = _findAuthProvider();
      if (authProvider == null || authProvider.currentUser == null) {
        throw Exception("Usuario no autenticado");
      }

      final currentUser = authProvider.currentUser!;
      final userId = currentUser.id;

      // Verificar si el usuario tiene pareja
      if (currentUser.partnerId == null) {
        throw Exception("No tienes una pareja conectada");
      }

      // Generar un ID de relación combinando los IDs de ambos usuarios
      final List<String> userIds = [userId, currentUser.partnerId!];
      userIds.sort(); // Ordenar para consistencia
      final String relationshipId = userIds.join('-');

      // Crear un nuevo pulso de pensamiento
      final now = DateTime.now();
      final thoughtPulse = ThoughtPulse(
        id: ID.unique(),
        fromUserId: userId,
        toUserId: currentUser.partnerId!,
        relationshipId: relationshipId,
        type: type,
        message: message,
        timestamp: now,
        isRead: false,
        isReceived: false,
      );

      // Guardar en Appwrite - colección de pulsos
      await _appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.thoughtPulsesCollectionId,
        documentId: ID.unique(),
        data: thoughtPulse.toAppwriteData(),
      );

      // Actualizar estado local
      _lastThoughtPulse = now;
      _dailyPulseCount++;
      _recentPulses.insert(0, thoughtPulse);

      // Si hay más de 20 pulsos, eliminar los más antiguos
      if (_recentPulses.length > 20) {
        _recentPulses = _recentPulses.take(20).toList();
      }

      // Actualizar también el último momento de conexión
      _lastConnection = now;

      notifyListeners();

    } catch (e) {
      _setError('Error al enviar pulso: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Encuentra el AuthProvider en el árbol de contexto
  AuthProvider? _findAuthProvider() {
    try {
      // Intentar obtener la instancia global del AuthProvider
      final authService = AuthProvider.instance;
      if (authService != null) {
        return authService;
      }

      // Método alternativo: intentar obtener desde el contexto
      BuildContext? context = WidgetsBinding.instance.rootElement;
      if (context != null) {
        return Provider.of<AuthProvider>(context, listen: false);
      }

      print('No se pudo encontrar el AuthProvider');
      return null;
    } catch (e) {
      print('Error accediendo al AuthProvider: $e');
      return null;
    }
  }

  /// Carga los datos actuales del usuario
  Future<void> _loadCurrentUserData() async {
    try {
      // Simular carga de datos - se implementaría con Appwrite
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Implementar carga real desde Appwrite
      _currentData = null; // Se cargará desde la base de datos
      _isConnected = false; // Se determinará basado en si tiene pareja

    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }

  /// Configura listeners en tiempo real para cambios de la pareja
  Future<void> _setupRealtimeListeners() async {
    try {
      // TODO: Implementar listeners de Appwrite Realtime
      // _appwriteService.realtime.subscribe(['documents'])

    } catch (e) {
      print('Error configurando listeners: $e');
    }
  }

  /// Establece el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establece un error
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpia el error actual
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears the current error
  void clearError() => _clearError();

  /// Loads relationship configuration (stub)
  Future<void> loadRelationshipConfig() async {
    await _loadCurrentUserData();
  }

  /// Loads partner data (stub)
  Future<void> loadPartnerData() async {
    // TODO: implement actual partner data loading
    _partnerData = _currentData;
    notifyListeners();
  }

  /// Loads recent thought pulses (stub)
  Future<void> loadRecentThoughtPulses() async {
    // TODO: implement actual loading
  }

  /// Current mood snapshot
  MoodCompassData? get currentMoodSnapshot => _currentData;

  /// Partner mood snapshot
  MoodCompassData? get partnerMoodSnapshot => _partnerData;

  @override
  void dispose() {
    // Limpiar listeners y recursos
    super.dispose();
  }
}