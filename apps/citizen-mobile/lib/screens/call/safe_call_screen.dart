import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class SafeCallScreen extends StatelessWidget {
  const SafeCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: Container(decoration: BoxDecoration(gradient: RadialGradient(colors: [AppTheme.safeGreen.withValues(alpha: 0.05), AppTheme.cyberBlack], radius: 1.5)),
        child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          const SizedBox(height: 40),
          const Text('Safe Call', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.safeGreen)),
          const SizedBox(height: 40),
          const PulseContainer(size: 140, color: AppTheme.safeGreen, child: SizedBox(width: 80, height: 80,
            child: Icon(Icons.shield, color: AppTheme.safeGreen, size: 48))),
          const SizedBox(height: 24),
          const Text('This number appears safe', style: TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 24),
          CyberCard(borderColor: AppTheme.safeGreen, child: Column(children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Risk Score', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text('10/100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.safeGreen)),
            ]),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Status', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              Text('Very Low Risk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.safeGreen)),
            ]),
            const SizedBox(height: 12),
            _indicator('Verified Number', true), _indicator('Known Contact', true), _indicator('No Scam Reports', true), _indicator('No Fraud Keywords', true),
          ])),
          const Spacer(),
          CyberButton(label: 'Continue Call', icon: Icons.call, color: AppTheme.safeGreen,
            onPressed: () => context.go('/call/live-protection')),
          const SizedBox(height: 16),
        ]))),
      ),
    );
  }
  Widget _indicator(String text, bool ok) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
    Icon(ok ? Icons.check_circle : Icons.cancel, size: 16, color: ok ? AppTheme.safeGreen : AppTheme.textDim),
    const SizedBox(width: 8), Text(text, style: TextStyle(fontSize: 12, color: ok ? Colors.white : AppTheme.textDim)),
  ]));
}