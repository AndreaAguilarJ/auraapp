import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_constants.dart';
import 'appwrite_service.dart';

class AppwritePushNotificationService {
  static final AppwritePushNotificationService _instance = AppwritePushNotificationService._internal();
  factory AppwritePushNotificationService() => _instance;
  AppwritePushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AppwriteService _appwriteService = AppwriteService();

  String? _fcmToken;
  String? _appwriteTargetId;

  // Getters
  String? get fcmToken => _fcmToken;
  String? get appwriteTargetId => _appwriteTargetId;
  bool get isInitialized => _fcmToken != null && _appwriteTargetId != null;

  /// Inicializar el servicio completo de push notifications
  Future<void> initialize() async {
    try {
      // 1. Inicializar Firebase
      await Firebase.initializeApp();

      // 2. Configurar notificaciones locales
      await _initializeLocalNotifications();

      // 3. Solicitar permisos
      await _requestPermissions();

      // 4. Obtener token FCM
      await _getFCMToken();

      // 5. Configurar listeners
      _setupFirebaseListeners();

      if (kDebugMode) {
        print('✅ Push notifications inicializadas correctamente');
        print('🔑 FCM Token: $_fcmToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando push notifications: $e');
      }
    }
  }

  /// Registrar dispositivo como target en Appwrite
  Future<bool> registerAsTarget({required String userId}) async {
    if (_fcmToken == null) {
      if (kDebugMode) {
        print('❌ No se puede registrar target: FCM token no disponible');
      }
      return false;
    }

    try {
      // Crear target en Appwrite
      final response = await _appwriteService.account.createPushTarget(
        targetId: ID.unique(),
        identifier: _fcmToken!,
        providerId: 'fcm-provider', // ID del provider FCM configurado en Appwrite
      );

      _appwriteTargetId = response.$id;

      // Guardar localmente para futuras actualizaciones
      await _saveTargetId(_appwriteTargetId!);

      if (kDebugMode) {
        print('✅ Target registrado en Appwrite: $_appwriteTargetId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error registrando target en Appwrite: $e');
      }
      return false;
    }
  }

  /// Actualizar token FCM en Appwrite target existente
  Future<bool> updateTarget(String newToken) async {
    if (_appwriteTargetId == null) {
      if (kDebugMode) {
        print('❌ No se puede actualizar target: Target ID no disponible');
      }
      return false;
    }

    try {
      await _appwriteService.account.updatePushTarget(
        targetId: _appwriteTargetId!,
        identifier: newToken,
      );

      _fcmToken = newToken;
      await _saveFCMToken(newToken);

      if (kDebugMode) {
        print('✅ Target actualizado en Appwrite con nuevo token');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error actualizando target en Appwrite: $e');
      }
      return false;
    }
  }

  /// Enviar push notification usando Appwrite Messaging
  Future<bool> sendPushNotification({
    required List<String> targetIds,
    required String title,
    required String body,
    Map<String, String>? data,
    String? imageUrl,
  }) async {
    try {
      // Crear mensaje en Appwrite
      final message = await _appwriteService.messaging.createPush(
        messageId: ID.unique(),
        title: title,
        body: body,
        targets: targetIds,
        data: data,
        image: imageUrl,
        // Enviar inmediatamente
        scheduledAt: null,
      );

      if (kDebugMode) {
        print('✅ Push notification enviada: ${message.$id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enviando push notification: $e');
      }
      return false;
    }
  }

