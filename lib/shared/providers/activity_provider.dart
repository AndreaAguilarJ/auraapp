import 'package:flutter/material.dart';
import 'dart:async';
import 'package:appwrite/appwrite.dart'; // Importamos appwrite para usar ID

import '../../features/shared_space/domain/models/activity_item.dart';
import '../../core/services/realtime_sync_service.dart';
import '../../core/constants/app_constants.dart'; // Importamos constantes
import 'auth_provider.dart';

/// Provider que gestiona las actividades recientes y el estado de sincronización
class ActivityProvider extends ChangeNotifier {
  static ActivityProvider? _instance;
  static ActivityProvider? get instance => _instance;

  final RealtimeSyncService _syncService = RealtimeSyncService.instance;

  // Estado de las actividades
  List<ActivityItem> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSync;
  bool _isConnected = false;

  // Suscripciones a streams
  StreamSubscription<ActivityItem>? _activitySubscription;
  StreamSubscription<Map<String, dynamic>>? _moodSubscription;
  StreamSubscription<Map<String, dynamic>>? _pulseSubscription;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  // Getters
  List<ActivityItem> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSync => _lastSync;
  bool get isConnected => _isConnected;
  bool get hasUnreadActivities => _activities.any((activity) => !activity.isRead);
  int get unreadCount => _activities.where((activity) => !activity.isRead).length;

  /// Constructor
  ActivityProvider() {
    _instance = this;
  }

  /// Inicializa el provider
  Future<void> initialize(String userId, String? partnerId) async {
    _setLoading(true);
    _clearError();

    try {
      // Cargar actividades existentes
      await _loadActivities(userId, partnerId);

      // Configurar suscripciones en tiempo real
      await _setupRealtimeListeners(userId, partnerId);

      // Configurar el servicio de sincronización
      await _syncService.setupUserSubscriptions(userId, partnerId);

      _isConnected = true;
      _lastSync = DateTime.now();

      print('✅ ActivityProvider inicializado correctamente');
    } catch (e) {
      _setError('Error al inicializar actividades: $e');
      print('❌ Error inicializando ActivityProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga las actividades desde la base de datos
  Future<void> _loadActivities(String userId, String? partnerId) async {
    try {
      final loadedActivities = await _syncService.getRecentActivities(
        userId: userId,
        partnerId: partnerId,
        limit: 50,
      );

      _activities = loadedActivities;
      _sortActivities();
      notifyListeners();

      print('✅ ${_activities.length} actividades cargadas');
    } catch (e) {
      print('❌ Error cargando actividades: $e');
      throw e;
    }
  }

  /// Configura los listeners en tiempo real
  Future<void> _setupRealtimeListeners(String userId, String? partnerId) async {
    try {
      // Limpiar suscripciones existentes
      await _clearSubscriptions();

      // Suscribirse a nuevas actividades
      _activitySubscription = _syncService.activityStream.listen((activity) {
        _addActivity(activity);
      });

      // Suscribirse a actualizaciones de mood
      _moodSubscription = _syncService.moodUpdates.listen((data) {
        _handleMoodUpdate(data);
      });

      // Suscribirse a pulsos de pensamiento
      _pulseSubscription = _syncService.thoughtPulses.listen((data) {
        _handleThoughtPulse(data);
      });

      // Suscribirse a mensajes
      _messageSubscription = _syncService.messages.listen((data) {
        _handleMessage(data);
      });

      print('✅ Listeners en tiempo real configurados');
    } catch (e) {
      print('❌ Error configurando listeners: $e');
    }
  }

  /// Maneja actualizaciones de mood
  void _handleMoodUpdate(Map<String, dynamic> data) {
    try {
      final activity = ActivityItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        userId: data['userId'] ?? '',
        userName: _getUserName(data['userId']),
        type: ActivityType.moodUpdate,
        title: 'Estado de ánimo actualizado',
        description: data['contextNote'] ?? 'Cambió su estado de ánimo',
        timestamp: DateTime.now(),
        metadata: data,
      );

      _addActivity(activity);
      _lastSync = DateTime.now();
    } catch (e) {
      print('❌ Error procesando mood update: $e');
    }
  }

  /// Maneja pulsos de pensamiento
  void _handleThoughtPulse(Map<String, dynamic> data) {
    try {
      final activity = ActivityItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        userId: data['fromUserId'] ?? '',
        userName: _getUserName(data['fromUserId']),
        type: ActivityType.thoughtPulse,
        title: 'Pulso de pensamiento',
        description: data['message'] ?? 'Te envió un pulso de pensamiento',
        timestamp: DateTime.now(),
        metadata: data,
      );

      _addActivity(activity);
      _lastSync = DateTime.now();
    } catch (e) {
      print('❌ Error procesando thought pulse: $e');
    }
  }

  /// Maneja mensajes
  void _handleMessage(Map<String, dynamic> data) {
    try {
      final activity = ActivityItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        userId: data['senderId'] ?? '',
        userName: _getUserName(data['senderId']),
        type: ActivityType.message,
        title: 'Nuevo mensaje',
        description: data['content'] ?? 'Te envió un mensaje',
        timestamp: DateTime.now(),
        metadata: data,
      );

      _addActivity(activity);
      _lastSync = DateTime.now();
    } catch (e) {
      print('❌ Error procesando message: $e');
    }
  }

