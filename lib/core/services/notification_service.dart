import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Servicio para manejar notificaciones locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    try {
      // Configuración para Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      print('✅ Servicio de notificaciones inicializado');
    } catch (e) {
      print('❌ Error inicializando notificaciones: $e');
    }
  }

  /// Solicita permisos de notificación
  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }

  /// Muestra una notificación de pulso de pensamiento
  Future<void> showThoughtPulseNotification({
    required String partnerName,
    String? message,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'thought_pulse_channel',
      'Pulsos de Pensamiento',
      channelDescription: 'Notificaciones cuando tu pareja piensa en ti',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '💕 $partnerName está pensando en ti',
      message ?? 'Tu pareja te envió un pulso de amor',
      platformChannelSpecifics,
    );
  }

  /// Muestra notificación de cambio de estado
  Future<void> showStatusUpdateNotification({
    required String partnerName,
    required String newStatus,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'status_update_channel',
      'Actualizaciones de Estado',
      channelDescription: 'Notificaciones cuando tu pareja actualiza su estado',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '🔄 $partnerName actualizó su estado',
      'Ahora está: $newStatus',
      platformChannelSpecifics,
    );
  }

  /// Maneja cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('Notificación tocada: ${response.payload}');
    // Aquí puedes agregar navegación específica según el tipo de notificación
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
