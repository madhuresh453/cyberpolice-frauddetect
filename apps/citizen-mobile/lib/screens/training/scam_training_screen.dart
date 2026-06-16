import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ScamTrainingScreen extends StatelessWidget {
  const ScamTrainingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Scam Awareness Training')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Protect Yourself with Knowledge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _lesson(Icons.phone, 'OTP Scam Awareness', 'Learn how scammers steal OTPs', 5, 5, AppTheme.dangerRed),
        _lesson(Icons.email, 'Phishing Email Detection', 'Identify fake emails and links', 5, 5, AppTheme.warningOrange),
        _lesson(Icons.payments, 'UPI Scam Prevention', 'Safe online payment practices', 5, 5, AppTheme.safeGreen),
        _lesson(Icons.phishing, 'Social Engineering', 'How scammers manipulate people', 5, 5, AppTheme.cyberBlue),
        _lesson(Icons.chat, 'WhatsApp Scam Patterns', 'Identify WhatsApp scam messages', 5, 5, AppTheme.warningOrange),
        _lesson(Icons.android, 'Fake App Detection', 'How to spot fake apps', 5, 5, AppTheme.dangerRed),
        _lesson(Icons.vpn_key, 'Digital Literacy', 'Basics of online security', 5, 5, AppTheme.cyberBlue),
      ]),
    );
  }
  Widget _lesson(IconData icon, String title, String desc, int completed, int total, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: LinearProgressIndicator(value: completed / total, backgroundColor: AppTheme.borderColor, valueColor: AlwaysStoppedAnimation(color), minHeight: 3)),
            const SizedBox(width: 8),
            Text('$completed/$total', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ]),
        ])),
      ]));
  }
}