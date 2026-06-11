import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();
    const androidDetails = AndroidNotificationDetails(
      'cybershield_alerts',
      'CyberShield Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  static Future<void> showBackgroundNotification(RemoteMessage message) async {
    if (!_initialized) await initialize();
    final notification = message.notification;
    if (notification == null) return;
    await showNotification(
      id: message.hashCode,
      title: notification.title ?? 'CyberShield',
      body: notification.body ?? '',
    );
  }

  static Future<void> showFraudAlert(String title, String body) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
    );
  }
}