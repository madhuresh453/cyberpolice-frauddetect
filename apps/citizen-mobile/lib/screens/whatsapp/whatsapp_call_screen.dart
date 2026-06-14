import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class WhatsappCallScreen extends StatefulWidget {
  const WhatsappCallScreen({super.key});
  @override
  State<WhatsappCallScreen> createState() => _WhatsappCallScreenState();
}

class _WhatsappCallScreenState extends State<WhatsappCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: Container(
        decoration: BoxDecoration(gradient: RadialGradient(colors: [AppTheme.dangerRed.withValues(alpha: 0.05), AppTheme.cyberBlack], radius: 1.5)),
        child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          const Row(children: [Icon(Icons.chat, color: AppTheme.safeGreen), SizedBox(width: 8), Text('WhatsApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.safeGreen))]),
          const SizedBox(height: 4),
          const Text('WhatsApp Call Analysis', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          const PulseContainer(size: 120, color: AppTheme.dangerRed,
            child: SizedBox(width: 60, height: 60, child: Icon(Icons.phone_in_talk, size: 32, color: AppTheme.dangerRed))),
          const SizedBox(height: 16),
          const Text('WhatsApp Call Detected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('High Risk Scammer Number', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
          const SizedBox(height: 24),
          CyberCard(borderColor: AppTheme.dangerRed, child: Column(children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Risk Score', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)), Text('95/100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dangerRed))]),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Status', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)), Text('Very High Risk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dangerRed))]),
          ])),
          const SizedBox(height: 16),
          const Text('Detected Keywords', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: ['verify', 'otp', 'bank', 'account', 'kyc'].map((k) =>
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3))), child: Text(k, style: const TextStyle(fontSize: 11, color: AppTheme.dangerRed)))
          ).toList()),
          const Spacer(),
          Row(children: [
            Expanded(child: CyberButton(label: 'End & Block', icon: Icons.block, color: AppTheme.dangerRed, onPressed: () => context.go('/home'))),
            const SizedBox(width: 12),
            Expanded(child: CyberButton(label: 'Report', icon: Icons.report, color: AppTheme.warningOrange, onPressed: () => context.go('/report'))),
          ]),
        ]))),
      ),
    );
  }
}