import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class UpiProtectionScreen extends StatelessWidget {
  const UpiProtectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('UPI Protection')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        CyberCard(borderColor: AppTheme.safeGreen, child: Column(children: [
          const Row(children: [Icon(Icons.shield, color: AppTheme.safeGreen), SizedBox(width: 8), Text('UPI Protection Active', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.safeGreen))]),
          const SizedBox(height: 8),
          Text('Monitoring UPI transactions for fraud patterns', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
        ])),
        const SizedBox(height: 20),
        const Text('Suspicious Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _transaction(context, 'Payment to 9876543210', '₹15,000', 'High Risk', AppTheme.dangerRed, 'Fake KYC scam'),
        _transaction(context, 'Payment to 9998887777', '₹5,000', 'Medium Risk', AppTheme.warningOrange, 'Suspicious merchant'),
        _transaction(context, 'Payment to SBI Bank', '₹2,000', 'Safe', AppTheme.safeGreen, 'Verified bank'),
      ]),
    );
  }
  Widget _transaction(BuildContext c, String title, String amount, String risk, Color color, String reason) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(reason, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          StatusBadge(label: risk, color: color),
        ]),
      ]),
    );
  }
}