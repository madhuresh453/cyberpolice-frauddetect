import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class SeniorModeScreen extends StatelessWidget {
  const SeniorModeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Senior Mode')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      Container(decoration: AppTheme.neonBorder(color: const Color(0xFFEC4899)), padding: const EdgeInsets.all(30), child: const Column(children: [
        Icon(Icons.elderly, size: 60, color: Color(0xFFEC4899)), SizedBox(height: 16),
        Text('Senior Citizen Mode', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8), Text('Simplified interface for elderly users', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
        SizedBox(height: 20),
        Text('✓ Large Fonts', style: TextStyle(color: AppTheme.successGreen, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8), Text('✓ Voice Assistance', style: TextStyle(color: AppTheme.successGreen, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8), Text('✓ Auto Fraud Alerts', style: TextStyle(color: AppTheme.successGreen, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8), Text('✓ One-Tap SOS', style: TextStyle(color: AppTheme.successGreen, fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8), Text('✓ Family Notifications', style: TextStyle(color: AppTheme.successGreen, fontSize: 16, fontWeight: FontWeight.w500)),
      ])),
      const SizedBox(height: 30),
      SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () {}, child: const Text('Enable Senior Mode', style: TextStyle(fontSize: 18)))),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, height: 56, child: OutlinedButton(onPressed: () {}, child: const Text('Try Voice Tutorial', style: TextStyle(fontSize: 16)))),
    ]),
  );
}