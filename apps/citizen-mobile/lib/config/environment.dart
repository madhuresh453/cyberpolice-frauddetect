import 'package:cybershield_citizen/core/config/app_config.dart';

class Environment {
  static String get apiBaseUrl => AppConfig.apiV1;
  static String get wsBaseUrl => AppConfig.webSocketUrl;
  static String get socketUrl => AppConfig.apiBaseUrl;

  // API timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Feature flags (mirror AppConfig)
  static bool get enableDeepfakeDetection => AppConfig.enableDeepfakeDetection;
  static bool get enableCallRecording => AppConfig.enableCallRecording;
  static bool get enableBackgroundService => AppConfig.enableBackgroundService;
  static bool get enableFamilyProtection => AppConfig.enableFamilyProtection;
  static bool get enableOfflineVault => AppConfig.enableOfflineVault;
  static bool get enableAiCopilot => AppConfig.enableAiCopilot;
  static bool get enableLiveAlerts => AppConfig.enableLiveAlerts;
  static bool get enableRealTimeSync => AppConfig.enableRealTimeSync;
  static bool get enableBiometricAuth => AppConfig.enableBiometricAuth;
  static bool get enableMFA => AppConfig.enableMFA;

  // App configuration
  static const String appName = 'RAKSAAR';
  static const String appTagline = 'Cyber Safety Operating System';
  static const String appVersion = '2.0.0';
  static const String buildNumber = '200';

  // Encryption
  static const String encryptionKey = '';
  static const int encryptionIterations = 10000;

  // Cache durations
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration trustScoreCache = Duration(minutes: 15);

  // Sync settings
  static const int maxOfflineSyncItems = 100;
  static const Duration syncInterval = Duration(minutes: 5);

  // WebSocket reconnection
  static const Duration wsReconnectDelay = Duration(seconds: 5);
  static const int wsMaxReconnectAttempts = 10;

  // Security
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const int sessionTimeoutMinutes = 30;
  static const bool requireCertificatePinning = true;
}