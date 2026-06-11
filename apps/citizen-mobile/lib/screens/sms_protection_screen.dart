import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class SmsProtectionScreen extends StatelessWidget {
  const SmsProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('SMS Protection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: AppTheme.neonBorder(color: AppTheme.successGreen),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.shield, size: 48, color: AppTheme.successGreen),
                const SizedBox(height: 12),
                Text('SMS Protection Active', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.successGreen)),
                const SizedBox(height: 8),
                Text('Scanning all incoming messages', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: AppTheme.glassCard(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Activity', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildStatRow('Total SMS', '12', Icons.sms, AppTheme.primaryBlue),
                _buildStatRow('Fraud Detected', '3', Icons.warning, AppTheme.dangerRed),
                _buildStatRow('Safe Messages', '8', Icons.check_circle, AppTheme.successGreen),
                _buildStatRow('Blocked Spam', '1', Icons.block, AppTheme.warningOrange),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Recent SMS Analysis', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildSmsItem(context, 'ICICI Bank', 'Your KYC is expiring...', AppTheme.dangerRed, 'FRAUD'),
          _buildSmsItem(context, 'Flipkart', 'You won ₹10,00,000...', AppTheme.dangerRed, 'SCAM'),
          _buildSmsItem(context, 'Airtel', 'Your bill is due...', AppTheme.successGreen, 'SAFE'),
          _buildSmsItem(context, 'Amazon', 'OTP for login: 4532...', AppTheme.successGreen, 'SAFE'),
          const SizedBox(height: 20),
          Container(
            decoration: AppTheme.glassCard(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Protection Settings', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SwitchListTile(title: const Text('Auto-block Fraud SMS'), value: true, onChanged: (v) {}, activeThumbColor: AppTheme.primaryBlue),
                SwitchListTile(title: const Text('Scan Unknown Senders'), value: true, onChanged: (v) {}, activeThumbColor: AppTheme.primaryBlue),
                SwitchListTile(title: const Text('Move Spam to Junk'), value: false, onChanged: (v) {}, activeThumbColor: AppTheme.primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(
      children: [Icon(icon, color: color, size: 20), const SizedBox(width: 12), Expanded(child: Text(label)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)))],
    ));
  }

  Widget _buildSmsItem(BuildContext context, String sender, String preview, Color color, String badge) {
    return Container(margin: const EdgeInsets.only(bottom: 8), decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(12), child: Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.sms, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sender, style: Theme.of(context).textTheme.titleMedium), Text(preview, style: Theme.of(context).textTheme.bodySmall, maxLines: 1)])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text(badge, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))),
      ],
    ));
  }
}