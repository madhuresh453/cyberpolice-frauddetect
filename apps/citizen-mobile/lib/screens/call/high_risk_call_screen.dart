import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class HighRiskCallScreen extends StatelessWidget {
  const HighRiskCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: Container(
        decoration: BoxDecoration(gradient: RadialGradient(colors: [AppTheme.dangerRed.withValues(alpha: 0.05), AppTheme.cyberBlack], radius: 1.5)),
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
            const SizedBox(height: 20),
            const Text('High Risk Detected', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
            const Text('Scam Likely', style: TextStyle(fontSize: 14, color: AppTheme.dangerRed)),
            const SizedBox(height: 30),
            const RiskMeter(score: 85, size: 140, showLabel: true),
            const SizedBox(height: 30),
            CyberCard(borderColor: AppTheme.dangerRed, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Reasons', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 12),
              _reason('Asking for OTP', 'High severity', AppTheme.dangerRed),
              _reason('Fake Bank Representative', 'High severity', AppTheme.dangerRed),
              _reason('Urgency Detected', 'High severity', AppTheme.warningOrange),
              _reason('Caller Not Verified', 'Medium severity', AppTheme.warningAmber),
            ])),
            const Spacer(),
            CyberButton(label: 'End Call & Block', icon: Icons.block, color: AppTheme.dangerRed,
              onPressed: () => context.go('/call/summary')),
            const SizedBox(height: 12),
            CyberButton(label: 'Report & Save Evidence', icon: Icons.report, color: AppTheme.warningOrange,
              onPressed: () => context.go('/report')),
            const SizedBox(height: 16),
          ])),
        ),
      ),
    );
  }

  Widget _reason(String text, String severity, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      Icon(Icons.warning_amber_rounded, size: 16, color: color),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white))),
      Text(severity, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    ]));
  }
}