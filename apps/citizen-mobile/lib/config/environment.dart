import 'package:cybershield_citizen/core/config/app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Environment {
  static String get apiBaseUrl => AppConfig.apiV1;
  static String get wsBaseUrl => AppConfig.webSocketUrl;
  static String get socketUrl => AppConfig.apiBaseUrl;

  // API timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Feature flags
  static bool get enableDeepfakeDetection => true;
  static bool get enableCallRecording => true;
  static bool get enableBackgroundService => true;
  static bool get enableFamilyProtection => true;
  static bool get enableOfflineVault => true;
  static bool get enableAiCopilot => true;
  static bool get enableLiveAlerts => true;
  static bool get enableRealTimeSync => true;
  static bool get enableBiometricAuth => true;
  static bool get enableMFA => true;

  // App configuration
  static const String appName = 'CYBERSHIELD AI';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Encryption
  static const String encryptionKey = 'cybershield_aes_256_key_v1';
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