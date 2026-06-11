import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class UpiProtectionScreen extends StatelessWidget {
  const UpiProtectionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('UPI Fraud Protection')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.primaryBlue), padding: const EdgeInsets.all(20), child: const Column(children: [
        Icon(Icons.payments, size: 48, color: AppTheme.primaryBlue), SizedBox(height: 12),
        Text('UPI Protection Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Monitoring transactions', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 20),
      Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Transaction History', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12),
        _txnItem('₹15,000', 'UPI transfer', AppTheme.successGreen),
        _txnItem('₹50,000', 'Suspicious merchant', AppTheme.dangerRed),
        _txnItem('₹2,500', 'QR payment', AppTheme.successGreen),
        _txnItem('₹1,00,000', 'Unknown UPI ID', AppTheme.warningOrange),
      ])),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner), label: const Text('Scan QR to Verify'))),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, child: const Text('Check Merchant Status'))),
    ]),
  );
  Widget _txnItem(String amount, String desc, Color color) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)), child: Row(children: [
    Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.payments, color: color, size: 18)),
    const SizedBox(width: 10), Expanded(child: Text(desc, style: const TextStyle(color: AppTheme.textPrimary))), Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
  ]));
}