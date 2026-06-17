import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth screens
import '../screens/splash_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/onboarding_screen.dart';

// Core screens
import '../screens/home/home_dashboard.dart';
import '../screens/home_dashboard.dart' as old_home;
import '../screens/permissions_screen.dart';
import '../screens/protection/protection_tab_screen.dart';
import '../screens/ai_investigator/ai_investigator_screen.dart';
import '../screens/safety/safety_tab_screen.dart';
import '../screens/intelligence/intelligence_tab_screen.dart';
import '../screens/profile/profile_tab_screen.dart';

// Call protection
import '../screens/call/incoming_call_screen.dart';
import '../screens/call/call_analysis_screen.dart';
import '../screens/call/high_risk_call_screen.dart';
import '../screens/call/medium_risk_call_screen.dart';
import '../screens/call/safe_call_screen.dart';
import '../screens/call/live_call_protection_screen.dart';
import '../screens/call/call_summary_screen.dart';
import '../screens/call/call_evidence_screen.dart';

// SMS
import '../screens/sms/sms_protection_screen.dart';
import '../screens/sms/sms_scam_result_screen.dart';

// WhatsApp
import '../screens/whatsapp/whatsapp_protection_screen.dart';
import '../screens/whatsapp/whatsapp_call_screen.dart';

// UPI
import '../screens/upi/upi_protection_screen.dart';

// Other
import '../screens/screen_sharing_screen.dart';
import '../screens/remote_access_screen.dart';
import '../screens/fake_apk_screen.dart';
import '../screens/link_scanner_screen.dart';
import '../screens/fraud_heatmap_screen.dart';
import '../screens/family/family_protection_screen.dart';
import '../screens/training/scam_training_screen.dart';
import '../screens/emergency/cyber_emergency_screen.dart';
import '../screens/emergency_sos_screen.dart';
import '../screens/reports/report_fraud_screen.dart';
import '../screens/reports/report_success_screen.dart';
import '../screens/report_submitted_screen.dart';
import '../screens/settings/profile_settings_screen.dart';
import '../screens/deepfake_detection_screen.dart';
import '../screens/ai_copilot_screen.dart';
import '../screens/digital_trust_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/offline_vault_screen.dart';
import '../screens/bank_protection_screen.dart';
import '../screens/live_alerts_screen.dart';
import '../screens/senior_mode_screen.dart';
import '../screens/permission_center_screen.dart';

import '../providers/auth_provider.dart';

