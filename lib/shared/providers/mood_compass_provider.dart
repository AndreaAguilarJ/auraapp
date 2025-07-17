import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../features/shared_space/domain/models/mood_compass_data.dart';
import '../../features/shared_space/domain/models/mood_coordinates.dart';
import '../../features/shared_space/domain/models/user_status.dart';
import '../../features/shared_space/domain/models/thought_pulse.dart';
import '../../core/services/appwrite_service.dart';
import '../../core/services/realtime_sync_service.dart';
import '../../core/constants/app_constants.dart';
import 'package:appwrite/appwrite.dart';
import 'auth_provider.dart';
import 'activity_provider.dart';

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

  // Suscripción a tiempo real
  StreamSubscription<RealtimeMessage>? _realtimeSubscription;

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

  // Mapeo de estados de ánimo a coordenadas
  static final Map<String, MoodCoordinates> moodMap = {
    'Feliz': const MoodCoordinates(positivity: 0.8, energy: 0.5),
    'Enérgico': const MoodCoordinates(positivity: 0.5, energy: 0.9),
    'Tranquilo': const MoodCoordinates(positivity: 0.6, energy: -0.3),
    'Cansado': const MoodCoordinates(positivity: -0.2, energy: -0.7),
    'Estresado': const MoodCoordinates(positivity: -0.5, energy: 0.5),
    'Triste': const MoodCoordinates(positivity: -0.8, energy: -0.5),
    'Enfadado': const MoodCoordinates(positivity: -0.7, energy: 0.7),
  };

  /// Inicializa el provider con sincronización mejorada
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Inicializar el servicio de sincronización en tiempo real
      await RealtimeSyncService.instance.initialize();

      // Cargar datos existentes del usuario
      await _loadCurrentUserData();

      // Configurar listeners mejorados en tiempo real
      await _setupImprovedRealtimeListeners();

      // Inicializar el ActivityProvider si está disponible
      await _initializeActivityProvider();

      print('✅ MoodCompassProvider inicializado con sincronización mejorada');

    } catch (e) {
      _setError('Error al inicializar: $e');
      print('❌ Error inicializando MoodCompassProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Configura listeners mejorados en tiempo real
  Future<void> _setupImprovedRealtimeListeners() async {
    try {
      final AuthProvider? authProvider = _findAuthProvider();
      if (authProvider == null || authProvider.currentUser == null) {
        return;
      }

      final currentUser = authProvider.currentUser!;
      final userId = currentUser.id;
      final partnerId = currentUser.partnerId;

      // Configurar las suscripciones usando el servicio mejorado
      await RealtimeSyncService.instance.setupUserSubscriptions(userId, partnerId);

      // Suscribirse a actualizaciones de mood
      RealtimeSyncService.instance.moodUpdates.listen((data) {
        _handleRealtimeMoodUpdate(data, userId, partnerId);
      });

      // Suscribirse a pulsos de pensamiento
      RealtimeSyncService.instance.thoughtPulses.listen((data) {
        _handleRealtimeThoughtPulse(data, userId, partnerId);
      });

      // Actualizar estado de conexión
      _isConnected = partnerId != null;
      _lastConnection = DateTime.now();

      print('✅ Listeners mejorados configurados');
    } catch (e) {
      print('❌ Error configurando listeners mejorados: $e');
    }
  }

  /// Maneja actualizaciones de mood en tiempo real
  void _handleRealtimeMoodUpdate(Map<String, dynamic> data, String userId, String? partnerId) {
    try {
      final documentUserId = data['userId'] as String?;

      if (documentUserId == userId) {
        // Actualización del usuario actual
        _currentData = MoodCompassData.fromAppwriteData(data);
        _lastConnection = DateTime.now();
        notifyListeners();
        print('🎭 Estado propio actualizado en tiempo real');
      } else if (partnerId != null && documentUserId == partnerId) {
        // Actualización de la pareja
        _partnerData = MoodCompassData.fromAppwriteData(data);
        _lastConnection = DateTime.now();
        notifyListeners();
        print('💕 Estado de pareja actualizado en tiempo real');
      }
    } catch (e) {
      print('❌ Error procesando actualización de mood: $e');
    }
  }

  /// Maneja pulsos de pensamiento en tiempo real
  void _handleRealtimeThoughtPulse(Map<String, dynamic> data, String userId, String? partnerId) {
    try {
      final fromUserId = data['fromUserId'] as String?;
      final toUserId = data['toUserId'] as String?;

      // Solo procesar si está dirigido al usuario actual
      if (toUserId == userId && fromUserId == partnerId) {
        final pulse = ThoughtPulse.fromAppwriteData(data);
        _recentPulses.insert(0, pulse);

        // Mantener solo los últimos 20 pulsos
        if (_recentPulses.length > 20) {
          _recentPulses = _recentPulses.take(20).toList();
        }

        _lastConnection = DateTime.now();
        notifyListeners();
        print('💭 Pulso de pensamiento recibido en tiempo real');
      }
    } catch (e) {
      print('❌ Error procesando pulso de pensamiento: $e');
    }
  }

  /// Inicializa el ActivityProvider si está disponible
  Future<void> _initializeActivityProvider() async {
    try {
      final AuthProvider? authProvider = _findAuthProvider();
      if (authProvider?.currentUser != null) {
        final activityProvider = ActivityProvider.instance;
        if (activityProvider != null) {
          await activityProvider.initialize(
            authProvider!.currentUser!.id,
            authProvider.currentUser!.partnerId,
          );
          print('✅ ActivityProvider inicializado');
        }
      }
    } catch (e) {
      print('ℹ️ ActivityProvider no disponible o error: $e');
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

  /// Actualiza la brújula de estado y ánimo con mejor sincronización
  Future<void> updateMoodCompass({String? contextNote}) async {
    _setLoading(true);
    _clearError();

    try {
      final AuthProvider? authProvider = _findAuthProvider();
      if (authProvider == null || authProvider.currentUser == null) {
        throw Exception("Usuario no autenticado");
      }

      final currentUser = authProvider.currentUser!;
      final userId = currentUser.id;

      // Crear los datos de mood con la estructura exacta de la colección Mood_Snapshots
      final userData = {
        'userId': userId,
        'status': _selectedStatus.toString().split('.').last,
        'mood': "${_selectedMood.positivity.toStringAsFixed(0)},${_selectedMood.energy.toStringAsFixed(0)}",
        'contextNote': contextNote ?? '',
        'privacyLevel': 'shared', // Valor por defecto
        'timestamp': DateTime.now().toIso8601String(),
        'isManualUpdate': true,
        'confidenceScore': 1.0,
      };

      // Guardar en Appwrite
      await _appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.moodCollectionId,
        documentId: ID.unique(),
        data: userData,
      );

      // Actualizar estado local inmediatamente
      _currentData = MoodCompassData.fromAppwriteData({
        '\$id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
        ...userData,
      });
      _lastConnection = DateTime.now();

      // Si hay contexto, enviar como mensaje
      if (contextNote != null && contextNote.trim().isNotEmpty && currentUser.partnerId != null) {
        await _sendMessageToPartner(
          senderId: userId,
          receiverId: currentUser.partnerId!,
          content: contextNote,
        );
      }

      // Notificar al ActivityProvider sobre la actualización
      final activityProvider = ActivityProvider.instance;
      activityProvider?.addConnectionActivity('Estado de ánimo actualizado');

      notifyListeners();
      print('✅ Estado de ánimo actualizado con sincronización mejorada');

    } catch (e) {
      _setError('Error al actualizar: $e');
      print('❌ Error actualizando mood compass: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza la brújula de estado y ánimo a partir de un nombre de estado de ánimo
  Future<void> updateMoodCompassByName({required String moodName, String? contextNote}) async {
    // Convertir el nombre del estado de ánimo a coordenadas usando el mapa
    final coordinates = moodMap[moodName];
    if (coordinates == null) {
      print('❌ Nombre de estado de ánimo no válido: $moodName');
      _setError('Estado de ánimo no reconocido');
      return;
    }

    // Establecer el mood usando las coordenadas del mapa
    setMood(coordinates);

    // Llamar al método existente para actualizar
    await updateMoodCompass(contextNote: contextNote);

    // Registrar el ID del documento creado para confirmar que la operación fue exitosa
    print('✅ Estado de ánimo "$moodName" enviado exitosamente (${coordinates.positivity}, ${coordinates.energy})');
  }

  /// Envía un pulso de pensamiento con mejor sincronización
  Future<void> sendThoughtPulse({required ThoughtPulseType type, String? message}) async {
    _setLoading(true);
    _clearError();

    try {
      if (!canSendPulse) {
        throw Exception("No puedes enviar un pulso en este momento. Espera el cooldown.");
      }

      final AuthProvider? authProvider = _findAuthProvider();
      if (authProvider == null || authProvider.currentUser == null) {
        throw Exception("Usuario no autenticado");
      }

      final currentUser = authProvider.currentUser!;
      final userId = currentUser.id;

      if (currentUser.partnerId == null) {
        throw Exception("No tienes una pareja conectada");
      }

      final now = DateTime.now();
      final relationshipId = [userId, currentUser.partnerId!]..sort();
      final pulseData = {
        'fromUserId': userId,
        'fromUserName': currentUser.name,
        'toUserId': currentUser.partnerId!,
        'relationshipId': relationshipId.join('-'),
        'type': type.toString().split('.').last,
        'message': message ?? '',
        'timestamp': now.toIso8601String(),
        'isRead': false,
        'isReceived': false,
      };

      // Guardar en Appwrite
      await _appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.thoughtPulsesCollectionId,
        documentId: ID.unique(),
        data: pulseData,
      );

      // Actualizar estado local
      final thoughtPulse = ThoughtPulse.fromAppwriteData(pulseData);
      _lastThoughtPulse = now;
      _dailyPulseCount++;
      _recentPulses.insert(0, thoughtPulse);
      _lastConnection = now;

      // Configurar cooldown
      _canSendPulse = false;
      Timer(_pulseCooldown, () {
        _canSendPulse = true;
        notifyListeners();
      });

      // Notificar al ActivityProvider
      final activityProvider = ActivityProvider.instance;
      activityProvider?.addConnectionActivity('Pulso de pensamiento enviado');

      notifyListeners();
      print('💝 Pulso de pensamiento enviado');

    } catch (e) {
      _setError('Error al enviar pulso: $e');
      print('❌ Error enviando pulso: $e');
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
        collectionId: AppwriteConstants.messagesCollectionId,
        documentId: ID.unique(),
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'type': 'text',
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
        },
      );

      print('✅ Mensaje enviado exitosamente a la pareja');
    } catch (e) {
      print('❌ Error enviando mensaje: $e');
      rethrow;
    }
  }

  /// Obtiene un stream de actualizaciones de estado de ánimo en tiempo real
  Stream<RealtimeMessage> getMoodUpdates() {
    // La cadena de suscripción debe ser: 'databases.[DATABASE_ID].collections.[COLLECTION_ID].documents'
    final subscriptionPath = 'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.moodCollectionId}.documents';
    // Convertir RealtimeSubscription a Stream<RealtimeMessage>
    return _appwriteService.realtime.subscribe([subscriptionPath]).stream;
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
      // Obtener el AuthProvider para acceder al usuario actual
      final AuthProvider? authProvider = _findAuthProvider();
      if (authProvider == null || authProvider.currentUser == null) {
        throw Exception("Usuario no autenticado");
      }

      final currentUser = authProvider.currentUser!;
      final userId = currentUser.id;

      // Cargar el estado de ánimo más reciente del usuario desde la colección Mood_Snapshots
      try {
        // Consultar documentos ordenados por timestamp (más reciente primero)
        final response = await _appwriteService.databases.listDocuments(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.moodCollectionId,
          queries: [
            Query.equal('userId', userId),
            Query.orderDesc('timestamp'),
            Query.limit(1),
          ],
        );

        // Si hay resultados, actualizar el estado local usando fromAppwriteData
        if (response.documents.isNotEmpty) {
          final document = response.documents.first;
          _currentData = MoodCompassData.fromAppwriteData(document.data);
          print('✅ Estado de ánimo cargado: ${_currentData?.statusDescription}');
        }

        // Determinar si el usuario está conectado (tiene pareja)
        _isConnected = currentUser.partnerId != null;

        // Si tiene pareja, intentar cargar su estado también
        if (_isConnected) {
          await _loadPartnerData(currentUser.partnerId!);
        }

      } catch (e) {
        print('❌ Error cargando estado de ánimo: $e');
      }
    } catch (e) {
      print('❌ Error cargando datos del usuario: $e');
    }
  }

  /// Carga los datos de la pareja
  Future<void> _loadPartnerData(String partnerId) async {
    try {
      // Consultar documentos de la pareja ordenados por timestamp (más reciente primero)
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.moodCollectionId,
        queries: [
          Query.equal('userId', partnerId),
          Query.orderDesc('timestamp'),
          Query.limit(1),
        ],
      );

      // Si hay resultados, actualizar el estado de la pareja usando fromAppwriteData
      if (response.documents.isNotEmpty) {
        final document = response.documents.first;
        _partnerData = MoodCompassData.fromAppwriteData(document.data);
        print('✅ Estado de ánimo de pareja cargado: ${_partnerData?.statusDescription}');
      }
    } catch (e) {
      print('❌ Error cargando estado de ánimo de la pareja: $e');
    }
  }

  /// Configura listeners en tiempo real para cambios de la pareja
  Future<void> _setupRealtimeListeners() async {
    try {
      // Obtener el AuthProvider para acceder al usuario actual
      final AuthProvider? authProvider = _findAuthProvider();
      if (authProvider == null || authProvider.currentUser == null) {
        throw Exception("Usuario no autenticado");
      }

      final currentUser = authProvider.currentUser!;
      final userId = currentUser.id;

      // Si no hay pareja conectada, no es necesario configurar listeners
      if (currentUser.partnerId == null) {
        _isConnected = false;
        return;
      }

      _isConnected = true;
      final partnerId = currentUser.partnerId!;

      // Suscribirse a los cambios en la colección Mood_Snapshots
      final subscription = getMoodUpdates().listen((RealtimeMessage message) {
        // Procesar solo eventos de creación o actualización
        if (message.events.contains('databases.*.collections.*.documents.*.create') ||
            message.events.contains('databases.*.collections.*.documents.*.update')) {

          // Extraer los datos del payload
          final Map<String, dynamic>? payload = message.payload;

          if (payload != null && payload['userId'] != null) {
            final String documentUserId = payload['userId'];

            // Si el evento es del usuario actual, actualizar datos locales
            if (documentUserId == userId) {
              // Convertir los datos del payload a un objeto MoodCompassData
              _currentData = MoodCompassData.fromAppwriteData(payload);
              notifyListeners();
            }
            // Si el evento es de la pareja, actualizar datos de la pareja
            else if (documentUserId == partnerId) {
              // Convertir los datos del payload a un objeto MoodCompassData
              _partnerData = MoodCompassData.fromAppwriteData(payload);
              notifyListeners();
            }
          }
        }
      });

      // Almacenar la suscripción para cancelarla cuando sea necesario
      _realtimeSubscription = subscription;

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
    _realtimeSubscription?.cancel(); // Cancelar suscripción en tiempo real
    super.dispose();
  }
}
