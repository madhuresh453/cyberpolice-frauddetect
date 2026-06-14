import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

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
              const Text('Your Safety,\nOur Priority', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
              const SizedBox(height: 40),
              PulseContainer(
                size: 140,
                color: AppTheme.safeGreen,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.safeGreen.withValues(alpha: 0.15), border: Border.all(color: AppTheme.safeGreen.withValues(alpha: 0.5), width: 2)),
                  child: const Icon(Icons.lock_outline, size: 48, color: AppTheme.safeGreen),
                ),
              ),
              const SizedBox(height: 40),
              CyberCard(
                child: Column(
                  children: [
                    _trustItem('100% Secure', 'Bank-grade encryption for all your data', Icons.security, AppTheme.safeGreen),
                    const Divider(color: AppTheme.borderColor, height: 24),
                    _trustItem('Built in India', 'Designed for Indian citizens', Icons.map, AppTheme.cyberBlue),
                    const Divider(color: AppTheme.borderColor, height: 24),
                    _trustItem('Privacy First', 'No unnecessary data storage', Icons.lock_outline, AppTheme.warningOrange),
                    const Divider(color: AppTheme.borderColor, height: 24),
                    _trustItem('Zero Trust', 'Verify everything before trusting', Icons.verified_user, AppTheme.dangerRed),
                  ],
                ),
              ),
              const Spacer(),
              CyberButton(label: 'Get Started', icon: Icons.rocket_launch, color: AppTheme.safeGreen,
                onPressed: () => context.go('/permissions')),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trustItem(String title, String desc, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}