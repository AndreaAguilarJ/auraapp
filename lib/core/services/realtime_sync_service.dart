import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:async';
import 'dart:convert';

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
          // Procesar el campo metadata si es una cadena JSON
          Map<String, dynamic>? metadataMap;
          if (payload['metadata'] is String) {
            try {
              // Intentar convertir la cadena JSON de vuelta a un mapa
              final metadataStr = payload['metadata'] as String;
              if (metadataStr.isNotEmpty && metadataStr != '{}') {
                metadataMap = json.decode(metadataStr) as Map<String, dynamic>;
                print('ℹ️ Campo metadata convertido de JSON string a Map');
              } else {
                metadataMap = {};
              }
            } catch (e) {
              print('⚠️ Error al convertir metadata de JSON a Map: $e');
              metadataMap = {};
            }
          } else {
            metadataMap = payload['metadata'] as Map<String, dynamic>?;
          }

          // Crear ActivityItem desde el payload con todos los campos requeridos
          final activity = ActivityItem(
            id: payload['\$id'] ?? '',
            userId: payload['userId'] ?? '',
            userName: payload['userName'] ?? 'Usuario',
            partnerId: payload['partnerId'],
            type: ActivityType.values.firstWhere(
              (e) => e.toString().split('.').last == (payload['type'] ?? 'other'),
              orElse: () => ActivityType.other,
            ),
            title: payload['title'] ?? 'Actividad',
            description: payload['description'] ?? '',
            timestamp: DateTime.tryParse(payload['timestamp'] ?? '') ?? DateTime.now(),
            metadata: metadataMap,
            isRead: payload['isRead'] ?? false,
          );

          print('✅ Actividad recibida y procesada correctamente: ${activity.title}');
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
      // Registros de depuración para verificar IDs
      print('📊 Consultando actividades con:');
      print('   - userId: $userId${userId.isEmpty ? " ⚠️ VACÍO" : ""}');
      print('   - partnerId: $partnerId${partnerId == null || partnerId.isEmpty ? " ⚠️ VACÍO/NULO" : ""}');

      if (userId.isEmpty) {
        print('⚠️ ADVERTENCIA: userId está vacío, esto causará problemas en la consulta');
        return [];
      }

      // Primero, intentemos obtener TODAS las actividades para ver qué hay en la base de datos
      print('🔍 Consultando TODAS las actividades en la colección para depuración...');
      final allActivitiesResponse = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.activitiesCollectionId,
        queries: [
          Query.limit(10), // Solo las primeras 10 para depuración
        ],
      );

      print('📋 Total de documentos en la colección activities: ${allActivitiesResponse.total}');
      if (allActivitiesResponse.documents.isNotEmpty) {
        print('📋 Ejemplos de documentos encontrados:');
        for (int i = 0; i < allActivitiesResponse.documents.length && i < 3; i++) {
          final doc = allActivitiesResponse.documents[i];
          print('   - Doc ${i + 1}: userId=${doc.data['userId']}, title="${doc.data['title']}", timestamp=${doc.data['timestamp']}');
        }
      } else {
        print('📋 No hay documentos en la colección activities');
      }

      // Ahora hacer la consulta específica para el usuario
      final queries = [
        Query.or([
          Query.equal('userId', userId),
          if (partnerId != null && partnerId.isNotEmpty)
            Query.equal('userId', partnerId)
        ]),
        Query.orderDesc('timestamp'),
        Query.limit(limit),
      ];

      // Mostrar mensaje si partnerId no es válido
      if (partnerId == null || partnerId.isEmpty) {
        print('⚠️ partnerId no válido, solo se mostrarán actividades del usuario actual');
      }

      print('🔍 Ejecutando consulta específica para el usuario...');
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.activitiesCollectionId,
        queries: queries,
      );

      print('📊 Respuesta de consulta específica: ${response.documents.length} documentos encontrados');

      if (response.documents.isNotEmpty) {
        print('📊 Documentos que coinciden con la consulta:');
        for (int i = 0; i < response.documents.length && i < 3; i++) {
          final doc = response.documents[i];
          print('   - Match ${i + 1}: userId=${doc.data['userId']}, title="${doc.data['title']}"');
        }
      }

      final activities = <ActivityItem>[];
      for (final doc in response.documents) {
        try {
          final activity = ActivityItem.fromAppwriteData(doc.data);
          activities.add(activity);
          print('✅ Actividad convertida correctamente: ${activity.title}');
        } catch (e) {
          print('❌ Error convirtiendo documento a ActivityItem: $e');
          print('📄 Datos del documento problemático: ${doc.data}');
        }
      }

      print('✅ ${activities.length} actividades procesadas exitosamente');

      // Si no hay actividades, mostrar un mensaje adicional de depuración
      if (activities.isEmpty) {
        print('ℹ️ No se encontraron actividades para el usuario $userId${partnerId != null ? " o su pareja $partnerId" : ""}');
        print('ℹ️ Verifique que existen documentos en la colección ${AppwriteConstants.activitiesCollectionId}');
      }

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

  /// Guarda una actividad en la base de datos
  Future<void> storeActivityInDatabase({
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Convertir el campo metadata a JSON string si existe
      if (data.containsKey('metadata') && data['metadata'] is Map) {
        try {
          // Intentar convertir el mapa a una cadena JSON
          data['metadata'] = json.encode(data['metadata']);
          print('ℹ️ Campo metadata convertido a cadena JSON');
        } catch (e) {
          print('⚠️ No se pudo convertir metadata a JSON: $e');
          // Si falla la conversión, establecer un valor predeterminado
          data['metadata'] = '{}';
        }
      } else if (data['metadata'] == null) {
        // Si es nulo, establecer un objeto vacío
        data['metadata'] = '{}';
      }

      await _appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.activitiesCollectionId,
        documentId: documentId,
        data: data,
      );

      print('✅ Actividad guardada en Appwrite con ID: $documentId');
    } catch (e) {
      print('❌ Error guardando actividad en Appwrite: $e');
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
