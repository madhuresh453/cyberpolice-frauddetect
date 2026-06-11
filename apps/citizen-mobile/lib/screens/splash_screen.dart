import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) ref.read(authProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated || next.status == AuthStatus.unauthenticated) {
        if (mounted) context.go(next.status == AuthStatus.authenticated ? '/home' : '/onboarding');
      }
    });
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          children: [
            // Animated background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [AppTheme.primaryBlue.withValues(alpha: 0.15 * _controller.value), AppTheme.background],
                    radius: 1.5,
                  ),
                ),
              ),
            ),
            // Shield glow effect
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 0, right: 0,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.shield_outlined, size: 60, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 24),
                      const Text('CYBERSHIELD', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4, color: AppTheme.primaryBlue)),
                      const SizedBox(height: 8),
                      const Text('AI', style: TextStyle(fontSize: 20, color: AppTheme.primaryBlue, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ),
            // Tagline
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.12,
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: DefaultTextStyle(
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        child: AnimatedTextKit(
                          animatedTexts: [TypewriterAnimatedText('Be Aware. Be Safe.', speed: const Duration(milliseconds: 100))],
                          repeatForever: false, isRepeatingAnimation: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.local_police, size: 16, color: AppTheme.textSecondary), SizedBox(width: 8), Text('In partnership with Police', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.05,
              left: 0, right: 0,
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue.withValues(alpha: 0.6))))),
            ),
          ],
        ),
      ),
    );
  }
}