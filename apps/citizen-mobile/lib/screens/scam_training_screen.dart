import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ScamTrainingScreen extends StatelessWidget {
  const ScamTrainingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Training Center')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.primaryBlue), padding: const EdgeInsets.all(20), child: const Column(children: [
        Icon(Icons.school, size: 48, color: AppTheme.primaryBlue), SizedBox(height: 12),
        Text('Learn to Stay Safe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Complete modules to earn certificates', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 20),
      _module(context, '1', 'Understanding Scam Calls', 'Learn to identify fraudulent calls', '80%', AppTheme.primaryBlue),
      _module(context, '2', 'SMS & WhatsApp Safety', 'Spot phishing and scam messages', '45%', AppTheme.warningOrange),
      _module(context, '3', 'UPI & Banking Security', 'Safe digital payment practices', '0%', AppTheme.textSecondary),
      _module(context, '4', 'Deepfake Awareness', 'Identify AI-generated content', '0%', AppTheme.textSecondary),
      _module(context, '5', 'Family Protection Guide', 'Protect elderly and children', '0%', AppTheme.textSecondary),
    ]),
  );
  Widget _module(BuildContext c, String num, String title, String desc, String progress, Color color) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Row(children: [
    Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(num, style: TextStyle(color: color, fontWeight: FontWeight.bold)))), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(c).textTheme.titleMedium), Text(desc, style: Theme.of(c).textTheme.bodySmall)])),
    Column(children: [Text(progress, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(height: 4), Container(width: 40, height: 4, decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: double.tryParse(progress.replaceAll('%', ''))! / 100, child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))))])
  ]));
}