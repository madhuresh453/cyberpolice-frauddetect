import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_theme.dart';

class SeniorModeScreen extends StatelessWidget {
  const SeniorModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Senior Mode')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryBlue.withValues(alpha: 0.1), AppTheme.primaryBlue.withValues(alpha: 0.02)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
            ),
            child: const Column(children: [
              Icon(Icons.elderly, size: 64, color: AppTheme.primaryBlue),
              SizedBox(height: 16),
              Text('Senior Protection Mode', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Simplified interface for senior citizens', style: TextStyle(color: AppTheme.textSecondary)),
            ]),
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(context, Icons.phone, 'Call Protection', 'Auto-detect scam calls', '/call/incoming'),
          _buildFeatureCard(context, Icons.sms, 'SMS Protection', 'Block fraudulent messages', '/sms'),
          _buildFeatureCard(context, Icons.emergency, 'Emergency SOS', 'One tap emergency alert', '/emergency-sos'),
          _buildFeatureCard(context, Icons.support_agent, 'Helpline', 'Call cyber crime helpline', '/help'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/report'),
              icon: const Icon(Icons.report),
              label: const Text('Report an Issue'),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String subtitle, String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.primaryBlue, size: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, size: 28),
        onTap: () => context.push(route),
      ),
    );
  }
}