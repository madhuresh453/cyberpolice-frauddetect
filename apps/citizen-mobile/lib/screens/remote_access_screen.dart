import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class RemoteAccessScreen extends StatelessWidget {
  const RemoteAccessScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Remote Access Detection')),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.dangerRed), padding: const EdgeInsets.all(20), child: const Column(children: [
        Icon(Icons.security, size: 48, color: AppTheme.dangerRed), SizedBox(height: 12),
        Text('Remote Access Protection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Blocking unauthorized access', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 20),
      Expanded(child: ListView(children: [
        _card(context, Icons.block, 'Remote Control Apps', 'TeamViewer, AnyDesk, RustDesk blocked'),
        _card(context, Icons.visibility_off, 'Overlay Detection', 'Suspicious overlays detected and blocked'),
        _card(context, Icons.touch_app, 'Touch Injection', 'Preventing fake touch events'),
        _card(context, Icons.admin_panel_settings, 'ADB Protection', 'USB debugging access monitored'),
      ])),
    ])),
  );
  Widget _card(BuildContext c, IconData i, String t, String s) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Row(children: [Icon(i, color: AppTheme.primaryBlue), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: Theme.of(c).textTheme.titleMedium), Text(s, style: Theme.of(c).textTheme.bodySmall)]))]));
}