/// GoRouter redirect logic - checks auth state
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: ref as Listenable? ?? ValueNotifier(0),
    routes: _allRoutes,
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text('Page Not Found', style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Route: ${state.uri}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8)),
              child: const Text('Go Home', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Access GoRouter directly for non-provider use
final goRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  routes: _allRoutes,
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF030712),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          const Text('Page Not Found', style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 8),
          Text('Route: ${state.uri}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8)),
            child: const Text('Go Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  ),
);

/// All application routes - single source of truth
final List<GoRoute> _allRoutes = [
  // ─── Auth Routes ───
  GoRoute(path: '/splash', name: 'splash', builder: (_, __) => const SplashScreen()),
  GoRoute(path: '/auth', name: 'auth', builder: (_, __) => const AuthScreen()),
  GoRoute(path: '/login', name: 'login', builder: (_, __) => const AuthScreen()),
  GoRoute(path: '/register', name: 'register', builder: (_, __) => const AuthScreen()),
  GoRoute(path: '/otp', name: 'otp', builder: (_, __) => const AuthScreen()),

  // ─── Onboarding ───
  GoRoute(path: '/onboarding', name: 'onboarding', builder: (_, __) => const OnboardingScreen()),
  GoRoute(path: '/onboarding/1', name: 'onboarding1', builder: (_, __) => const OnboardingScreen()),
  GoRoute(path: '/onboarding/2', name: 'onboarding2', builder: (_, __) => const OnboardingScreen()),
  GoRoute(path: '/onboarding/3', name: 'onboarding3', builder: (_, __) => const OnboardingScreen()),

  // ─── Permissions ───
  GoRoute(path: '/permissions', name: 'permissions', builder: (_, __) => const PermissionsScreen()),

  // ─── Main Home ───
  GoRoute(path: '/home', name: 'home', builder: (_, __) => const RaksaarHomeDashboard()),

  // ─── Dashboard ───
  GoRoute(path: '/dashboard', name: 'dashboard', builder: (_, __) => const RaksaarHomeDashboard()),

  // ─── Call Protection ───
  GoRoute(path: '/call/incoming', name: 'incomingCall', builder: (_, state) => IncomingCallScreen(
    phoneNumber: state.uri.queryParameters['phone'],
    callerName: state.uri.queryParameters['name'],
  )),
  GoRoute(path: '/call/analysis', name: 'callAnalysis', builder: (_, state) => CallAnalysisScreen(
    phoneNumber: state.uri.queryParameters['phone'],
  )),
  GoRoute(path: '/call/high-risk', name: 'highRiskCall', builder: (_, __) => const HighRiskCallScreen()),
  GoRoute(path: '/call/medium-risk', name: 'mediumRiskCall', builder: (_, __) => const MediumRiskCallScreen()),
  GoRoute(path: '/call/safe', name: 'safeCall', builder: (_, __) => const SafeCallScreen()),
  GoRoute(path: '/call/live-protection', name: 'liveCallProtection', builder: (_, __) => const LiveCallProtectionScreen()),
  GoRoute(path: '/call/summary', name: 'callSummary', builder: (_, __) => const CallSummaryScreen()),
  GoRoute(path: '/call/evidence', name: 'callEvidence', builder: (_, __) => const CallEvidenceScreen()),
  GoRoute(path: '/call-detection', name: 'callDetection', builder: (_, __) => const LiveCallProtectionScreen()),

  // ─── SMS Protection ───
  GoRoute(path: '/sms', name: 'smsProtection', builder: (_, __) => const SmsProtectionScreen()),
  GoRoute(path: '/sms/scam-result', name: 'smsScamResult', builder: (_, __) => const SmsScamResultScreen()),
  GoRoute(path: '/sms-detection', name: 'smsDetection', builder: (_, __) => const SmsProtectionScreen()),

  // ─── WhatsApp Protection ───
  GoRoute(path: '/whatsapp', name: 'whatsappProtection', builder: (_, __) => const WhatsappProtectionScreen()),
  GoRoute(path: '/whatsapp/call', name: 'whatsappCall', builder: (_, __) => const WhatsappCallScreen()),
  GoRoute(path: '/whatsapp-analysis', name: 'whatsappAnalysis', builder: (_, __) => const WhatsappProtectionScreen()),

  // ─── UPI Protection ───
  GoRoute(path: '/upi', name: 'upiProtection', builder: (_, __) => const UpiProtectionScreen()),
  GoRoute(path: '/upi-verification', name: 'upiVerification', builder: (_, __) => const UpiProtectionScreen()),

  // ─── Screen & Remote ───
  GoRoute(path: '/screen-sharing', name: 'screenSharing', builder: (_, __) => const ScreenSharingScreen()),
  GoRoute(path: '/remote-access', name: 'remoteAccess', builder: (_, __) => const RemoteAccessScreen()),

  // ─── APK & Link ───
  GoRoute(path: '/fake-apk', name: 'fakeApk', builder: (_, __) => const FakeApkScreen()),
  GoRoute(path: '/link-scanner', name: 'linkScanner', builder: (_, __) => const LinkScannerScreen()),

  // ─── Deepfake Detection ───
  GoRoute(path: '/deepfake', name: 'deepfake', builder: (_, __) => const DeepfakeDetectionScreen()),

  // ─── QR Scanner ───
  GoRoute(path: '/qr-scanner', name: 'qrScanner', builder: (_, __) => const QrScannerScreen()),

  // ─── Intelligence ───
  GoRoute(path: '/heatmap', name: 'heatmap', builder: (_, __) => const FraudHeatmapScreen()),
  GoRoute(path: '/digital-trust', name: 'digitalTrust', builder: (_, __) => const DigitalTrustScreen()),
  GoRoute(path: '/trust-score', name: 'trustScore', builder: (_, __) => const DigitalTrustScreen()),
  GoRoute(path: '/fraud-map', name: 'fraudMap', builder: (_, __) => const FraudHeatmapScreen()),

  // ─── AI ───
  GoRoute(path: '/ai-investigator', name: 'aiInvestigator', builder: (_, __) => const AiInvestigatorTabScreen()),
  GoRoute(path: '/ai-copilot', name: 'aiCopilot', builder: (_, __) => const AiCopilotScreen()),
  GoRoute(path: '/ai-assistant', name: 'aiAssistant', builder: (_, __) => const AiCopilotScreen()),
  GoRoute(path: '/fraud-scanner', name: 'fraudScanner', builder: (_, __) => const AiInvestigatorTabScreen()),

  // ─── Family ───
  GoRoute(path: '/family', name: 'family', builder: (_, __) => const FamilyProtectionScreen()),

  // ─── Training ───
  GoRoute(path: '/training', name: 'training', builder: (_, __) => const ScamTrainingScreen()),
  GoRoute(path: '/cyber-education', name: 'cyberEducation', builder: (_, __) => const ScamTrainingScreen()),

  // ─── Emergency ───
  GoRoute(path: '/emergency', name: 'emergency', builder: (_, __) => const CyberEmergencyScreen()),
  GoRoute(path: '/emergency-sos', name: 'emergencySos', builder: (_, __) => const EmergencySosScreen()),
  GoRoute(path: '/sos', name: 'sos', builder: (_, __) => const EmergencySosScreen()),

  // ─── Reports ───
  GoRoute(path: '/report', name: 'report', builder: (_, __) => const ReportFraudScreen()),
  GoRoute(path: '/report/success', name: 'reportSuccess', builder: (_, __) => const ReportSuccessScreen()),
  GoRoute(path: '/report-submitted', name: 'reportSubmitted', builder: (_, __) => const ReportSubmittedScreen()),
  GoRoute(path: '/report/history', name: 'reportHistory', builder: (_, __) => const ReportFraudScreen()),
  GoRoute(path: '/complaint-history', name: 'complaintHistory', builder: (_, __) => const ReportFraudScreen()),

  // ─── Profile & Settings ───
  GoRoute(path: '/profile', name: 'profile', builder: (_, __) => const ProfileSettingsScreen()),
  GoRoute(path: '/settings', name: 'settings', builder: (_, __) => const ProfileSettingsScreen()),

  // ─── Vault ───
  GoRoute(path: '/evidence-vault', name: 'evidenceVault', builder: (_, __) => const OfflineVaultScreen()),

  // ─── Notifications ───
  GoRoute(path: '/notifications', name: 'notifications', builder: (_, __) => const LiveAlertsScreen()),
  GoRoute(path: '/live-alerts', name: 'liveAlerts', builder: (_, __) => const LiveAlertsScreen()),

  // ─── Bank ───
  GoRoute(path: '/bank-protection', name: 'bankProtection', builder: (_, __) => const BankProtectionScreen()),

  // ─── Senior Mode ───
  GoRoute(path: '/senior-mode', name: 'seniorMode', builder: (_, __) => const SeniorModeScreen()),

  // ─── Permission Center ───
  GoRoute(path: '/permission-center', name: 'permissionCenter', builder: (_, __) => const PermissionCenterScreen()),

  // ─── Phone Verification ───
  GoRoute(path: '/phone-verification', name: 'phoneVerification', builder: (_, __) => const IntelligenceTabScreen()),

  // ─── Help Center ───
  GoRoute(path: '/help', name: 'help', builder: (_, __) => const ProfileSettingsScreen()),

  // ─── Catch-all fallback ───
  GoRoute(path: '/:path(.*)', name: 'not-found', builder: (_, __) => const SplashScreen()),
];