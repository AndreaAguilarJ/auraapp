import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:async';

import '../constants/app_constants.dart';
import 'appwrite_service.dart';
import '../../features/shared_space/domain/models/activity_item.dart';

/// Servicio mejorado para manejar sincronización en tiempo real y actividades
class RealtimeSyncService {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  static RealtimeSyncService get instance => _instance;
  RealtimeSyncService._internal();

  final AppwriteService _appwriteService = AppwriteService.instance;

  // Suscripciones activas
  final Map<String, StreamSubscription<RealtimeMessage>> _subscriptions = {};

  // Stream controllers para diferentes tipos de eventos
  final StreamController<Map<String, dynamic>> _moodUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<ActivityItem> _activityController =
      StreamController<ActivityItem>.broadcast();
  final StreamController<Map<String, dynamic>> _thoughtPulsesController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messagesController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters para los streams
  Stream<Map<String, dynamic>> get moodUpdates => _moodUpdatesController.stream;
  Stream<ActivityItem> get activityStream => _activityController.stream;
  Stream<Map<String, dynamic>> get thoughtPulses => _thoughtPulsesController.stream;
  Stream<Map<String, dynamic>> get messages => _messagesController.stream;

  // Estado de conexión
  bool _isConnected = false;
  DateTime? _lastHeartbeat;
  Timer? _heartbeatTimer;

  bool get isConnected => _isConnected;
  DateTime? get lastHeartbeat => _lastHeartbeat;

  /// Inicializa el servicio de sincronización
  Future<void> initialize() async {
    try {
      print('🔄 Iniciando servicio de sincronización...');
      await _setupHeartbeat();
      print('✅ Servicio de sincronización inicializado');
    } catch (e) {
      print('❌ Error inicializando servicio de sincronización: $e');
    }
  }

  /// Configura las suscripciones en tiempo real para un usuario específico
  Future<void> setupUserSubscriptions(String userId, String? partnerId) async {
    try {
      // Limpiar suscripciones existentes
      await _clearSubscriptions();

      // Suscribirse a actualizaciones de mood
      await _subscribeMoodUpdates(userId, partnerId);

      // Suscribirse a pulsos de pensamiento
      await _subscribeThoughtPulses(userId, partnerId);

      // Suscribirse a mensajes
      await _subscribeMessages(userId, partnerId);

      // Suscribirse a actividades generales
      await _subscribeActivities(userId, partnerId);

      _isConnected = true;
      print('✅ Suscripciones configuradas para usuario: $userId');

    } catch (e) {
      print('❌ Error configurando suscripciones: $e');
      _isConnected = false;
    }
  }

  /// Suscribirse a actualizaciones de mood
  Future<void> _subscribeMoodUpdates(String userId, String? partnerId) async {
    const channel = 'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.moodCollectionId}.documents';

    try {
      final subscription = _appwriteService.realtime
          .subscribe([channel])
          .stream
          .listen((RealtimeMessage message) {
        _handleMoodUpdate(message, userId, partnerId);
      });

      _subscriptions['mood_updates'] = subscription;
      print('✅ Suscrito a actualizaciones de mood');
    } catch (e) {
      print('❌ Error suscribiéndose a mood updates: $e');
    }
  }

  /// Suscribirse a pulsos de pensamiento
  Future<void> _subscribeThoughtPulses(String userId, String? partnerId) async {
    const channel = 'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.thoughtPulsesCollectionId}.documents';

    try {
      final subscription = _appwriteService.realtime
          .subscribe([channel])
          .stream
          .listen((RealtimeMessage message) {
        _handleThoughtPulseUpdate(message, userId, partnerId);
      });

      _subscriptions['thought_pulses'] = subscription;
      print('✅ Suscrito a pulsos de pensamiento');
    } catch (e) {
      print('❌ Error suscribiéndose a thought pulses: $e');
    }
  }

  /// Suscribirse a mensajes
  Future<void> _subscribeMessages(String userId, String? partnerId) async {
    const channel = 'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.messagesCollectionId}.documents';

    try {
      final subscription = _appwriteService.realtime
          .subscribe([channel])
          .stream
          .listen((RealtimeMessage message) {
        _handleMessageUpdate(message, userId, partnerId);
      });

      _subscriptions['messages'] = subscription;
      print('✅ Suscrito a mensajes');
    } catch (e) {
      print('❌ Error suscribiéndose a mensajes: $e');
    }
  }

  /// Suscribirse a actividades
  Future<void> _subscribeActivities(String userId, String? partnerId) async {
    final channel = 'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.activitiesCollectionId}.documents';

    try {
      print('ℹ️ Suscribiéndose a colección de actividades: ${AppwriteConstants.activitiesCollectionId}');
      final subscription = _appwriteService.realtime
          .subscribe([channel])
          .stream
          .listen((RealtimeMessage message) {
        _handleActivityUpdate(message, userId, partnerId);
      });

      _subscriptions['activities'] = subscription;
      print('✅ Suscrito a actividades');
    } catch (e) {
      print('❌ Error suscribiéndose a actividades: $e');
    }
  }

