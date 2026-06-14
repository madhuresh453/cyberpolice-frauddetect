import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Profile Header
        Center(child: Column(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppTheme.cyberBlue, Color(0xFF0088FF)]),
              border: Border.all(color: AppTheme.cyberBlue.withValues(alpha: 0.3), width: 2)),
            child: const Icon(Icons.person, size: 40, color: Colors.white)),
          const SizedBox(height: 12),
          const Text('Rajesh Kumar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('+91 98765 43210', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
          const SizedBox(height: 4),
          const Text('Premium Member', style: TextStyle(fontSize: 12, color: AppTheme.safeGreen, fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(height: 24),
        // Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _stat('24', 'Calls', AppTheme.cyberBlue),
            _stat('5', 'Threats', AppTheme.dangerRed),
            _stat('3', 'Reports', AppTheme.warningOrange),
            _stat('12', 'Blocked', AppTheme.safeGreen),
          ])),
        const SizedBox(height: 24),
        // Settings
        _settingsSection('Account', [
          _settingsItem(Icons.person, 'Edit Profile', () {}),
          _settingsItem(Icons.lock, 'Change Password', () {}),
          _settingsItem(Icons.phone, 'Change Phone Number', () {}),
        ]),
        const SizedBox(height: 16),
        _settingsSection('Protection', [
          _settingsItem(Icons.shield, 'Protection Status', () {}),
          _settingsItem(Icons.notifications, 'Notification Settings', () {}),
          _settingsItem(Icons.family_restroom, 'Family Members', () => context.go('/family')),
          _settingsItem(Icons.location_on, 'Location Sharing', () {}),
        ]),
        const SizedBox(height: 16),
        _settingsSection('Data & Privacy', [
          _settingsItem(Icons.download, 'Export Data', () {}),
          _settingsItem(Icons.delete, 'Delete Account', () {}),
          _settingsItem(Icons.description, 'Privacy Policy', () {}),
          _settingsItem(Icons.description, 'Terms of Service', () {}),
        ]),
        const SizedBox(height: 16),
        _settingsSection('About', [
          _settingsItem(Icons.info, 'About CyberShield AI', () {}),
          _settingsItem(Icons.update, 'App Version 2.1.0', () {}),
          _settingsItem(Icons.star, 'Rate Us', () {}),
          _settingsItem(Icons.share, 'Share App', () {}),
        ]),
        const SizedBox(height: 30),
        Center(child: Text('CyberShield AI v2.1.0', style: TextStyle(fontSize: 12, color: AppTheme.textDim))),
        const SizedBox(height: 8),
        Center(child: Text('Built with ❤️ for India', style: TextStyle(fontSize: 12, color: AppTheme.textDim))),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ]);
  }

  Widget _settingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor)),
          child: Column(children: items)),
      ]);
  }

  Widget _settingsItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.borderColor, width: 0.5))),
        child: Row(children: [
          Icon(icon, size: 20, color: AppTheme.cyberBlue),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white))),
          const Icon(Icons.chevron_right, size: 20, color: AppTheme.textDim),
        ])));
  }
}