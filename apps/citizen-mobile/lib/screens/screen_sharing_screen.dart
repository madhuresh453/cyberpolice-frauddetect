import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ScreenSharingScreen extends StatelessWidget {
  const ScreenSharingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Screen Sharing Detection')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.warningOrange), padding: const EdgeInsets.all(20), child: const Column(children: [
        Icon(Icons.monitor, size: 48, color: AppTheme.warningOrange), SizedBox(height: 12),
        Text('Detection Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Monitoring for screen sharing apps', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 20),
      Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Detected Apps', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12),
        _appItem('AnyDesk', 'Not detected', AppTheme.successGreen),
        _appItem('TeamViewer', 'Not detected', AppTheme.successGreen),
        _appItem('RustDesk', 'BLOCKED', AppTheme.dangerRed),
        _appItem('Screen Meet', 'Not detected', AppTheme.successGreen),
      ])),
      const SizedBox(height: 20),
      Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Protection Settings', style: Theme.of(context).textTheme.titleLarge),
        SwitchListTile(title: const Text('Auto-detect screen sharing'), value: true, onChanged: (v) {}, activeThumbColor: AppTheme.primaryBlue),
        SwitchListTile(title: const Text('Alert on overlay apps'), value: true, onChanged: (v) {}, activeThumbColor: AppTheme.primaryBlue),
        SwitchListTile(title: const Text('Block remote control apps'), value: true, onChanged: (v) {}, activeThumbColor: AppTheme.primaryBlue),
      ])),
    ]),
  );
  Widget _appItem(String name, String status, Color color) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)), child: Row(children: [
    Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.apps, color: color, size: 18)),
    const SizedBox(width: 10), Expanded(child: Text(name, style: const TextStyle(color: AppTheme.textPrimary))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))),
  ]));
}