import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/emergency_sos_screen.dart';
import 'screens/call_monitor_screen.dart';
import 'screens/sms_scanner_screen.dart';
import 'screens/whatsapp_protection_screen.dart';
import 'screens/link_scanner_screen.dart';
import 'screens/upi_protection_screen.dart';
import 'screens/family_protection_screen.dart';
import 'screens/fraud_history_screen.dart';
import 'screens/ai_copilot_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/blocked_numbers_screen.dart';
import 'screens/trust_checker_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/emergency', builder: (context, state) => const EmergencySosScreen()),
      GoRoute(path: '/call-monitor', builder: (context, state) => const CallMonitorScreen()),
      GoRoute(path: '/sms-scanner', builder: (context, state) => const SmsScannerScreen()),
      GoRoute(path: '/whatsapp', builder: (context, state) => const WhatsAppProtectionScreen()),
      GoRoute(path: '/link-scanner', builder: (context, state) => const LinkScannerScreen()),
      GoRoute(path: '/upi-protection', builder: (context, state) => const UpiProtectionScreen()),
      GoRoute(path: '/family', builder: (context, state) => const FamilyProtectionScreen()),
      GoRoute(path: '/history', builder: (context, state) => const FraudHistoryScreen()),
      GoRoute(path: '/ai-copilot', builder: (context, state) => const AiCopilotScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/blocked', builder: (context, state) => const BlockedNumbersScreen()),
      GoRoute(path: '/trust-checker', builder: (context, state) => const TrustCheckerScreen()),
    ],
  );
});

class CyberShieldApp extends ConsumerWidget {
  const CyberShieldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CyberShield AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        brightness: Brightness.light,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF42A5F5),
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}