  /// Maneja actualizaciones de mood
  void _handleMoodUpdate(RealtimeMessage message, String userId, String? partnerId) {
    try {
      if (message.events.any((event) =>
          event.contains('create') || event.contains('update'))) {

        final payload = message.payload;
        if (payload is Map<String, dynamic>) {
          _moodUpdatesController.add(payload);
        }
      }
    } catch (e) {
      print('❌ Error procesando mood update: $e');
    }
  }

  /// Maneja actualizaciones de pulsos de pensamiento
  void _handleThoughtPulseUpdate(RealtimeMessage message, String userId, String? partnerId) {
    try {
      if (message.events.any((event) =>
          event.contains('create') || event.contains('update'))) {

        final payload = message.payload;
        if (payload is Map<String, dynamic>) {
          _thoughtPulsesController.add(payload);
        }
      }
    } catch (e) {
      print('❌ Error procesando thought pulse update: $e');
    }
  }

  /// Maneja actualizaciones de mensajes
  void _handleMessageUpdate(RealtimeMessage message, String userId, String? partnerId) {
    try {
      if (message.events.any((event) =>
          event.contains('create') || event.contains('update'))) {

        final payload = message.payload;
        if (payload is Map<String, dynamic>) {
          _messagesController.add(payload);
        }
      }
    } catch (e) {
      print('❌ Error procesando message update: $e');
    }
  }

  /// Maneja actualizaciones de actividades
  void _handleActivityUpdate(RealtimeMessage message, String userId, String? partnerId) {
    try {
      if (message.events.any((event) =>
          event.contains('create') || event.contains('update'))) {

        final payload = message.payload;
        if (payload is Map<String, dynamic>) {
          // Crear ActivityItem desde el payload con todos los campos requeridos
          final activity = ActivityItem(
            id: payload['\$id'] ?? '',
            userId: payload['userId'] ?? '',
            userName: payload['userName'] ?? 'Usuario', // Campo requerido agregado
            partnerId: payload['partnerId'],
            type: ActivityType.values.firstWhere(
              (e) => e.toString().split('.').last == (payload['type'] ?? 'other'),
              orElse: () => ActivityType.other,
            ),
            title: payload['title'] ?? 'Actividad', // Campo requerido agregado
            description: payload['description'] ?? '',
            timestamp: DateTime.tryParse(payload['timestamp'] ?? '') ?? DateTime.now(),
            metadata: payload['metadata'],
            isRead: payload['isRead'] ?? false,
          );
          _activityController.add(activity);
        }
      }
    } catch (e) {
      print('❌ Error procesando activity update: $e');
    }
  }

  /// Configura el heartbeat para mantener la conexión activa
  Future<void> _setupHeartbeat() async {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _lastHeartbeat = DateTime.now();
      print('💓 Heartbeat: $_lastHeartbeat');
    });
  }

  /// Obtiene actividades recientes para un usuario
  Future<List<ActivityItem>> getRecentActivities({
    required String userId,
    String? partnerId,
    int limit = 50,
  }) async {
    try {
      // Consultar actividades del usuario y su pareja
      final queries = [
        Query.or([
          Query.equal('userId', userId),
          if (partnerId != null) Query.equal('userId', partnerId),
        ]),
        Query.orderDesc('timestamp'),
        Query.limit(limit),
      ];

      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.activitiesCollectionId,
        queries: queries,
      );

      final activities = response.documents
          .map((doc) => ActivityItem.fromAppwriteData(doc.data))
          .toList();

      print('✅ ${activities.length} actividades cargadas');
      return activities;
    } catch (e) {
      print('❌ Error obteniendo actividades: $e');
      return [];
    }
  }

  /// Marca una actividad como leída
  Future<void> markActivityAsRead(String activityId) async {
    try {
      await _appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.activitiesCollectionId,
        documentId: activityId,
        data: {'isRead': true},
      );
      print('✅ Actividad $activityId marcada como leída');
    } catch (e) {
      print('❌ Error marcando actividad como leída: $e');
      rethrow;
    }
  }

  /// Limpia todas las suscripciones
  Future<void> _clearSubscriptions() async {
    print('🧹 Suscripciones limpiadas');
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Cierra el servicio y libera recursos
  Future<void> dispose() async {
    await _clearSubscriptions();
    _heartbeatTimer?.cancel();

    await _moodUpdatesController.close();
    await _activityController.close();
    await _thoughtPulsesController.close();
    await _messagesController.close();

    _isConnected = false;
    print('🔄 RealtimeSyncService cerrado');
  }
}
