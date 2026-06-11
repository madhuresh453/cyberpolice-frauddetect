import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class FakeApkScreen extends StatelessWidget {
  const FakeApkScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('APK Scanner')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.warningOrange), padding: const EdgeInsets.all(20), child: const Column(children: [
        Icon(Icons.android, size: 48, color: AppTheme.warningOrange), SizedBox(height: 12),
        Text('App Scanner Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Scanning installed applications', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.security), label: const Text('Scan All Apps'))),
      const SizedBox(height: 16),
      Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Detected Threats', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12),
        _appItem('Photo Editor Pro', 'Malware detected', AppTheme.dangerRed),
        _appItem('Fast Cleaner', 'Suspicious permissions', AppTheme.warningOrange),
        _appItem('WhatsApp', 'Verified', AppTheme.successGreen),
      ])),
    ]),
  );
  Widget _appItem(String name, String status, Color color) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)), child: Row(children: [
    Icon(Icons.android, color: color, size: 20), const SizedBox(width: 10), Expanded(child: Text(name, style: const TextStyle(color: AppTheme.textPrimary))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))),
  ]));
}