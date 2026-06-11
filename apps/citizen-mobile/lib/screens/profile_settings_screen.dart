import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/app_theme.dart';
import '../services/auth_service.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Settings')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.primaryBlue), padding: const EdgeInsets.all(20), child: Row(children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primaryBlue, Color(0xFF8B5CF6)]), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person, color: Colors.white, size: 28)),
        const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Rahul Sharma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), Text('+91 98765 43210', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))])),
        const Icon(Icons.edit, color: AppTheme.primaryBlue, size: 20),
      ])),
      const SizedBox(height: 24),
      _section(context, 'Account', [ _tile(Icons.person, 'Profile', (){}), _tile(Icons.security, 'Security', (){}), _tile(Icons.fingerprint, 'Biometric Lock', (){}), ]),
      _section(context, 'Preferences', [ _tile(Icons.notifications, 'Notifications', (){}), _tile(Icons.language, 'Language', (){}), _tile(Icons.dark_mode, 'Theme', (){}), ]),
      _section(context, 'Support', [ _tile(Icons.help, 'Help Center', (){}), _tile(Icons.info, 'About', (){}), _tile(Icons.description, 'Privacy Policy', (){}), ]),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () async {
        await ref.read(authServiceProvider).logout();
        if (context.mounted) context.go('/auth');
      }, icon: const Icon(Icons.logout, color: AppTheme.dangerRed), label: const Text('Logout', style: TextStyle(color: AppTheme.dangerRed)))),
      const SizedBox(height: 32),
    ]),
  );
  Widget _section(BuildContext c, String title, List<Widget> tiles) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8), child: Text(title, style: Theme.of(c).textTheme.titleLarge)), Container(decoration: AppTheme.glassCard(), child: Column(children: tiles.map((t) => t).toList()))]);
  Widget _tile(IconData icon, String title, VoidCallback onTap) => ListTile(leading: Icon(icon, color: AppTheme.primaryBlue), title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)), trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20), onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 12));
}