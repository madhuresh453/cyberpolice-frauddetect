import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class ReportSuccessScreen extends StatelessWidget {
  const ReportSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 60),
          const AllianceIcon(size: 180), const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: [AppTheme.safeGreen, Color(0xFF0088FF)]).createShader(bounds),
            child: const Text('Report Submitted', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
          const SizedBox(height: 8),
          Text('Your report has been sent to the Cyber Crime Division',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _item('Case ID', 'CSD-2026-002847', AppTheme.cyberBlue),
              const SizedBox(height: 8),
              _item('Status', 'Reported', AppTheme.safeGreen),
              const SizedBox(height: 8),
              _item('Type', 'Phone Scam', AppTheme.dangerRed),
              const SizedBox(height: 8),
              _item('Reported At', '13 Jun 2026, 10:30 PM', AppTheme.textSecondary),
            ])),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.safeGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.safeGreen.withValues(alpha: 0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('What Happens Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.safeGreen)),
              const SizedBox(height: 12),
              _next('You will receive a confirmation call within 48 hours'),
              _next('Your case will be reviewed by the Cyber Crime Division'),
              _next('Evidence package has been automatically generated'),
              _next('You can track status via the Cyber Crime website'),
            ])),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _actionButton(context, Icons.home, 'Home', () => context.go('/home')),
            const SizedBox(width: 30),
            _actionButton(context, Icons.emergency, 'Emergency', () => context.go('/emergency')),
            const SizedBox(width: 30),
            _actionButton(context, Icons.share, 'Share', () {}),
          ]),
          const Spacer(),
        ]))));
  }

  Widget _item(String label, String value, Color color) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color))]);

  Widget _next(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [const Icon(Icons.check_circle, size: 18, color: AppTheme.safeGreen),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white)))]));

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Column(children: [
      Container(width: 56, height: 56,
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
        child: Icon(icon, color: AppTheme.cyberBlue, size: 24)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ]));
}

class AllianceIcon extends StatelessWidget {
  final double size;
  const AllianceIcon({super.key, required this.size});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Center(
        child: Container(
          width: 140, height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.safeGreen.withValues(alpha: 0.8), width: 2),
            boxShadow: [BoxShadow(color: AppTheme.safeGreen.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10)]),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.safeGreen.withValues(alpha: 0.3), width: 1)),
            child: const Icon(Icons.verified, size: 48, color: AppTheme.safeGreen),
          ),
        ),
      ),
    );
  }
}
