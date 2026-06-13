import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || !_initialized) return;
    
    const androidDetails = AndroidNotificationDetails(
      'cybershield_alerts',
      'CYBERSHIELD Alerts',
      channelDescription: 'Fraud alerts and notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  static Future<void> showBackgroundNotification(dynamic message) async {
    if (kIsWeb || !_initialized) return;
    try {
      final notification = message.notification;
      if (notification != null) {
        await showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification.title ?? 'CYBERSHIELD Alert',
          body: notification.body ?? '',
          payload: message.data?.toString(),
        );
      }
    } catch (_) {}
  }

  static Future<String?> getFcmToken() async {
    // Firebase Messaging token - returns null if Firebase not configured
    try {
      // Uncomment when Firebase is configured:
      // return await FirebaseMessaging.instance.getToken();
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> requestPermissions() async {
    if (kIsWeb) return;
    try {
      await _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    } catch (_) {}
  }

  static Future<void> subscribeToTopic(String topic) async {
    // Uncomment when Firebase is configured:
    // await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    // Uncomment when Firebase is configured:
    // await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}