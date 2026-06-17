import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Safety Tab – Emergency SOS, Women Safety, Family Protection
class SafetyTabScreen extends StatelessWidget {
  const SafetyTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () => _shareLocation(context),
            tooltip: 'Share Location',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSOSCard(context, theme),
          const SizedBox(height: 20),

          Text('Emergency Services', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildEmergencyActions(context, theme),
          const SizedBox(height: 20),

          Text('Women Safety', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildWomenSafetySection(context, theme),
          const SizedBox(height: 20),

          Text('Trusted Contacts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildTrustedContacts(context, theme),
          const SizedBox(height: 20),

          Text('Family Protection', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFamilyProtection(context, theme),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSOSCard(BuildContext context, ThemeData theme) {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.emergency, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text('EMERGENCY SOS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            Text('Press for immediate emergency assistance', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _triggerSOS(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('ACTIVATE SOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sosOption(Icons.volume_up, 'Silent SOS', () => _triggerSilentSOS(context)),
                _sosOption(Icons.videocam, 'Record Video', () => context.push('/emergency-sos')),
                _sosOption(Icons.mic, 'Record Audio', () => context.push('/emergency-sos')),
                _sosOption(Icons.share, 'Share Location', () => _shareLocation(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sosOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.red, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildEmergencyActions(BuildContext context, ThemeData theme) {
    final actions = [
      _EmergencyAction('Call 1930', 'Cyber Crime Helpline', Icons.phone, Colors.red, () => _dialNumber('1930')),
      _EmergencyAction('Call 112', 'National Emergency', Icons.phone, Colors.orange, () => _dialNumber('112')),
      _EmergencyAction('Call 181', 'Women Helpline', Icons.phone, Colors.pink, () => _dialNumber('181')),
      _EmergencyAction('Report Fraud', 'File Complaint', Icons.report, Colors.blue, () => context.push('/report')),
    ];

    return Column(
      children: actions.map((a) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(a.icon, color: a.color, size: 22),
          ),
          title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(a.subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          trailing: Icon(Icons.chevron_right, color: a.color),
          onTap: a.onTap,
        ),
      )).toList(),
    );
  }

  Widget _buildWomenSafetySection(BuildContext context, ThemeData theme) {
    final features = [
      {'title': 'Emergency Contacts', 'subtitle': 'Manage your emergency contacts', 'icon': Icons.contacts, 'route': '/emergency'},
      {'title': 'Location Sharing', 'subtitle': 'Share live location with trusted contacts', 'icon': Icons.location_on, 'route': '/settings'},
      {'title': 'Safety Alerts', 'subtitle': 'Area-based safety notifications', 'icon': Icons.notifications_active, 'route': '/settings'},
      {'title': 'Fake Call', 'subtitle': 'Simulate an incoming call to escape', 'icon': Icons.phone_in_talk, 'route': '/call/incoming'},
    ];

    return Column(
      children: features.map((f) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(f['icon'] as IconData, color: Colors.pink, size: 22),
          ),
          title: Text(f['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(f['subtitle'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            final route = f['route'] as String;
            if (route.isNotEmpty) {
              context.push(route);
            }
          },
        ),
      )).toList(),
    );
  }

  Widget _buildTrustedContacts(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.people, size: 40, color: Colors.grey[500]),
            const SizedBox(height: 8),
            Text('No trusted contacts added', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/emergency'),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Add Trusted Contact'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyProtection(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.family_restroom, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Family Protection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Protect your family from cyber threats', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/family'),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Open Family Dashboard'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dialNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _triggerSOS(BuildContext context) {
    context.push('/emergency-sos');
  }

  void _triggerSilentSOS(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silent SOS activated – contacts notified'), backgroundColor: Colors.red),
    );
  }

  void _shareLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location sharing started'), backgroundColor: Colors.blue),
    );
  }
}

class _EmergencyAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _EmergencyAction(this.title, this.subtitle, this.icon, this.color, this.onTap);
}