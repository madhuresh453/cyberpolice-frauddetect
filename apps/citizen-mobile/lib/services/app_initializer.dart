import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/permission_manager.dart';
import 'background_service.dart';
import 'local_notification_service.dart';
import 'websocket_service.dart' as ws;
import 'native_bridge_service.dart';

/// AppInitializer - starts all protection services after permissions granted
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._();
  factory AppInitializer() => _instance;
  AppInitializer._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    debugPrint('[AppInitializer] Starting protection engine...');

    // Step 1: Initialize native bridge
    final bridge = RaksaarNativeBridge();

    // Step 2: Start background service
    final bg = BackgroundService();
    await bg.init();

    // Step 3: Restore monitoring state
    await bg.restoreState();

    // Step 4: Connect WebSocket for real-time alerts
    final webSocket = ws.RaksaarWebSocketService();
    await webSocket.connect(userId: 'citizen', serverUrl: '');

    // Step 5: Listen for fraud alerts via WebSocket
    webSocket.events?.listen((alert) {
      debugPrint('[AppInitializer] WS Alert: $alert');
      if (alert['type'] == 'fraud_alert') {
        LocalNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: alert['title'] ?? '🚨 Fraud Alert',
          body: alert['message'] ?? '',
        );
      }
    });

    // Step 6: Start call protection if permissions granted
    final permissions = await RaksaarPermissionManager.checkAllPermissions();
    if (permissions['phone'] == true) {
      await bridge.startCallProtection();
    }

    // Step 7: Start SMS protection if permissions granted
    if (permissions['sms'] == true) {
      await bridge.startSmsProtection();
    }

    debugPrint('[AppInitializer] Protection engine ready');
  }
}