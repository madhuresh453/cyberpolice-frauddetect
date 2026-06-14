import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const ShieldIcon(size: 100, glow: true),
              const SizedBox(height: 40),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(colors: [AppTheme.cyberBlue, Color(0xFF0088FF)]).createShader(bounds),
                child: const Text('Welcome to\nCyberShield AI', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
              ),
              const SizedBox(height: 12),
              Text("India's Most Advanced AI Fraud Protection",
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withValues(alpha: 0.8)), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              CyberCard(
                child: Column(
                  children: [
                    FeatureRow(icon: Icons.radar, text: 'Real-Time Scam Detection', color: AppTheme.cyberBlue),
                    FeatureRow(icon: Icons.phone_in_talk, text: 'Smart Call Analysis', color: AppTheme.safeGreen),
                    FeatureRow(icon: Icons.message, text: 'SMS & WhatsApp Protection', color: AppTheme.warningOrange),
                    FeatureRow(icon: Icons.map, text: 'Designed for India', color: AppTheme.cyberBlue),
                  ],
                ),
              ),
              const Spacer(),
              CyberButton(label: 'Next', icon: Icons.arrow_forward, color: AppTheme.safeGreen,
                onPressed: () => context.go('/onboarding/2')),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}