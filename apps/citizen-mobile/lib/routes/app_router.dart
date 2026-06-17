import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth screens (OUTSIDE shell - no bottom nav)
import '../screens/splash_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/permissions_screen.dart';

// Tab screens
import '../screens/home/home_dashboard.dart';
import '../screens/settings/profile_settings_screen.dart';
import '../screens/ai_investigator/ai_investigator_screen.dart';
import '../screens/safety/safety_tab_screen.dart';

// Feature screens (INSIDE shell branches - keep bottom nav)
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
import '../screens/emergency_sos_screen.dart';
import '../screens/reports/report_fraud_screen.dart';
import '../screens/reports/report_success_screen.dart';
import '../screens/report_submitted_screen.dart';
import '../screens/deepfake_detection_screen.dart';
import '../screens/ai_copilot_screen.dart';
import '../screens/digital_trust_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/offline_vault_screen.dart';
import '../screens/bank_protection_screen.dart';
import '../screens/live_alerts_screen.dart';
import '../screens/senior_mode_screen.dart';
import '../screens/permission_center_screen.dart';
import '../screens/intelligence/intelligence_tab_screen.dart';
import '../screens/protection/protection_tab_screen.dart';
import '../screens/live_call_detection_screen.dart';
import '../screens/live_call_analysis_screen.dart';
import '../screens/call_protection_screen.dart';
import '../screens/home_dashboard.dart';
import '../screens/family/family_dashboard.dart';
import '../screens/monitor/monitor_center.dart';

