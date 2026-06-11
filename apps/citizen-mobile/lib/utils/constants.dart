class AppConstants {
  static const String appName = 'CYBERSHIELD AI';
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api/v1';
  static const String wsBaseUrl = 'ws://10.0.2.2:5000/ws';
  static const String mapboxToken = 'pk.mapbox_token';
  
  static const double cardRadius = 16;
  static const double padding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
}

class StorageKeys {
  static const String jwtToken = 'jwt_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String onboardingComplete = 'onboarding_complete';
  static const String trustScore = 'trust_score';
  static const String blockedNumbers = 'blocked_numbers';
  static const String emergencyContacts = 'emergency_contacts';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
}

class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  
  // Citizen
  static const String reportCall = '/citizen/report/call';
  static const String reportSms = '/citizen/report/sms';
  static const String reportWhatsapp = '/citizen/report/whatsapp';
  static const String trustScore = '/citizen/trust-score';
  static const String history = '/citizen/history';
  static const String blockNumber = '/citizen/block-number';
  static const String emergencySos = '/citizen/emergency-sos';
  static const String familyProtection = '/citizen/family-protection';
  static const String evidenceUpload = '/citizen/evidence/upload';
  
  // Deepfake
  static const String deepfakeVoice = '/deepfake/voice';
  static const String deepfakeVideo = '/deepfake/video';
  static const String deepfakeResult = '/deepfake/result';
  
  // Emergency
  static const String emergencyContact = '/emergency/contact';
  
  // Notification
  static const String registerDevice = '/device/register';
}