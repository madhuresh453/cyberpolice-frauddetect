import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class SmsProtectionScreen extends StatelessWidget {
  const SmsProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('SMS Protection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tabs
          Row(children: [
            _tab('Inbox', true), const SizedBox(width: 8), _tab('Spam', false),
          ]),
          const SizedBox(height: 20),
          // Message cards
          _messageCard(context, 'AD-LOAN', '09:31 AM', 'Your loan is approved...', 'Safe', AppTheme.safeGreen, false),
          const SizedBox(height: 12),
          _messageCard(context, 'VK-BANKAL', '10:15 AM', 'Your account is blocked. Call us now...', 'Suspicious', AppTheme.warningOrange, true),
          const SizedBox(height: 12),
          _messageCard(context, 'BZ-PRIZE', '11:02 AM', 'Congratulations! You won ₹50,000...', 'Suspicious', AppTheme.warningOrange, true),
          const SizedBox(height: 12),
          _messageCard(context, 'AD-SBI', '12:30 PM', 'RNHBalance is ₹45000', 'Safe', AppTheme.safeGreen, false),
          const SizedBox(height: 12),
          _messageCard(context, 'DM-KYC', '01:45 PM', 'Your KYC is pending. Verify now...', 'Spam', AppTheme.dangerRed, true),
        ],
      ),
      bottomNavigationBar: CyberBottomNav(currentIndex: 3, onTap: (i) {
        if (i == 0) context.go('/home');
        if (i == 2) context.go('/report');
        if (i == 4) context.go('/profile');
      }),
    );
  }

  Widget _tab(String label, bool active)
    => GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: active ? AppTheme.cyberBlue.withValues(alpha: 0.15) : AppTheme.cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: active ? AppTheme.cyberBlue : AppTheme.borderColor)),
        child: Text(label, style: TextStyle(color: active ? AppTheme.cyberBlue : AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
      ));

  Widget _messageCard(BuildContext context, String sender, String time, String preview, String risk, Color color, bool scam) {
    return GestureDetector(
      onTap: () => context.push('/sms/scam-result'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: scam ? color.withValues(alpha: 0.3) : AppTheme.borderColor)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.message, color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sender, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 4),
            Text(preview, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 10, color: AppTheme.textDim)),
          ])),
          StatusBadge(label: risk, color: color),
        ]),
      ),
    );
  }
}