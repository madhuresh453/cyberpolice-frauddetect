import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class LiveAlertsScreen extends StatelessWidget {
  const LiveAlertsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Live Alerts')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.dangerRed), padding: const EdgeInsets.all(20), child: const Column(children: [
        Icon(Icons.notifications_active, size: 48, color: AppTheme.dangerRed), SizedBox(height: 12),
        Text('3 Active Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ])),
      const SizedBox(height: 20),
      _alertItem(Icons.phone, 'High Risk Call', '+91 98765 43210 attempted scam call', AppTheme.dangerRed, '2 min ago'),
      _alertItem(Icons.sms, 'SMS Scam', 'Fake KYC message detected and blocked', AppTheme.warningOrange, '15 min ago'),
      _alertItem(Icons.shield, 'Suspicious App', 'Photo Editor Pro has malware', AppTheme.warningOrange, '1 hour ago'),
      _alertItem(Icons.chat, 'WhatsApp Scam', 'Fraudulent message from unknown number', AppTheme.successGreen, '2 hours ago - Resolved'),
    ]),
  );
  Widget _alertItem(IconData icon, String title, String desc, Color color, String time) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Row(children: [
    Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
    const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)), Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)), Text(time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10))])),
    Icon(Icons.chevron_right, color: color, size: 20),
  ]));
}