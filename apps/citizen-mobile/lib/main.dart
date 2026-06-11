import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('emergency');
  await Hive.openBox('evidence_queue');
  await Hive.openBox('blocked_numbers');
  
  // Initialize notifications
  await LocalNotificationService.initialize();
  
  // Setup Firebase Cloud Messaging
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    criticalAlert: true,
  );
  
  messaging.onTokenRefresh.listen((token) {
    // Send token to backend
  });
  
  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  
  // Lock orientation to portrait for security screens
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  runApp(
    const ProviderScope(
      child: CyberShieldApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await LocalNotificationService.showBackgroundNotification(message);
}