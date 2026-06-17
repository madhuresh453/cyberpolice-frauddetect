import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes/raksaar_theme.dart';
import 'providers/app_providers.dart';
import 'core/permission_manager.dart';
import 'screens/permissions/permission_gate_screen.dart';
import 'screens/home/home_dashboard.dart';
import 'screens/protection/protection_tab_screen.dart';
import 'screens/ai_investigator/ai_investigator_screen.dart';
import 'screens/safety/safety_tab_screen.dart';
import 'screens/intelligence/intelligence_tab_screen.dart';
import 'screens/profile/profile_tab_screen.dart';

class RaksaarApp extends ConsumerWidget {
  final List<String> startupErrors;

  const RaksaarApp({super.key, this.startupErrors = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final permissionsGranted = ref.watch(permissionsGrantedProvider);

    return MaterialApp(
      title: 'RAKSAAR',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: RaksaarTheme.lightTheme,
      darkTheme: RaksaarTheme.darkTheme,
      home: permissionsGranted
          ? AppShell(startupErrors: startupErrors)
          : PermissionGateScreen(startupErrors: startupErrors),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3)),
          ),
          child: child!,
        );
      },
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  final List<String> startupErrors;
  const AppShell({super.key, this.startupErrors = const []});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _showStartupWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.startupErrors.isNotEmpty) {
      Future.microtask(() {
        if (mounted) setState(() => _showStartupWarning = true);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _revalidatePermissions();
    }
  }

  Future<void> _revalidatePermissions() async {
    try {
      final allGranted =
          await RaksaarPermissionManager.hasAllCriticalPermissions();
      if (!mounted) return;
      if (!allGranted) {
        ref.read(permissionsGrantedProvider.notifier).deny();
      }
    } catch (e) {
      debugPrint('[AppShell] Permission recheck failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 6-tab RAKSAAR layout: Home, Protection, AI Investigator, Safety, Intelligence, Profile
    final screens = <Widget>[
      RaksaarHomeDashboard(startupErrors: widget.startupErrors),
      const ProtectionTabScreen(),
      const AiInvestigatorTabScreen(),
      const SafetyTabScreen(),
      const IntelligenceTabScreen(),
      const ProfileTabScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: screens),
          if (_showStartupWarning && widget.startupErrors.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  color: Colors.orange.withValues(alpha: 0.9),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.startupErrors.length} service(s) failed to initialize',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showStartupWarning = false),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Protection'),
          NavigationDestination(
              icon: Icon(Icons.psychology_outlined),
              selectedIcon: Icon(Icons.psychology),
              label: 'AI Scan'),
          NavigationDestination(
              icon: Icon(Icons.emergency_outlined),
              selectedIcon: Icon(Icons.emergency),
              label: 'Safety'),
          NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Intel'),
          NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}