import 'package:flutter/foundation.dart' show kIsWeb;

class Environment {
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    return _getMobileBaseUrl();
  }

  static String get wsBaseUrl {
    if (kIsWeb) {
      return 'ws://localhost:5000/ws';
    }
    return _getMobileWsUrl();
  }

  static String get socketUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    return _getMobileBaseUrl().replaceFirst('/api/v1', '');
  }

  static String _getMobileBaseUrl() {
    // For Android emulator, use 10.0.2.2 to reach host localhost
    // For physical devices, the user should set their machine IP
    return 'http://10.0.2.2:5000/api/v1';
  }

  static String _getMobileWsUrl() {
    return 'ws://10.0.2.2:5000/ws';
  }

  static String get policePortalUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    return 'http://10.0.2.2:3000';
  }

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