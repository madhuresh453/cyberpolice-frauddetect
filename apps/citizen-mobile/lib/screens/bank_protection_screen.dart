import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class BankProtectionScreen extends StatelessWidget {
  const BankProtectionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Bank Protection')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.primaryBlue), padding: const EdgeInsets.all(20), child: const Column(children: [
        Icon(Icons.account_balance, size: 48, color: AppTheme.primaryBlue), SizedBox(height: 12),
        Text('Bank Account Protection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Verify and protect your accounts', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 20),
      _card(Icons.check_circle, 'Verify Account', 'Check if a bank account is legitimate', AppTheme.primaryBlue, () {}),
      _card(Icons.block, 'Freeze Account', 'Request to freeze a suspicious account', AppTheme.dangerRed, () {}),
      _card(Icons.report, 'Fraud Complaint', 'File a bank fraud complaint', AppTheme.warningOrange, () {}),
      _card(Icons.history, 'Transaction History', 'View flagged transactions', AppTheme.successGreen, () {}),
    ]),
  );
  Widget _card(IconData icon, String title, String desc, Color color, VoidCallback onTap) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: AppTheme.glassCard(), child: ListTile(
    leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
    title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
    subtitle: Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary), onTap: onTap,
    contentPadding: const EdgeInsets.all(12),
  ));
}