  /// Agrega una nueva actividad
  void _addActivity(ActivityItem activity) {
    // Evitar duplicados
    if (!_activities.any((a) => a.id == activity.id)) {
      _activities.insert(0, activity);

      // Mantener solo las últimas 50 actividades
      if (_activities.length > 50) {
        _activities = _activities.take(50).toList();
      }

      _sortActivities();
      notifyListeners();

      print('➕ Nueva actividad agregada: ${activity.title}');
    }
  }

  /// Obtiene el nombre del usuario (método temporal)
  String _getUserName(String? userId) {
    if (userId == null) return 'Usuario';

    try {
      final authProvider = AuthProvider.instance;
      if (authProvider?.currentUser?.id == userId) {
        return authProvider?.currentUser?.name ?? 'Tú';
      }
      return 'Tu pareja';
    } catch (e) {
      return 'Usuario';
    }
  }

  /// Ordena las actividades por timestamp (más recientes primero)
  void _sortActivities() {
    _activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Marca una actividad como leída
  Future<void> markAsRead(String activityId) async {
    try {
      // Actualizar en la base de datos
      await _syncService.markActivityAsRead(activityId);

      // Actualizar localmente
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index != -1) {
        _activities[index] = _activities[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error marcando actividad como leída: $e');
    }
  }

  /// Marca todas las actividades como leídas
  Future<void> markAllAsRead() async {
    try {
      final unreadActivities = _activities.where((a) => !a.isRead).toList();

      for (final activity in unreadActivities) {
        await markAsRead(activity.id);
      }

      print('✅ Todas las actividades marcadas como leídas');
    } catch (e) {
      print('❌ Error marcando todas como leídas: $e');
    }
  }

  /// Refresca las actividades
  Future<void> refresh() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 Forzando recarga de actividades...');
      final authProvider = AuthProvider.instance;
      if (authProvider?.currentUser != null) {
        final userId = authProvider!.currentUser!.id;
        final partnerId = authProvider.currentUser!.partnerId;

        // Mostrar los IDs que estamos usando para depuración
        print('🔍 Recargando actividades para: userId=$userId, partnerId=$partnerId');

        // Forzar recarga de actividades limpiando la lista actual
        _activities = [];
        notifyListeners();

        // Recargar las actividades desde cero
        await _loadActivities(userId, partnerId);
        _lastSync = DateTime.now();

        print('✅ Recarga completada: ${_activities.length} actividades');
      } else {
        _setError('No se pudo refrescar: usuario no disponible');
        print('❌ Error refrescando: usuario no disponible');
      }
    } catch (e) {
      _setError('Error al refrescar: $e');
      print('❌ Error refrescando actividades: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fuerza una recarga completa de actividades (alias más explícito de refresh)
  Future<void> refreshActivities() => refresh();

  /// Guarda una nueva actividad en la base de datos de Appwrite y la añade localmente
  Future<void> createAndAddActivity({
    required String userId,
    required String userName,
    required ActivityType type,
    required String title,
    required String description,
    String? partnerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final authProvider = AuthProvider.instance;
      if (authProvider == null || authProvider.currentUser == null) {
        print('❌ No se pudo crear actividad: usuario no autenticado');
        return;
      }

      final now = DateTime.now();
      final timestamp = now.toIso8601String();

      // Crear datos de la actividad
      final activityData = {
        'userId': userId,
        'userName': userName,
        'partnerId': partnerId,
        'type': type.toString().split('.').last,
        'title': title,
        'description': description,
        'timestamp': timestamp,
        'isRead': false,
        'metadata': metadata ?? {},
      };

      print('🔄 Guardando actividad en Appwrite: $title');

      // Guardar en Appwrite directamente
      try {
        final docId = ID.unique();
        await _syncService.storeActivityInDatabase(
          documentId: docId,
          data: activityData
        );

        print('✅ Actividad guardada exitosamente en Appwrite con ID: $docId');

        // Crear un ActivityItem con el ID asignado por Appwrite
        final activity = ActivityItem(
          id: docId,
          userId: userId,
          userName: userName,
          partnerId: partnerId,
          type: type,
          title: title,
          description: description,
          timestamp: now,
          metadata: metadata,
          isRead: false,
        );

        // Añadir localmente también
        _addActivity(activity);

      } catch (e) {
        print('❌ Error guardando actividad en Appwrite: $e');
        // Añadir localmente de todos modos con un ID temporal
        final activity = ActivityItem(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          userName: userName,
          partnerId: partnerId,
          type: type,
          title: title,
          description: description,
          timestamp: now,
          metadata: metadata,
          isRead: false,
        );

        _addActivity(activity);
      }
    } catch (e) {
      print('❌ Error en createAndAddActivity: $e');
    }
  }

  /// Agrega una actividad de conexión personalizada (mejorado para guardar en Appwrite)
  Future<void> addConnectionActivity(String message) async {
    try {
      final authProvider = AuthProvider.instance;
      if (authProvider?.currentUser == null) {
        print('❌ No se pudo crear actividad de conexión: usuario no autenticado');
        return;
      }

      // Usar el ID del usuario real en lugar de 'system'
      await createAndAddActivity(
        userId: authProvider!.currentUser!.id, // <- CAMBIO PRINCIPAL: usar el ID real del usuario
        userName: authProvider.currentUser!.name, // <- CAMBIO: usar el nombre real del usuario
        type: ActivityType.connection,
        title: 'Estado de conexión',
        description: message,
        partnerId: authProvider.currentUser!.partnerId,
      );

    } catch (e) {
      print('❌ Error creando actividad de conexión: $e');
      // Fallback al método antiguo si hay errores, pero también con el ID real del usuario
      final authProvider = AuthProvider.instance;
      final activity = ActivityItem(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        userId: authProvider?.currentUser?.id ?? 'system', // usar ID real o system como fallback
        userName: authProvider?.currentUser?.name ?? 'AURA',
        type: ActivityType.connection,
        title: 'Estado de conexión',
        description: message,
        timestamp: DateTime.now(),
      );

      _addActivity(activity);
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

  /// Limpia las suscripciones
  Future<void> _clearSubscriptions() async {
    await _activitySubscription?.cancel();
    await _moodSubscription?.cancel();
    await _pulseSubscription?.cancel();
    await _messageSubscription?.cancel();

    _activitySubscription = null;
    _moodSubscription = null;
    _pulseSubscription = null;
    _messageSubscription = null;
  }

  /// Limpia recursos
  @override
  void dispose() {
    _clearSubscriptions();
    _instance = null;
    super.dispose();
  }
}
