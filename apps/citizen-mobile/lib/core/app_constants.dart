import 'config/app_config.dart';

class AppConstants {
  static const String appName = 'RAKSAAR';
  static const String appTagline = 'Cyber Safety Operating System';
  static const String appFooter = 'Building a Safer India Together';
  static String get apiBaseUrl => AppConfig.apiV2;
  static String get apiV1BaseUrl => AppConfig.apiV1;
}

class StorageKeys {
  static const String jwtToken = 'jwt_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String onboardingComplete = 'onboarding_complete';
  static const String permissionsGranted = 'permissions_granted';
  static const String blockedNumbers = 'blocked_numbers';
  static const String emergencyContacts = 'emergency_contacts';
  static const String protectionEnabled = 'protection_enabled';
  static const String themeMode = 'theme_mode';
  static const String biometricEnabled = 'biometric_enabled';
  static const String deviceId = 'device_id';
}