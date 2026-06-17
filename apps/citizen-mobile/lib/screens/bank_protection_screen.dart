import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_theme.dart';

class BankProtectionScreen extends StatelessWidget {
  const BankProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Bank Protection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.withValues(alpha: 0.1), Colors.blue.withValues(alpha: 0.02)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Column(children: [
              Icon(Icons.account_balance, size: 48, color: Colors.blue),
              SizedBox(height: 12),
              Text('Bank Account Protection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Monitor and protect your bank accounts', style: TextStyle(color: AppTheme.textSecondary)),
            ]),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.phone, color: Colors.blue)),
              title: const Text('Report Fraud Transaction'),
              subtitle: const Text('Call 1930 for immediate action'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/report'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.block, color: Colors.red)),
              title: const Text('Freeze Account'),
              subtitle: const Text('Temporarily freeze your account'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/report'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.check_circle, color: Colors.green)),
              title: const Text('Verify Transaction'),
              subtitle: const Text('Check if a transaction is legitimate'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/ai-investigator'),
            ),
          ),
        ],
      ),
    );
  }
}