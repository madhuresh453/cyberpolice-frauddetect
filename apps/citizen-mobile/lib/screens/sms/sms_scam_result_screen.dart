import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class SmsScamResultScreen extends StatelessWidget {
  const SmsScamResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: Container(
        decoration: BoxDecoration(gradient: RadialGradient(colors: [AppTheme.dangerRed.withValues(alpha: 0.05), AppTheme.cyberBlack], radius: 1.5)),
        child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          const SizedBox(height: 20),
          const Icon(Icons.warning_rounded, size: 48, color: AppTheme.dangerRed),
          const SizedBox(height: 16),
          const Text('Scam SMS Detected', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Text('This message is identified as a scam.', style: TextStyle(color: AppTheme.dangerRed, fontSize: 13)),
          ),
          const SizedBox(height: 24),
          CyberCard(borderColor: AppTheme.dangerRed, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Risk Factors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            _factor('Contains suspicious link'),
            _factor('Requests personal information'),
            _factor('Reported by community'),
            _factor('Fake bank impersonation'),
          ])),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(children: [const Text('92%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)), const Text('AI Confidence', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]),
            Container(width: 1, height: 40, color: AppTheme.borderColor),
            Column(children: [const Text('High', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)), const Text('Threat Level', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]),
          ]),
          const Spacer(),
          Row(children: [
            Expanded(child: CyberButton(label: 'Delete & Block', icon: Icons.delete, color: AppTheme.dangerRed, onPressed: () => context.go('/home'))),
            const SizedBox(width: 12),
            Expanded(child: CyberButton(label: 'Report SMS', icon: Icons.report, color: AppTheme.warningOrange, onPressed: () => context.go('/report'))),
          ]),
          const SizedBox(height: 16),
        ]))),
      ),
    );
  }
  Widget _factor(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.dangerRed), const SizedBox(width: 8),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white))),
  ]));
}