import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Center(child: Text('How It Protects You', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
              const SizedBox(height: 8),
              Center(child: Text('Advanced AI-powered protection workflow', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withValues(alpha: 0.8)))),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _buildStep(1, 'Listens to calls', 'AI monitors scam patterns in real-time', Icons.hearing, AppTheme.cyberBlue),
                    _buildStep(2, 'Detects scam behavior', 'NLP model analyzes speech patterns', Icons.psychology, AppTheme.safeGreen),
                    _buildStep(3, 'Verifies phone numbers', 'Cross-checks national fraud databases', Icons.verified_user, AppTheme.warningOrange),
                    _buildStep(4, 'Blocks & alerts', 'Shows instant warning on screen', Icons.shield, AppTheme.dangerRed),
                    _buildStep(5, 'Reports fraud', 'Automatically generates evidence package', Icons.assessment, AppTheme.cyberBlue),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _techChip('Speech Recognition'), _techChip('NLP'), _techChip('Risk Engine'), _techChip('Fraud DB'),
                ],
              ),
              const SizedBox(height: 16),
              CyberButton(label: 'Next', icon: Icons.arrow_forward, color: AppTheme.safeGreen,
                onPressed: () => context.go('/onboarding/3')),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int num, String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
            child: Center(child: Text('$num', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.borderColor)),
        child: Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
      ),
    );
  }
}