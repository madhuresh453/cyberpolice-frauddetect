import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});
  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool mic = false, phone = false, contacts = false, sms = false, location = false, storage = false;

  @override
  Widget build(BuildContext context) {
    final allGranted = mic && phone && contacts && sms && location && storage;
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),
            const ShieldIcon(size: 80),
            const SizedBox(height: 20),
            const Text('Enable Full Protection', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 32),
            _permCard(Icons.mic, 'Microphone', 'Analyze calls for scam patterns', mic, () => setState(() => mic = !mic)),
            const SizedBox(height: 12),
            _permCard(Icons.phone_in_talk, 'Phone', 'Call state detection', phone, () => setState(() => phone = !phone)),
            const SizedBox(height: 12),
            _permCard(Icons.contacts, 'Contacts', 'Verify callers', contacts, () => setState(() => contacts = !contacts)),
            const SizedBox(height: 12),
            _permCard(Icons.sms, 'SMS', 'Fraud SMS scanning', sms, () => setState(() => sms = !sms)),
            const SizedBox(height: 12),
            _permCard(Icons.location_on, 'Location', 'Fraud hotspot mapping', location, () => setState(() => location = !location)),
            const SizedBox(height: 12),
            _permCard(Icons.folder, 'Storage', 'Save evidence securely', storage, () => setState(() => storage = !storage)),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: const Row(children: [Icon(Icons.lock_outline, size: 16, color: AppTheme.textSecondary), SizedBox(width: 8), Text('Your data is safe and 100% secure', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))])),
            const SizedBox(height: 24),
            CyberButton(label: allGranted ? 'Continue to Dashboard' : 'Allow All', icon: allGranted ? Icons.arrow_forward : Icons.shield,
              color: allGranted ? AppTheme.safeGreen : AppTheme.cyberBlue,
              onPressed: () => context.go('/home')),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _permCard(IconData icon, String title, String desc, bool granted, VoidCallback onToggle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: granted ? AppTheme.safeGreen.withValues(alpha: 0.3) : AppTheme.borderColor)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: (granted ? AppTheme.safeGreen : AppTheme.cyberBlue).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: granted ? AppTheme.safeGreen : AppTheme.cyberBlue, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        Switch(value: granted, onChanged: (v) => onToggle(), activeThumbColor: AppTheme.safeGreen),
      ]),
    );
  }
}