import 'package:flutter/foundation.dart';

/// Centralized configuration for RAKSAAR – Cyber Safety Operating System.
/// Automatically switches between Development and Production based on build mode.
/// NO hardcoded URLs allowed outside this file.
class AppConfig {
  AppConfig._();

  // ─── Build Mode Detection ───
  static const bool isProduction = kReleaseMode;
  static const bool isDevelopment = !kReleaseMode;

  // ─── Production URLs ───
  static const String _prodApiBaseUrl = 'https://api.uni6ctf.online';
  static const String _prodAiBaseUrl = 'https://api.uni6ctf.online';
  static const String _prodAdminUrl = 'https://police.uni6ctf.online';
  static const String _prodAppUrl = 'https://app.uni6ctf.online';
  static const String _prodWebSocketUrl = '';

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

  // ─── App Identity ───
  static const String appName = 'RAKSAAR';
  static const String appTagline = 'Cyber Safety Operating System';
  static const String appVersion = '2.0.0';
  static const String buildNumber = '200';
  static const String appDescription = 'National Cyber Safety Platform – AI Powered';

  // ─── Feature Flags ───
  static const bool enableFirebase = true;
  static const bool enableAnalytics = kReleaseMode;
  static const bool enableCrashlytics = kReleaseMode;
  static const bool enableBackgroundService = true;
  static const bool enableDeepfakeDetection = true;
  static const bool enableCallRecording = true;
  static const bool enableFamilyProtection = true;
  static const bool enableOfflineVault = true;
  static const bool enableAiCopilot = true;
  static const bool enableLiveAlerts = true;
  static const bool enableRealTimeSync = true;
  static const bool enableBiometricAuth = true;
  static const bool enableMFA = true;

  // ─── Timeouts ───
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 20000;
  static const int sendTimeoutMs = 15000;
  static const Duration connectTimeout = Duration(milliseconds: connectTimeoutMs);
  static const Duration receiveTimeout = Duration(milliseconds: receiveTimeoutMs);

  // ─── Cache Durations ───
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration trustScoreCache = Duration(minutes: 15);

  // ─── Sync Settings ───
  static const int maxOfflineSyncItems = 100;
  static const Duration syncInterval = Duration(minutes: 5);

  // ─── WebSocket Reconnection ───
  static const Duration wsReconnectDelay = Duration(seconds: 5);
  static const int wsMaxReconnectAttempts = 10;

  // ─── Security ───
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const int sessionTimeoutMinutes = 30;
  static const bool requireCertificatePinning = false;
  static const String encryptionKey = '';
  static const int encryptionIterations = 10000;

  // ─── Splash ───
  static const Duration maxSplashDuration = Duration(seconds: 3);

  // ─── Debug Info ───
  static void printConfig() {
    debugPrint('═══════════════════════════════════');
    debugPrint('RAKSAAR – Cyber Safety OS');
    debugPrint('Mode: ${isProduction ? "PRODUCTION" : "DEVELOPMENT"}');
    debugPrint('API: $apiBaseUrl');
    debugPrint('AI: $aiBaseUrl');
    debugPrint('Admin: $adminUrl');
    debugPrint('WebSocket: $webSocketUrl');
    debugPrint('Version: $appVersion ($buildNumber)');
    debugPrint('═══════════════════════════════════');
  }
}