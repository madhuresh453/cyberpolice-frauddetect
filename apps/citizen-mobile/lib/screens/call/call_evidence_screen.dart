import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class CallEvidenceScreen extends StatelessWidget {
  const CallEvidenceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Call Details & Evidence')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        CyberCard(child: Column(children: [
          _info('Phone Number', '+91 98765 43210'),
          _info('Date', '13 Jun 2026'), _info('Time', '10:31 PM'),
          _info('Duration', '5 min 24 sec'),
          _info('Risk Level', 'Very High', AppTheme.dangerRed),
          _info('Risk Score', '85/100', AppTheme.dangerRed),
        ])),
        const SizedBox(height: 16),
        const Text('AI Transcript', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _transcript('Caller:', '"Hello, I am from HDFC Bank."', false),
        _transcript('You:', '"Yes?"', false),
        _transcript('Caller:', '"Your account is blocked. Please share OTP."', true),
        _transcript('You:', '"Let me check..."', false),
        const SizedBox(height: 16),
        const Text('Voice Recording', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.play_arrow, color: AppTheme.dangerRed)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recording_20260613_2031.mp3', style: TextStyle(fontSize: 13, color: Colors.white)),
              Text('5 min 24 sec • 4.2 MB', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ])),
            const Icon(Icons.download, color: AppTheme.cyberBlue, size: 20),
          ])),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Download Evidence Package'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyberBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () {}, icon: const Icon(Icons.share), label: const Text('Share Evidence'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cardBg, foregroundColor: AppTheme.cyberBlue, padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: AppTheme.cyberBlue), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        const SizedBox(height: 30),
      ]),
    );
  }
  Widget _info(String label, String value, [Color? color]) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
    const Spacer(), Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? Colors.white)),
  ]));
  Widget _transcript(String who, String text, bool scam) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: scam ? AppTheme.dangerRed.withValues(alpha: 0.08) : AppTheme.cardBg, borderRadius: BorderRadius.circular(8), border: scam ? Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3)) : null),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(who, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scam ? AppTheme.dangerRed : AppTheme.cyberBlue)),
      const SizedBox(width: 8), Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: scam ? AppTheme.dangerRed : Colors.white))),
    ]));
}

// Used locally
class CyberCard extends StatelessWidget {
  final Widget child; final EdgeInsetsGeometry? padding; final Color? borderColor;
  const CyberCard({super.key, required this.child, this.padding, this.borderColor});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF131740), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: (borderColor ?? const Color(0xFF1E2456)).withValues(alpha: 0.5))),
    child: child,
  );
}