import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class MediumRiskCallScreen extends StatelessWidget {
  const MediumRiskCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: Container(decoration: BoxDecoration(gradient: RadialGradient(colors: [AppTheme.warningOrange.withValues(alpha: 0.05), AppTheme.cyberBlack], radius: 1.5)),
        child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          const SizedBox(height: 20),
          const Text('Suspicious Call', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.warningOrange)),
          const Text('Proceed With Caution', style: TextStyle(fontSize: 14, color: AppTheme.warningOrange)),
          const SizedBox(height: 30),
          const RiskMeter(score: 45, size: 140, showLabel: true),
          const SizedBox(height: 30),
          CyberCard(borderColor: AppTheme.warningOrange, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Reasons', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            _reason('Banking Keywords Detected', AppTheme.warningOrange),
            _reason('Verification Request Detected', AppTheme.warningOrange),
            _reason('Unknown Number', AppTheme.warningAmber),
          ])),
          const Spacer(),
          Row(children: [
            Expanded(child: CyberButton(label: 'Continue Call', color: AppTheme.warningOrange, onPressed: () => context.go('/call/live-protection'))),
            const SizedBox(width: 12),
            Expanded(child: CyberButton(label: 'Report Number', color: AppTheme.cyberBlue, onPressed: () => context.go('/report'))),
          ]),
          const SizedBox(height: 16),
        ]))),
      ),
    );
  }
  Widget _reason(String text, Color color) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    Icon(Icons.info_outline, size: 16, color: color), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 13, color: Colors.white)) ]));
}