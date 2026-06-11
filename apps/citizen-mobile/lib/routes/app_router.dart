import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/sms_protection_screen.dart';
import '../screens/whatsapp_protection_screen.dart';
import '../screens/upi_protection_screen.dart';
import '../screens/screen_sharing_screen.dart';
import '../screens/remote_access_screen.dart';
import '../screens/fake_apk_screen.dart';
import '../screens/scam_link_screen.dart';
import '../screens/fraud_heatmap_screen.dart';
import '../screens/family_protection_screen.dart';
import '../screens/scam_training_screen.dart';
import '../screens/emergency_sos_screen.dart';
import '../screens/report_fraud_screen.dart';
import '../screens/report_submitted_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../screens/ai_copilot_screen.dart';
import '../screens/deepfake_detection_screen.dart';
import '../screens/offline_vault_screen.dart';
import '../screens/senior_mode_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/bank_protection_screen.dart';
import '../screens/live_alerts_screen.dart';
import '../screens/digital_trust_screen.dart';
import '../screens/call_protection_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/call-protection', builder: (_, __) => const CallProtectionScreen()),
    GoRoute(path: '/sms-protection', builder: (_, __) => const SmsProtectionScreen()),
    GoRoute(path: '/whatsapp-protection', builder: (_, __) => const WhatsappProtectionScreen()),
    GoRoute(path: '/upi-protection', builder: (_, __) => const UpiProtectionScreen()),
    GoRoute(path: '/screen-sharing', builder: (_, __) => const ScreenSharingScreen()),
    GoRoute(path: '/remote-access', builder: (_, __) => const RemoteAccessScreen()),
    GoRoute(path: '/fake-apk', builder: (_, __) => const FakeApkScreen()),
    GoRoute(path: '/scam-link', builder: (_, __) => const ScamLinkScreen()),
    GoRoute(path: '/heatmap', builder: (_, __) => const FraudHeatmapScreen()),
    GoRoute(path: '/family', builder: (_, __) => const FamilyProtectionScreen()),
    GoRoute(path: '/training', builder: (_, __) => const ScamTrainingScreen()),
    GoRoute(path: '/emergency', builder: (_, __) => const EmergencySosScreen()),
    GoRoute(path: '/report', builder: (_, __) => const ReportFraudScreen()),
    GoRoute(path: '/report-submitted', builder: (_, __) => const ReportSubmittedScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const ProfileSettingsScreen()),
    GoRoute(path: '/ai-copilot', builder: (_, __) => const AiCopilotScreen()),
    GoRoute(path: '/deepfake', builder: (_, __) => const DeepfakeDetectionScreen()),
    GoRoute(path: '/vault', builder: (_, __) => const OfflineVaultScreen()),
    GoRoute(path: '/senior-mode', builder: (_, __) => const SeniorModeScreen()),
    GoRoute(path: '/qr-scanner', builder: (_, __) => const QrScannerScreen()),
    GoRoute(path: '/bank-protection', builder: (_, __) => const BankProtectionScreen()),
    GoRoute(path: '/live-alerts', builder: (_, __) => const LiveAlertsScreen()),
    GoRoute(path: '/trust-score', builder: (_, __) => const DigitalTrustScreen()),
  ],
);