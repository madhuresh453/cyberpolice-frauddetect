import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class CallSummaryScreen extends StatelessWidget {
  const CallSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 20),
        const Text('Call Ended', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        const RiskMeter(score: 85, size: 100, showLabel: true),
        const SizedBox(height: 24),
        CyberCard(borderColor: AppTheme.dangerRed, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Detected:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          _item('OTP requested'), _item('Fake representative'), _item('Number unverified'), _item('Call disconnected suddenly'), _item('Fraud behavior detected'),
        ])),
        const SizedBox(height: 20),
        const Text('Timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 12),
        _timeline('10:31', 'Call Started'), _timeline('10:33', 'OTP Mentioned'), _timeline('10:35', 'Verification Scam Detected'), _timeline('10:36', 'Call Ended'),
        const SizedBox(height: 20),
        const Text('Evidence Saved', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.safeGreen)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _evidenceItem(Icons.description, 'Transcript'),
          _evidenceItem(Icons.mic, 'Audio'),
          _evidenceItem(Icons.analytics, 'AI Analysis'),
          _evidenceItem(Icons.assignment, 'Report'),
        ]),
        const Spacer(),
        CyberButton(label: 'View Details', icon: Icons.visibility, onPressed: () => context.go('/call/evidence')),
        const SizedBox(height: 16),
      ]))),
    );
  }
  Widget _item(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
    const Icon(Icons.check_circle, size: 16, color: AppTheme.dangerRed), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
  ]));
  Widget _timeline(String time, String event) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)), const SizedBox(width: 12),
    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cyberBlue.withValues(alpha: 0.5))), const SizedBox(width: 12),
    Text(event, style: const TextStyle(fontSize: 13, color: Colors.white)),
  ]));
  Widget _evidenceItem(IconData icon, String label) => Column(children: [
    Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
      child: Icon(icon, color: AppTheme.cyberBlue, size: 22)),
    const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
  ]);
}