import '../config/environment.dart';
import '../core/config/app_config.dart';

class AppConstants {
  static const String appName = 'CYBERSHIELD AI';
  static String get apiBaseUrl => Environment.apiBaseUrl;
  static String get wsBaseUrl => Environment.wsBaseUrl;
  static String get socketUrl => Environment.socketUrl;
  static String get policePortalUrl => AppConfig.adminUrl;
  static const String mapboxToken = 'pk.mapbox_token';
  
  static const double cardRadius = 16;
  static const double padding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
  static const double radiusCircular = 16;
  static const double radiusCard = 12;
  static const double radiusButton = 8;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  
  // Security
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
}

class StorageKeys {
  static const String jwtToken = 'jwt_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String onboardingComplete = 'onboarding_complete';
  static const String permissionsGranted = 'permissions_granted';
  static const String protectionEnabled = 'protection_enabled';
  static const String trustScore = 'trust_score';
  static const String blockedNumbers = 'blocked_numbers';
  static const String emergencyContacts = 'emergency_contacts';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String deviceId = 'device_id';
  static const String rememberDevice = 'remember_device';
  static const String mfaEnabled = 'mfa_enabled';
  static const String biometricEnabled = 'biometric_enabled';
}

class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String mfaSetup = '/auth/mfa/setup';
  static const String mfaVerify = '/auth/mfa/verify';
  static const String otpLogin = '/auth/otp/login';
  static const String otpVerify = '/auth/otp/verify';
  static const String phoneLogin = '/auth/phone/login';
  static const String googleLogin = '/auth/google/login';
  
  // Sessions
  static const String sessions = '/auth/sessions';
  static const String sessionRevoke = '/auth/sessions/revoke';
  
  // Citizen
  static const String dashboard = '/citizen/dashboard';
  static const String reportCall = '/citizen/report/call';
  static const String reportSms = '/citizen/report/sms';
  static const String reportWhatsapp = '/citizen/report/whatsapp';
  static const String trustScore = '/citizen/trust-score';
  static const String history = '/citizen/history';
  static const String blockNumber = '/citizen/block-number';
  static const String emergencySos = '/citizen/emergency-sos';
  static const String familyProtection = '/citizen/family-protection';
  static const String evidenceUpload = '/citizen/evidence/upload';
  static const String liveAlerts = '/citizen/alerts';
  static const String callProtection = '/citizen/call-protection';
  static const String smsProtection = '/citizen/sms-protection';
  static const String whatsappProtection = '/citizen/whatsapp-protection';
  static const String upiProtection = '/citizen/upi-protection';
  static const String bankProtection = '/citizen/bank-protection';
  static const String offlineSync = '/citizen/evidence/sync';
  
  // Deepfake
  static const String deepfakeVoice = '/deepfake/voice';
  static const String deepfakeVideo = '/deepfake/video';
  static const String deepfakeResult = '/deepfake/result';
  static const String deepfakeRealtime = '/deepfake/realtime';
  
  // Emergency
  static const String emergencyContact = '/emergency/contact';
  static const String emergencyQueue = '/emergency/queue';
  
  // Notification
  static const String registerDevice = '/device/register';
  static const String updateDeviceToken = '/device/update-token';
  
  // Police Integration
  static const String policeCases = '/police/cases';
  static const String policeEvidence = '/police/evidence';
  static const String policeEmergency = '/police/emergency';
  static const String policeIntelligence = '/police/intelligence';
  
  // Banks
  static const String bankVerify = '/bank/verify';
  static const String bankFreeze = '/bank/freeze';
  static const String bankDispute = '/bank/dispute';
}
