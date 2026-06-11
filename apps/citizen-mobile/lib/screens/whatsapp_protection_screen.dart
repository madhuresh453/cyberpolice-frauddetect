import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class WhatsappProtectionScreen extends StatelessWidget {
  const WhatsappProtectionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('WhatsApp Protection')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.successGreen), padding: const EdgeInsets.all(20), child: Column(children: [
        const Icon(Icons.shield, size: 48, color: AppTheme.successGreen), const SizedBox(height: 12),
        Text('WhatsApp Protection Active', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.successGreen)),
        const Text('Analyzing messages and calls', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 20),
      Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Chat Analysis', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _chatItem(context, 'Priya Sharma', 'Urgent! Click this link...', AppTheme.dangerRed, 'SCAM'),
        _chatItem(context, 'ICICI Bank Official', 'Your account will be...', AppTheme.dangerRed, 'FAKE'),
        _chatItem(context, 'Rahul Verma', 'Meeting at 5pm', AppTheme.successGreen, 'SAFE'),
        _chatItem(context, 'Amazon Support', 'Order #12345 shipped', AppTheme.successGreen, 'SAFE'),
      ])),
      const SizedBox(height: 20),
      Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Protection Features', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _feature(Icons.chat, 'Message Scanning'), _feature(Icons.phone, 'Call Analysis'), _feature(Icons.image, 'Media Verification'), _feature(Icons.link, 'Link Scanner'), _feature(Icons.block, 'Auto Block Scammers'),
      ])),
    ]),
  );
  Widget _chatItem(BuildContext context, String name, String msg, Color c, String badge) => Container(margin: const EdgeInsets.only(bottom: 8), decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(12), child: Row(children: [
    Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.chat, color: c, size: 20)), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: Theme.of(context).textTheme.titleMedium), Text(msg, style: Theme.of(context).textTheme.bodySmall, maxLines: 1)])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text(badge, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600))),
  ]));
  Widget _feature(IconData icon, String label) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Icon(icon, color: AppTheme.primaryBlue, size: 20), const SizedBox(width: 12), Text(label, style: const TextStyle(color: AppTheme.textPrimary))]));
}