/// AppShell - persistent bottom navigation using StatefulNavigationShell.
/// Never disappears - all app screens render inside this shell.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'AI Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.emergency_outlined),
            selectedIcon: Icon(Icons.emergency),
            label: 'SOS',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Root navigator key for GoRouter
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter with StatefulShellRoute for persistent bottom navigation.
/// Auth/splash routes are outside shell (no bottom nav).
/// ALL feature routes are inside shell branches (bottom nav ALWAYS visible).
final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  routes: [
    // ─── AUTH ROUTES (OUTSIDE shell - no bottom nav) ───
    GoRoute(path: '/splash', name: 'splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/auth', name: 'auth', builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/login', name: 'login', builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/register', name: 'register', builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/otp', name: 'otp', builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/onboarding', name: 'onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/onboarding/1', name: 'onboarding1', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/onboarding/2', name: 'onboarding2', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/onboarding/3', name: 'onboarding3', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/permissions', name: 'permissions', builder: (_, __) => const PermissionsScreen()),

    // ─── MAIN SHELL (all app screens WITH bottom nav) ───
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        // ═══ TAB 0: HOME ═══
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (_, __) => const RaksaarHomeDashboard(),
              routes: [
                GoRoute(path: 'protection', name: 'home-protection', builder: (_, __) => const ProtectionTabScreen()),
                GoRoute(path: 'intelligence', name: 'home-intelligence', builder: (_, __) => const IntelligenceTabScreen()),
                GoRoute(path: 'safety', name: 'home-safety', builder: (_, __) => const SafetyTabScreen()),
                GoRoute(path: 'dashboard', name: 'home-dashboard', builder: (_, __) => const HomeDashboard()),
              ],
            ),
          ],
        ),

        // ═══ TAB 1: AI SCAN ═══
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai-scan',
              name: 'aiScan',
              builder: (_, __) => const AiInvestigatorTabScreen(),
              routes: [
                GoRoute(path: 'copilot', name: 'ai-copilot', builder: (_, __) => const AiCopilotScreen()),
                GoRoute(path: 'investigator', name: 'ai-investigator', builder: (_, __) => const AiInvestigatorTabScreen()),
              ],
            ),
          ],
        ),

        // ═══ TAB 2: SCANNER ═══
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scanner',
              name: 'scanner',
              builder: (_, __) => const AiInvestigatorTabScreen(),
              routes: [
                GoRoute(path: 'link', name: 'link-scanner', builder: (_, __) => const LinkScannerScreen()),
                GoRoute(path: 'qr', name: 'qr-scanner', builder: (_, __) => const QrScannerScreen()),
                GoRoute(path: 'deepfake', name: 'deepfake', builder: (_, __) => const DeepfakeDetectionScreen()),
              ],
            ),
          ],
        ),

        // ═══ TAB 3: SOS ═══
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sos-tab',
              name: 'sosTab',
              builder: (_, __) => const SafetyTabScreen(),
              routes: [
                GoRoute(path: 'sos', name: 'sos', builder: (_, __) => const EmergencySosScreen()),
                GoRoute(path: 'emergency', name: 'emergency', builder: (_, __) => const CyberEmergencyScreen()),
              ],
            ),
          ],
        ),

        // ═══ TAB 4: PROFILE ═══
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (_, __) => const ProfileSettingsScreen(),
              routes: [
                GoRoute(path: 'settings', name: 'settings', builder: (_, __) => const ProfileSettingsScreen()),
                GoRoute(path: 'vault', name: 'evidence-vault', builder: (_, __) => const OfflineVaultScreen()),
                GoRoute(path: 'notifications', name: 'notifications', builder: (_, __) => const LiveAlertsScreen()),
                GoRoute(path: 'permission-center', name: 'permission-center', builder: (_, __) => const PermissionCenterScreen()),
                GoRoute(path: 'senior', name: 'senior-mode', builder: (_, __) => const SeniorModeScreen()),
                GoRoute(path: 'help', name: 'help', builder: (_, __) => const ProfileSettingsScreen()),
              ],
            ),
          ],
        ),
      ],
    ),

    // ─── FEATURE ROUTES (inside shell, accessible from any tab) ───
    // These are accessed via context.push() and keep bottom nav visible
    // because GoRouter resolves them relative to the current shell branch

    // Call Protection
    GoRoute(path: '/call/incoming', name: 'incomingCall', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => IncomingCallScreen(
        phoneNumber: state.uri.queryParameters['phone'],
        callerName: state.uri.queryParameters['name'],
      )),
    GoRoute(path: '/call/analysis', name: 'callAnalysis', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => CallAnalysisScreen(phoneNumber: state.uri.queryParameters['phone'])),
    GoRoute(path: '/call/high-risk', name: 'highRiskCall', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const HighRiskCallScreen()),
    GoRoute(path: '/call/medium-risk', name: 'mediumRiskCall', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const MediumRiskCallScreen()),
    GoRoute(path: '/call/safe', name: 'safeCall', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SafeCallScreen()),
    GoRoute(path: '/call/live-protection', name: 'liveCallProtection', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const LiveCallProtectionScreen()),
    GoRoute(path: '/call/summary', name: 'callSummary', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const CallSummaryScreen()),
    GoRoute(path: '/call/evidence', name: 'callEvidence', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const CallEvidenceScreen()),
    GoRoute(path: '/call-detection', name: 'callDetection', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const LiveCallProtectionScreen()),

    // SMS Protection
    GoRoute(path: '/sms', name: 'smsProtection', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SmsProtectionScreen()),
    GoRoute(path: '/sms/scam-result', name: 'smsScamResult', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SmsScamResultScreen()),
    GoRoute(path: '/sms-detection', name: 'smsDetection', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SmsProtectionScreen()),

    // WhatsApp
    GoRoute(path: '/whatsapp', name: 'whatsappProtection', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const WhatsappProtectionScreen()),
    GoRoute(path: '/whatsapp/call', name: 'whatsappCall', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const WhatsappCallScreen()),
    GoRoute(path: '/whatsapp-analysis', name: 'whatsappAnalysis', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const WhatsappProtectionScreen()),

    // UPI
    GoRoute(path: '/upi', name: 'upiProtection', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const UpiProtectionScreen()),
    GoRoute(path: '/upi-verification', name: 'upiVerification', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const UpiProtectionScreen()),

    // Screen & Remote
    GoRoute(path: '/screen-sharing', name: 'screenSharing', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ScreenSharingScreen()),
    GoRoute(path: '/remote-access', name: 'remoteAccess', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const RemoteAccessScreen()),

    // APK & Link
    GoRoute(path: '/fake-apk', name: 'fakeApk', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const FakeApkScreen()),

    // Intelligence
    GoRoute(path: '/heatmap', name: 'heatmap', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const FraudHeatmapScreen()),
    GoRoute(path: '/digital-trust', name: 'digitalTrust', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const DigitalTrustScreen()),
    GoRoute(path: '/trust-score', name: 'trustScore', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const DigitalTrustScreen()),
    GoRoute(path: '/fraud-map', name: 'fraudMap', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const FraudHeatmapScreen()),

    // Family
    GoRoute(path: '/family', name: 'family', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const FamilyProtectionScreen()),
    GoRoute(path: '/family-dashboard', name: 'familyDashboard', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const FamilyDashboard()),

    // Training
    GoRoute(path: '/training', name: 'training', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ScamTrainingScreen()),
    GoRoute(path: '/cyber-education', name: 'cyberEducation', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ScamTrainingScreen()),

    // Reports
    GoRoute(path: '/report', name: 'report', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ReportFraudScreen()),
    GoRoute(path: '/report/success', name: 'reportSuccess', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ReportSuccessScreen()),
    GoRoute(path: '/report-submitted', name: 'reportSubmitted', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ReportSubmittedScreen()),
    GoRoute(path: '/report/history', name: 'reportHistory', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ReportFraudScreen()),
    GoRoute(path: '/complaint-history', name: 'complaintHistory', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ReportFraudScreen()),

    // Bank
    GoRoute(path: '/bank-protection', name: 'bankProtection', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const BankProtectionScreen()),

    // Monitor
    GoRoute(path: '/monitor', name: 'monitor', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const MonitorCenter()),

    // Alerts
    GoRoute(path: '/live-alerts', name: 'liveAlerts', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const LiveAlertsScreen()),

    // Phone Verification (uses IntelligenceTabScreen)
    GoRoute(path: '/phone-verification', name: 'phoneVerification', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const IntelligenceTabScreen()),

    // Call protection (legacy)
    GoRoute(path: '/call-protection', name: 'callProtection', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const CallProtectionScreen()),
    GoRoute(path: '/live-call', name: 'liveCall', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const LiveCallDetectionScreen()),
    GoRoute(path: '/live-call-analysis', name: 'liveCallAnalysis', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const LiveCallAnalysisScreen()),

    // Catch-all fallback
    GoRoute(path: '/:path(.*)', name: 'not-found', parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SplashScreen()),
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