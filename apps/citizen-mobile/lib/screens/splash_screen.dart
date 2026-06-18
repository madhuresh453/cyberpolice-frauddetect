import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../core/config/app_config.dart';
import '../core/permission_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  Timer? _navigationTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _controller.forward();

    // SAFETY: Hard timeout at 3 seconds – NEVER allow splash freeze
    _navigationTimer = Timer(AppConfig.maxSplashDuration, _navigateToNext);
  }

  Future<void> _navigateToNext() async {
    if (_navigated || !mounted) return;
    _navigated = true;

    try {
      // Step 1: Check all permissions
      final permissions = await RaksaarPermissionManager.checkAllPermissions();
      final allMandatory = permissions['allMandatoryGranted'] == true;

      if (!allMandatory) {
        // Navigate to permission center if any mandatory permission is missing
        if (mounted) context.go('/permissions');
        return;
      }

      // Step 2: All permissions granted - go to onboarding then auth
      if (mounted) context.go('/onboarding/1');
    } catch (e) {
      debugPrint('[Splash] Permission check failed: $e — fallback to permissions');
      if (mounted) {
        try {
          context.go('/permissions');
        } catch (_) {
          debugPrint('[Splash] Fallback navigation failed');
        }
      }
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppTheme.cyberBlue.withValues(
                    alpha: 0.12 * _glowAnim.value),
                AppTheme.cyberBlack
              ],
              radius: 1.5,
            ),
          ),
          child: Stack(
            children: [
              ...List.generate(
                20,
                (i) => Positioned(
                  left: (i * 37.0) % MediaQuery.of(context).size.width,
                  top: (i * 53.0) % MediaQuery.of(context).size.height,
                  child: Opacity(
                    opacity: 0.3 + (0.7 * ((i % 5) / 5.0)),
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppTheme.cyberBlue),
                    ),
                  ),
                ),
              ),
              Center(
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Opacity(
                    opacity: _fadeAnim.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.cyberBlue
                                    .withValues(alpha: 0.8),
                                width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.cyberBlue.withValues(
                                      alpha: 0.3 * _glowAnim.value),
                                  blurRadius: 40,
                                  spreadRadius: 10),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.cyberBlue
                                      .withValues(alpha: 0.3),
                                  width: 1),
                            ),
                            child: const Icon(Icons.shield_outlined,
                                size: 48, color: AppTheme.cyberBlue),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: [
                                  AppTheme.cyberBlue,
                                  Color(0xFF0088FF)
                                ],
                              ).createShader(bounds),
                          child: const Text(
                            'RAKSAAR',
                            style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConfig.appTagline,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.cyberBlue
                                  .withValues(alpha: 0.8),
                              letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _fadeAnim.value,
                  child: Column(
                    children: [
                      const Text('Checking permissions...',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      Text('National Cyber Safety Platform',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary
                                  .withValues(alpha: 0.7))),
                      const SizedBox(height: 4),
                      Text('Government of India Initiative',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary
                                  .withValues(alpha: 0.5))),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.cyberBlue.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}