import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_1.dart';
import '../screens/onboarding/onboarding_2.dart';
import '../screens/onboarding/onboarding_3.dart';
import '../screens/permissions_screen.dart';
import '../screens/home_dashboard.dart';
import '../screens/call/incoming_call_screen.dart';
import '../screens/call/call_analysis_screen.dart';
import '../screens/call/high_risk_call_screen.dart';
import '../screens/call/medium_risk_call_screen.dart';
import '../screens/call/safe_call_screen.dart';
import '../screens/call/live_call_protection_screen.dart';
import '../screens/call/call_summary_screen.dart';
import '../screens/call/call_evidence_screen.dart';
import '../screens/sms/sms_protection_screen.dart';
import '../screens/sms/sms_scam_result_screen.dart';
import '../screens/whatsapp/whatsapp_protection_screen.dart';
import '../screens/whatsapp/whatsapp_call_screen.dart';
import '../screens/upi/upi_protection_screen.dart';
import '../screens/screen_sharing_screen.dart';
import '../screens/remote_access_screen.dart';
import '../screens/fake_apk_screen.dart';
import '../screens/link_scanner_screen.dart';
import '../screens/fraud_heatmap_screen.dart';
import '../screens/family/family_protection_screen.dart';
import '../screens/training/scam_training_screen.dart';
import '../screens/emergency/cyber_emergency_screen.dart';
import '../screens/reports/report_fraud_screen.dart';
import '../screens/reports/report_success_screen.dart';
import '../screens/settings/profile_settings_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/splash', name: 'splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding/1', name: 'onboarding1', builder: (_, __) => const Onboarding1Screen()),
    GoRoute(path: '/onboarding/2', name: 'onboarding2', builder: (_, __) => const Onboarding2Screen()),
    GoRoute(path: '/onboarding/3', name: 'onboarding3', builder: (_, __) => const Onboarding3Screen()),
    GoRoute(path: '/permissions', name: 'permissions', builder: (_, __) => const PermissionsScreen()),
    GoRoute(path: '/home', name: 'home', builder: (_, __) => const HomeDashboard()),
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
    GoRoute(path: '/sms', name: 'smsProtection', builder: (_, __) => const SmsProtectionScreen()),
    GoRoute(path: '/sms/scam-result', name: 'smsScamResult', builder: (_, __) => const SmsScamResultScreen()),
    GoRoute(path: '/whatsapp', name: 'whatsappProtection', builder: (_, __) => const WhatsappProtectionScreen()),
    GoRoute(path: '/whatsapp/call', name: 'whatsappCall', builder: (_, __) => const WhatsappCallScreen()),
    GoRoute(path: '/upi', name: 'upiProtection', builder: (_, __) => const UpiProtectionScreen()),
    GoRoute(path: '/screen-sharing', name: 'screenSharing', builder: (_, __) => const ScreenSharingScreen()),
    GoRoute(path: '/remote-access', name: 'remoteAccess', builder: (_, __) => const RemoteAccessScreen()),
    GoRoute(path: '/fake-apk', name: 'fakeApk', builder: (_, __) => const FakeApkScreen()),
    GoRoute(path: '/link-scanner', name: 'linkScanner', builder: (_, __) => const LinkScannerScreen()),
    GoRoute(path: '/heatmap', name: 'heatmap', builder: (_, __) => const FraudHeatmapScreen()),
    GoRoute(path: '/family', name: 'family', builder: (_, __) => const FamilyProtectionScreen()),
    GoRoute(path: '/training', name: 'training', builder: (_, __) => const ScamTrainingScreen()),
    GoRoute(path: '/emergency', name: 'emergency', builder: (_, __) => const CyberEmergencyScreen()),
    GoRoute(path: '/report', name: 'report', builder: (_, __) => const ReportFraudScreen()),
    GoRoute(path: '/report/success', name: 'reportSuccess', builder: (_, __) => const ReportSuccessScreen()),
    GoRoute(path: '/profile', name: 'profile', builder: (_, __) => const ProfileSettingsScreen()),
    GoRoute(path: '/settings', name: 'settings', builder: (_, __) => const ProfileSettingsScreen()),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF030712),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          const Text('Page Not Found', style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Go Home')),
        ],
      ),
    ),
  ),
);