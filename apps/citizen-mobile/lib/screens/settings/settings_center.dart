import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../core/permission_manager.dart';

class SettingsCenter extends ConsumerWidget {
  const SettingsCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Section
          _sectionHeader('Security', Icons.security, theme),
          _settingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Lock',
            subtitle: 'Secure app with fingerprint/face',
            trailing: Switch(
              value: settings.biometricLock,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleBiometric(),
              activeColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),
          _settingsTile(
            icon: Icons.pin,
            title: 'PIN Protection',
            subtitle: 'Require PIN to open app',
            trailing: Switch(
              value: settings.pinProtection,
              onChanged: (_) => ref.read(settingsProvider.notifier).togglePin(),
              activeColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),

          const Divider(height: 32),

          // Notifications Section
          _sectionHeader('Notifications', Icons.notifications, theme),
          _settingsTile(
            icon: Icons.warning_amber,
            title: 'Threat Notifications',
            subtitle: 'Real-time fraud alerts',
            trailing: Switch(
              value: settings.threatNotifications,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotifications(),
              activeColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),
          _settingsTile(
            icon: Icons.block,
            title: 'Auto-Block Scammers',
            subtitle: 'Automatically block known fraud numbers',
            trailing: Switch(
              value: settings.autoBlockScammers,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleAutoBlock(),
              activeColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),

          const Divider(height: 32),

          // Appearance Section
          _sectionHeader('Appearance', Icons.palette, theme),
          _settingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: settings.darkMode ? 'Dark theme active' : 'Light theme active',
            trailing: Switch(
              value: settings.darkMode,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleDarkMode(),
              activeColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),

          const Divider(height: 32),

          // Emergency Section
          _sectionHeader('Emergency', Icons.warning, theme),
          _settingsTile(
            icon: Icons.sos,
            title: 'Emergency SOS',
            subtitle: 'Quick-access emergency mode',
            trailing: Switch(
              value: settings.emergencySOS,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleEmergencySOS(),
              activeColor: Colors.red,
            ),
            theme: theme,
          ),

          const Divider(height: 32),

          // Permissions Section
          _sectionHeader('Permissions', Icons.verified_user, theme),
          _settingsTile(
            icon: Icons.shield,
            title: 'Manage Permissions',
            subtitle: 'View and request permissions',
            trailing: const Icon(Icons.chevron_right),
            theme: theme,
            onTap: () => _showPermissionStatus(context),
          ),

          const Divider(height: 32),

          // Account & Data
          _sectionHeader('Data', Icons.storage, theme),
          _settingsTile(
            icon: Icons.file_download,
            title: 'Export Reports',
            subtitle: 'Download fraud reports as PDF',
            trailing: Switch(
              value: settings.exportReports,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleExportReports(),
              activeColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),

          const SizedBox(height: 16),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showPermissionStatus(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: RaksaarPermissionManager.checkAllPermissions(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final p = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permission Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _permRow('Call Logs', p['callLogs']),
                _permRow('Contacts', p['contacts']),
                _permRow('Microphone', p['microphone']),
                _permRow('SMS', p['sms']),
                _permRow('Camera', p['camera']),
                _permRow('Notifications', p['notifications']),
                const Divider(height: 16),
                Text('Optional', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                _permRow('Overlay', p['overlay']),
                _permRow('Accessibility', p['accessibility']),
                _permRow('Battery', p['batteryOptimization']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _permRow(String label, dynamic granted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(granted == true ? Icons.check_circle : Icons.cancel,
              color: granted == true ? Colors.green : Colors.red, size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(granted == true ? 'Granted' : 'Missing',
              style: TextStyle(color: granted == true ? Colors.green : Colors.red, fontSize: 11)),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CyberShield AI (RAKSAAR)',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shield, size: 48, color: Colors.blue),
      children: [
        const Text('A Government of India Initiative\nDPDP 2023 Compliant\n\nProtecting citizens from cyber fraud using AI.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? All protection services will stop.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}