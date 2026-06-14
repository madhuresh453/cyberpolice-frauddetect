import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class WhatsappProtectionScreen extends StatelessWidget {
  const WhatsappProtectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('WhatsApp Protection')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        CyberCard(child: Column(children: [
          const Row(children: [Icon(Icons.check_circle, color: AppTheme.safeGreen), SizedBox(width: 8), Text('WhatsApp Protection Active', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.safeGreen))]),
          const SizedBox(height: 8),
          Text('Monitoring messages and calls for scam patterns...', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
        ])),
        const SizedBox(height: 20),
        const Text('Monitored Channels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _channel(context, 'Unknown Number', 'I am from IRCAS...', 'Scam', AppTheme.dangerRed),
        _channel(context, 'Bank Channel', 'Your account is...', 'Suspicious', AppTheme.warningOrange),
        _channel(context, 'UPI Payment', 'Pay ₹5000 now...', 'Safe', AppTheme.safeGreen),
      ]),
    );
  }
  Widget _channel(BuildContext c, String name, String preview, String risk, Color color) {
    return GestureDetector(
      onTap: () => c.push('/whatsapp/call'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.chat, color: color)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            Text(preview, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          StatusBadge(label: risk, color: color),
        ])));
  }
}