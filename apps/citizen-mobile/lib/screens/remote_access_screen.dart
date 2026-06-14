import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';

class RemoteAccessScreen extends StatelessWidget {
  const RemoteAccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Remote Access Alert')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const RiskMeter(score: 90, size: 120, showLabel: true),
        const SizedBox(height: 20),
        CyberCard(borderColor: AppTheme.dangerRed, child: Column(children: [
          const Icon(Icons.phishing, size: 48, color: AppTheme.dangerRed),
          const SizedBox(height: 12),
          const Text('Remote Access Detected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
          const SizedBox(height: 8),
          const Text('This is a very high risk scam pattern', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ])),
        const SizedBox(height: 20),
        const Text('Scam Pattern Detected', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _pattern('AnyDesk Session Active', 'Your device is being remotely accessed', AppTheme.dangerRed),
        _pattern('Scammer Requested OTP', 'One time password intercepted', AppTheme.dangerRed),
        _pattern('Device Screen Shared', 'Screen sharing session initiated', AppTheme.warningOrange),
        _pattern('Install Remote App', 'Fake app installation attempted', AppTheme.warningOrange),
        const SizedBox(height: 20),
        CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('How to Protect Yourself', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          _protect('1. Hang up immediately', AppTheme.safeGreen),
          _protect('2. Uninstall AnyDesk/TeamViewer', AppTheme.safeGreen),
          _protect('3. Block the number', AppTheme.safeGreen),
          _protect('4. Change your UPI PIN', AppTheme.safeGreen),
          _protect('5. Report to Cyber Crime', AppTheme.safeGreen),
        ])),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: CyberButton(label: 'Report', icon: Icons.report, color: AppTheme.dangerRed, onPressed: () => context.go('/report'))),
          const SizedBox(width: 12),
          Expanded(child: CyberButton(label: 'Call 1930', icon: Icons.phone, color: AppTheme.warningOrange, onPressed: () => context.go('/emergency'))),
        ]),
      ]),
    );
  }
  Widget _pattern(String title, String desc, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.dangerRed), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)))]),
      const SizedBox(height: 4),
      Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ]));
  Widget _protect(String text, Color color) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    Icon(Icons.check_circle, size: 16, color: color), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
  ]));
}