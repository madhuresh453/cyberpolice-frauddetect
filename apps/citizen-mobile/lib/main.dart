import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/permission_manager.dart';
import 'services/local_notification_service.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Startup diagnostics ───
  List<String> startupErrors = [];

  // ─── Safe Hive initialization ───
  try {
    await Hive.initFlutter();
    debugPrint('[startup] Hive initialized successfully');

    // Open each box individually with try/catch so one failure doesn't block all
    final boxes = ['settings', 'auth', 'emergency', 'evidence_queue', 'blocked_numbers', 'threat_cache'];
    for (final name in boxes) {
      try {
        await Hive.openBox(name);
        debugPrint('[startup] Hive box "$name" opened');
      } catch (e) {
        debugPrint('[startup] Hive box "$name" failed: $e');
        startupErrors.add('Hive box "$name": $e');
      }
    }
  } catch (e, s) {
    debugPrint('[startup] Hive init FAILED: $e');
    debugPrint('[startup] Stack trace: $s');
    startupErrors.add('Hive.initFlutter: $e');
    // Continue — app must launch even without Hive
  }

  // ─── Safe notification init ───
  try {
    await LocalNotificationService.initialize();
    debugPrint('[startup] Notifications initialized');
  } catch (e) {
    debugPrint('[startup] Notification init failed: $e');
    startupErrors.add('LocalNotificationService: $e');
  }

  // ─── Orientation lock ───
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('[startup] Orientation lock failed: $e');
  }

  // ─── Permission check (safe) ───
  bool allPermissionsGranted = false;
  try {
    allPermissionsGranted = await RaksaarPermissionManager.hasAllCriticalPermissions();
    debugPrint('[startup] Permissions pre-check: $allPermissionsGranted');
  } catch (e) {
    debugPrint('[startup] Permission check failed: $e');
    startupErrors.add('PermissionManager: $e');
  }

  // ─── ALWAYS reach runApp() ───
  runApp(
    ProviderScope(
      overrides: [
        if (allPermissionsGranted)
          permissionsGrantedProvider.overrideWith((ref) => PermissionsNotifier(true)),
      ],
      child: RaksaarApp(startupErrors: startupErrors),
    ),
  );
}