  /// Enviar notificación de invitación de conversación
  Future<bool> sendConversationInvitation({
    required String toUserId,
    required String fromUserName,
    required String topicTitle,
    required String invitationId,
  }) async {
    try {
      // Obtener target ID del usuario destinatario
      final targetId = await _getUserTargetId(toUserId);
      if (targetId == null) {
        if (kDebugMode) {
          print('❌ Usuario $toUserId no tiene target registrado');
        }
        return false;
      }

      return await sendPushNotification(
        targetIds: [targetId],
        title: '💬 Nueva invitación de conversación',
        body: '$fromUserName te invita a hablar sobre "$topicTitle"',
        data: {
          'type': 'conversation_invitation',
          'invitationId': invitationId,
          'fromUserId': toUserId,
          'fromUserName': fromUserName,
          'topicTitle': topicTitle,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enviando invitación: $e');
      }
      return false;
    }
  }

  /// Enviar notificación de respuesta a invitación
  Future<bool> sendInvitationResponse({
    required String toUserId,
    required String responderName,
    required String topicTitle,
    required bool accepted,
    required String invitationId,
  }) async {
    try {
      final targetId = await _getUserTargetId(toUserId);
      if (targetId == null) return false;

      final title = accepted ? '✅ Invitación aceptada' : '❌ Invitación rechazada';
      final body = accepted
          ? '$responderName aceptó tu invitación para hablar sobre "$topicTitle"'
          : '$responderName rechazó tu invitación para hablar sobre "$topicTitle"';

      return await sendPushNotification(
        targetIds: [targetId],
        title: title,
        body: body,
        data: {
          'type': 'invitation_response',
          'invitationId': invitationId,
          'accepted': accepted.toString(),
          'responderName': responderName,
          'topicTitle': topicTitle,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enviando respuesta: $e');
      }
      return false;
    }
  }

  /// Configurar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    // Solicitar permisos de Firebase
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('🔔 Permisos de notificación: ${settings.authorizationStatus}');
    }

    // Solicitar permisos adicionales en Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
    }
  }

  /// Obtener token FCM
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        await _saveFCMToken(_fcmToken!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo FCM token: $e');
      }
    }
  }

  /// Configurar listeners de Firebase
  void _setupFirebaseListeners() {
    // Listener para cuando la app está en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Listener para cuando se toca una notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Listener para cuando el token se actualiza
    _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);
  }

  /// Manejar mensajes cuando la app está en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📨 Mensaje recibido en foreground: ${message.notification?.title}');
    }

    // Mostrar notificación local
    await _showLocalNotification(
      title: message.notification?.title ?? 'Nueva notificación',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Manejar tap en notificación
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    if (kDebugMode) {
      print('👆 Notificación tocada: ${message.data}');
    }

    // Aquí puedes navegar a la pantalla apropiada
    await _navigateBasedOnNotification(message.data);
  }

  /// Manejar actualización de token FCM
  Future<void> _handleTokenRefresh(String newToken) async {
    if (kDebugMode) {
      print('🔄 Token FCM actualizado: $newToken');
    }

    await updateTarget(newToken);
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aura_conversations',
      'Conversaciones Guiadas',
      channelDescription: 'Notificaciones de invitaciones y conversaciones',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      color: Color(0xFF6B73FF),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Manejar tap en notificación local
  void _onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('👆 Notificación local tocada: ${response.payload}');
    }

    // Procesar payload y navegar
    if (response.payload != null) {
      _navigateBasedOnPayload(response.payload!);
    }
  }

  /// Navegar basado en datos de notificación
  Future<void> _navigateBasedOnNotification(Map<String, dynamic> data) async {
    final type = data['type'] as String?;

    switch (type) {
      case 'conversation_invitation':
        // Navegar a pantalla de invitaciones
        // NavigationService.navigateToInvitations();
        break;
      case 'invitation_response':
        // Navegar a pantalla de conversaciones
        // NavigationService.navigateToConversations();
        break;
    }
  }

  /// Navegar basado en payload de notificación local
  void _navigateBasedOnPayload(String payload) {
    // Implementar navegación basada en payload
  }

  /// Obtener target ID de un usuario (implementar según tu lógica)
  Future<String?> _getUserTargetId(String userId) async {
    try {
      // Aquí deberías consultar tu base de datos para obtener el targetId del usuario
      // Por ejemplo, podrías tener una colección 'user_targets' que mapee userId -> targetId
      // O almacenar el targetId en el documento del usuario

      return null; // Implementar según tu estructura de datos
    } catch (e) {
      return null;
    }
  }

  /// Guardar FCM token localmente
  Future<void> _saveFCMToken(String token) async {
    // Implementar usando SharedPreferences o tu método preferido
  }

  /// Guardar Target ID localmente
  Future<void> _saveTargetId(String targetId) async {
    // Implementar usando SharedPreferences o tu método preferido
  }

  /// Cleanup resources
  void dispose() {
    // Cleanup si es necesario
  }
}
