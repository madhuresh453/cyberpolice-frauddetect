import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/permission_manager.dart';
import '../../core/config/app_config.dart';

/// Profile Tab – Citizen Profile, Settings, Permissions, DPDP Consent
class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
          _buildProfileCard(context, theme, auth),
          const SizedBox(height: 20),

          _sectionHeader('Security', Icons.security, theme),
          _settingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Lock',
            subtitle: 'Secure app with fingerprint/face',
            trailing: Switch(
              value: settings.biometricLock,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleBiometric(),
              activeThumbColor: theme.colorScheme.primary,
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
              activeThumbColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),

          const Divider(height: 32),

          _sectionHeader('Notifications', Icons.notifications, theme),
          _settingsTile(
            icon: Icons.warning_amber,
            title: 'Threat Notifications',
            subtitle: 'Real-time fraud alerts',
            trailing: Switch(
              value: settings.threatNotifications,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotifications(),
              activeThumbColor: theme.colorScheme.primary,
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
              activeThumbColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),

          const Divider(height: 32),

          _sectionHeader('Appearance', Icons.palette, theme),
          _settingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: settings.darkMode ? 'Dark theme active' : 'Light theme active',
            trailing: Switch(
              value: settings.darkMode,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleDarkMode(),
              activeThumbColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),

          const Divider(height: 32),

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

          _sectionHeader('Data & Privacy', Icons.storage, theme),
          _settingsTile(
            icon: Icons.file_download,
            title: 'Export Reports',
            subtitle: 'Download fraud reports as PDF',
            trailing: Switch(
              value: settings.exportReports,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleExportReports(),
              activeThumbColor: theme.colorScheme.primary,
            ),
            theme: theme,
          ),
          _settingsTile(
            icon: Icons.privacy_tip,
            title: 'DPDP Consent',
            subtitle: 'Manage data protection consent',
            trailing: const Icon(Icons.chevron_right),
            theme: theme,
            onTap: () => _showDPDPConsent(context),
          ),

          const Divider(height: 32),

          _sectionHeader('Account', Icons.person, theme),
          _settingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            trailing: const Icon(Icons.chevron_right),
            theme: theme,
            onTap: () => _showLanguagePicker(context),
          ),
          _settingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            trailing: const Icon(Icons.chevron_right),
            theme: theme,
            onTap: () => context.push('/auth'),
          ),

          const Divider(height: 32),

          _sectionHeader('App Info', Icons.info, theme),
          _settingsTile(
            icon: Icons.update,
            title: 'Version',
            subtitle: '${AppConfig.appVersion} (${AppConfig.buildNumber})',
            theme: theme,
          ),
          _settingsTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'View terms and conditions',
            trailing: const Icon(Icons.open_in_new, size: 16),
            theme: theme,
            onTap: () => _launchUrl('${AppConfig.appUrl}/terms'),
          ),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'View privacy policy',
            trailing: const Icon(Icons.open_in_new, size: 16),
            theme: theme,
            onTap: () => _launchUrl('${AppConfig.appUrl}/privacy'),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
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

  Widget _buildProfileCard(
  BuildContext context,
  ThemeData theme,
  AuthState auth,
) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0088FF)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.fullName ?? 'Citizen', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(auth.email ?? 'citizen@raksaar.gov.in', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Verified Citizen', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => context.push('/auth'),
            ),
          ],
        ),
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
                _permRow('Phone', p['callLogs']),
                _permRow('Contacts', p['contacts']),
                _permRow('SMS', p['sms']),
                _permRow('Camera', p['camera']),
                _permRow('Microphone', p['microphone']),
                _permRow('Notifications', p['notifications']),
                const Divider(height: 16),
                Text('Optional', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                _permRow('Location', p['location']),
                _permRow('Overlay', p['overlay']),
                _permRow('Battery', p['batteryOptimization']),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      RaksaarPermissionManager.requestMandatoryPermissions(context: context);
                    },
                    child: const Text('Request All Permissions'),
                  ),
                ),
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

  void _showDPDPConsent(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DPDP 2023 Consent'),
        content: const SingleChildScrollView(
          child: Text(
            'RAKSAAR collects and processes personal data in accordance with the Digital Personal Data Protection Act, 2023.\n\n'
            'Data collected:\n'
            '• Phone numbers for fraud detection\n'
            '• SMS content for scam analysis\n'
            '• Call logs for threat detection\n'
            '• Location for emergency services\n\n'
            'Your data is encrypted and stored securely. '
            'You can export or delete your data at any time.\n\n'
            'By continuing, you consent to data processing for cyber safety purposes.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Decline')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('I Consent'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Marathi', 'Bengali', 'Gujarati', 'Kannada', 'Punjabi', 'Malayalam'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...languages.map((lang) => ListTile(
            title: Text(lang),
            trailing: lang == 'English' ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => Navigator.pop(ctx),
          )),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'RAKSAAR',
      applicationVersion: '${AppConfig.appVersion} (${AppConfig.buildNumber})',
      applicationIcon: const Icon(Icons.shield, size: 48, color: Colors.blue),
      children: const [
        Text('Cyber Safety Operating System\nA Government of India Initiative\nDPDP 2023 Compliant\n\nProtecting citizens from cyber fraud using AI.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext outerContext, WidgetRef ref) {
    showDialog(
      context: outerContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? All protection services will stop.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              outerContext.go('/auth');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}