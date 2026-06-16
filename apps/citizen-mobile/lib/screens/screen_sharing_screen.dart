import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';

class ScreenSharingScreen extends StatelessWidget {
  const ScreenSharingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Screen Sharing Detection')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const CyberCard(borderColor: AppTheme.dangerRed, child: Column(children: [
          Icon(Icons.screen_share, size: 48, color: AppTheme.dangerRed),
          SizedBox(height: 12),
          Text('Screen Sharing Detected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
          SizedBox(height: 8),
          Text('An app is attempting to capture your screen', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ])),
        const SizedBox(height: 20),
        const Text('Active Screen Sharing Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _session('AnyDesk', 'Screen captured for 2 min 15 sec', AppTheme.dangerRed, 'Active'),
        _session('TeamViewer', 'Attempted to install', AppTheme.warningOrange, 'Blocked'),
        _session('Zoho Assist', 'Session ended 5 min ago', AppTheme.safeGreen, 'Ended'),
        const SizedBox(height: 20),
        CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Protection Tips', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          _tip('Never share your screen with strangers'),
          _tip('Report any suspicious remote access apps'),
          _tip('Disable unknown app permissions'),
        ])),
        const SizedBox(height: 20),
        CyberButton(label: 'Block All Remote Access', icon: Icons.block, color: AppTheme.dangerRed, onPressed: () => context.go('/remote-access')),
      ]),
    );
  }
  Widget _session(String name, String desc, Color color, String label) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.screen_share, color: color, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(children: [
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ])),
      StatusBadge(label: label, color: color),
    ]));
  Widget _tip(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.warningOrange), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
  ]));
}