import 'package:flutter/foundation.dart';

/// Centralized configuration for CyberShield AI (RAKSAAR).
/// Automatically switches between Development and Production based on build mode.
class AppConfig {
  AppConfig._();

  // ─── Build Mode Detection ───
  static const bool isProduction = kReleaseMode;
  static const bool isDevelopment = !kReleaseMode;

  // ─── Production URLs ───
  static const String _prodApiBaseUrl = 'https://api.uni6ctf.online';
  static const String _prodAiBaseUrl = 'https://api.uni6ctf.online';
  static const String _prodAdminUrl = 'https://admin.uni6ctf.online';
  static const String _prodAppUrl = 'https://app.uni6ctf.online';
  static const String _prodWebSocketUrl = 'wss://api.uni6ctf.online/ws';

  // ─── Development URLs ───
  static const String _devApiBaseUrl = 'http://10.0.2.2:5000';
  static const String _devAiBaseUrl = 'http://10.0.2.2:8000';
  static const String _devAdminUrl = 'http://localhost:3001';
  static const String _devAppUrl = 'http://localhost:3000';
  static const String _devWebSocketUrl = 'ws://10.0.2.2:5000/ws';

  // ─── Public Getters ───
  static String get apiBaseUrl => isProduction ? _prodApiBaseUrl : _devApiBaseUrl;
  static String get aiBaseUrl => isProduction ? _prodAiBaseUrl : _devAiBaseUrl;
  static String get adminUrl => isProduction ? _prodAdminUrl : _devAdminUrl;
  static String get appUrl => isProduction ? _prodAppUrl : _devAppUrl;
  static String get webSocketUrl => isProduction ? _prodWebSocketUrl : _devWebSocketUrl;

  // ─── Full API URLs ───
  static String get apiV1 => '$apiBaseUrl/api/v1';
  static String get apiV2 => '$apiBaseUrl/api/v2';
  static String get wsEndpoint => webSocketUrl;

  // ─── Feature Flags ───
  static const bool enableFirebase = true;
  static const bool enableAnalytics = kReleaseMode;
  static const bool enableCrashlytics = kReleaseMode;
  static const bool enableBackgroundService = true;

  // ─── Timeouts ───
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // ─── Debug Info ───
  static void printConfig() {
    debugPrint('═══════════════════════════════════');
    debugPrint('CyberShield AI - AppConfig');
    debugPrint('Mode: ${isProduction ? "PRODUCTION" : "DEVELOPMENT"}');
    debugPrint('API: $apiBaseUrl');
    debugPrint('AI: $aiBaseUrl');
    debugPrint('WebSocket: $webSocketUrl');
    debugPrint('═══════════════════════════════════');
  }
}