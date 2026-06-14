import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class CyberEmergencyScreen extends StatelessWidget {
  const CyberEmergencyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Cyber Emergency'), backgroundColor: AppTheme.dangerRed),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.5))),
          child: const Column(children: [
            Icon(Icons.emergency, size: 48, color: AppTheme.dangerRed),
            SizedBox(height: 8),
            Text('CYBER CRIME EMERGENCY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
            SizedBox(height: 4),
            Text('If you have been scammed, act immediately', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        const SizedBox(height: 20),
        _emergency('1930', 'Cyber Crime Helpline', '24/7 Hotline', AppTheme.dangerRed),
        _emergency('100', 'Police Emergency', 'Local Police', AppTheme.warningOrange),
        _emergency('1800-11-0031', 'Cyber Fraud Reporting', 'Government Portal', AppTheme.cyberBlue),
        const SizedBox(height: 20),
        const Text('Steps to Take', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _step('1', 'Stop Communication', 'Hang up immediately'),
        _step('2', 'Block the Number', 'Block scammer from calling again'),
        _step('3', 'Report to 1930', 'Call cyber crime helpline'),
        _step('4', 'File FIR Online', 'cybercrime.gov.in'),
        _step('5', 'Alert Your Bank', 'Freeze compromised accounts'),
      ]),
    );
  }
  Widget _emergency(String number, String label, String desc, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.phone, color: color, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(number, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ),
    ]));
  Widget _step(String num, String title, String desc) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
    Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(num, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)))),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ])),
  ]));
}