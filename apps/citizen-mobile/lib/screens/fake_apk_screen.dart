import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';

class FakeApkScreen extends StatelessWidget {
  const FakeApkScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Fake APK Detection')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const CyberCard(borderColor: AppTheme.dangerRed, child: Column(children: [
          Icon(Icons.android, size: 48, color: AppTheme.dangerRed),
          SizedBox(height: 12),
          Text('Fake APK Detected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
          SizedBox(height: 8),
          Text('This app is attempting to install malware on your device', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ])),
        const SizedBox(height: 20),
        _apk('SP61 Bank App', 'Fake banking APK', '85%', AppTheme.dangerRed),
        _apk('UPI Pay Plus', 'Fake UPI transaction app', '90%', AppTheme.dangerRed),
        _apk('WhatsApp Mod', 'Fake WhatsApp application', '70%', AppTheme.warningOrange),
        const SizedBox(height: 20),
        CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('How to stay safe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          _tip('Always install from Play Store only'),
          _tip('Enable Google Play Protect'),
          _tip('Never accept APKs from unknown sources'),
          _tip('Check app permissions carefully'),
        ])),
        const SizedBox(height: 20),
        CyberButton(label: 'Report Fake App', icon: Icons.report, color: AppTheme.dangerRed, onPressed: () => context.go('/report')),
      ]),
    );
  }
  Widget _apk(String name, String desc, String risk, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.android, color: color, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ])),
      StatusBadge(label: risk, color: color),
    ]));
  Widget _tip(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    const Icon(Icons.check_circle, size: 16, color: AppTheme.safeGreen), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white))),
  ]));
}