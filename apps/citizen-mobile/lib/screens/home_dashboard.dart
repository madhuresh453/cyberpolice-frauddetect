import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CyberShield AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('AI Powered Scam Protection', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ]),
              GestureDetector(onTap: () => context.go('/profile'),
                child: Container(width: 44, height: 44, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.cyberBlue, Color(0xFF0088FF)]), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person, color: Colors.white, size: 22))),
            ]),
            const SizedBox(height: 20),

            // Protection Status Card
            CyberCard(borderColor: AppTheme.safeGreen, child: Column(children: [
              Row(children: [
                const PulseContainer(size: 50, color: AppTheme.safeGreen, child: SizedBox(
                  width: 36, height: 36,
                  child: Icon(Icons.shield, color: AppTheme.safeGreen, size: 20))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('You are Protected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.safeGreen)),
                  Text('All protection modules active', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
                ])),
                const StatusBadge(label: 'LIVE', color: AppTheme.safeGreen),
              ]),
              const Divider(color: AppTheme.borderColor, height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _module('Call Protection', true), _module('SMS Protection', true), _module('WhatsApp', true), _module('UPI', true),
              ]),
            ])),
            const SizedBox(height: 20),

            // Quick Actions
            Row(children: [
              _quickAction(context, Icons.phone_in_talk, 'Call', AppTheme.cyberBlue, '/call/incoming'),
              _quickAction(context, Icons.sms, 'SMS', AppTheme.warningOrange, '/sms'),
              _quickAction(context, Icons.chat, 'WhatsApp', AppTheme.safeGreen, '/whatsapp'),
              _quickAction(context, Icons.payments, 'UPI', AppTheme.cyberBlue, '/upi'),
              _quickAction(context, Icons.link, 'Link', AppTheme.dangerRed, '/link-scanner'),
            ]),
            const SizedBox(height: 20),

            // Today's Activity
            CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionHeader(title: "Today's Activity"),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                const AnimatedCount(value: 24, label: 'Calls Scanned', color: AppTheme.cyberBlue),
                Container(width: 1, height: 50, color: AppTheme.borderColor),
                const AnimatedCount(value: 5, label: 'Threats Detected', color: AppTheme.dangerRed),
                Container(width: 1, height: 50, color: AppTheme.borderColor),
                const AnimatedCount(value: 12, label: 'People Protected', color: AppTheme.safeGreen),
              ]),
            ])),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: CyberBottomNav(currentIndex: 0, onTap: (i) {
        if (i == 1) context.go('/call/incoming');
        if (i == 2) context.go('/report');
        if (i == 3) context.go('/sms');
        if (i == 4) context.go('/profile');
      }),
    );
  }

  Widget _module(String name, bool active) {
    return Column(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppTheme.safeGreen : AppTheme.textDim)),
      const SizedBox(height: 4),
      Text(name, style: TextStyle(fontSize: 10, color: active ? AppTheme.safeGreen : AppTheme.textDim, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _quickAction(BuildContext c, IconData icon, String label, Color color, String route) {
    return GestureDetector(onTap: () => c.push(route), child: Container(
      width: 64, padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 22), const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    ));
  }
}