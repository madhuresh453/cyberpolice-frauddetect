import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_theme.dart';

class ReportSubmittedScreen extends StatelessWidget {
  const ReportSubmittedScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.successGreen.withValues(alpha: 0.1), boxShadow: [BoxShadow(color: AppTheme.successGreen.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10)]), child: const Icon(Icons.check_circle, size: 50, color: AppTheme.successGreen)),
      const SizedBox(height: 24), const Text('Report Submitted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 8), const Text('Your report has been filed successfully.', style: TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Container(margin: const EdgeInsets.symmetric(vertical: 16), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt, color: AppTheme.primaryBlue, size: 18), SizedBox(width: 8), Text('Tracking ID: CS-2024-001234', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
      ])),
      const SizedBox(height: 16), SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Back to Home'))),
      const SizedBox(height: 12), TextButton(onPressed: () => context.push('/report'), child: const Text('Report Another', style: TextStyle(color: AppTheme.primaryBlue))),
    ]))),
  );
}