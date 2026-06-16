import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/api_client.dart';
import 'websocket_service.dart';
import 'native_bridge_service.dart';
import 'trust_engine.dart';

/// Initialize all RAKSAAR services on app startup
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._();
  factory AppInitializer() => _instance;
  AppInitializer._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize({required String userId}) async {
    if (_initialized) return;

    debugPrint('[AppInit] Initializing RAKSAAR services...');

    // 1. Ensure Hive boxes
    await Hive.openBox('auth');
    await Hive.openBox('settings');
    await Hive.openBox('emergency');
    await Hive.openBox('evidence_queue');
    await Hive.openBox('blocked_numbers');
    await Hive.openBox('trust_cache');
    await Hive.openBox('threat_cache');

    // 2. Initialize API client (singleton)
    final _ = ApiClient();
    debugPrint('[AppInit] API Client ready');

    // 3. Initialize Trust Engine (singleton)
    RaksaarTrustEngine();
    debugPrint('[AppInit] Trust Engine ready');

    // 4. Initialize Native Bridge (singleton) - connects to Android services
    final bridge = RaksaarNativeBridge();
    
    // 5. Start call protection service
    final callProtectionStarted = await bridge.startCallProtection();
    debugPrint('[AppInit] Call protection: $callProtectionStarted');
    
    // 6. Start SMS protection
    final smsProtectionStarted = await bridge.startSmsProtection();
    debugPrint('[AppInit] SMS protection: $smsProtectionStarted');

    // 7. Initialize WebSocket for real-time sync
    final ws = RaksaarWebSocketService();
    await ws.connect(userId: userId);
    debugPrint('[AppInit] WebSocket connected as citizen $userId');

    // 8. Listen for native bridge events (non-critical)
    bridge.events.listen(
      (event) {},
      onError: (e) => debugPrint('[AppInit] Bridge event error: $e'),
    );

    _initialized = true;
    debugPrint('[AppInit] All RAKSAAR services initialized successfully');
  }
}
