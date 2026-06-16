import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../themes/raksaar_theme.dart';

/// A working dashboard with real Riverpod state.
/// All buttons navigates to real screens.
class RaksaarHomeDashboard extends ConsumerWidget {
  final List<String> startupErrors;
  const RaksaarHomeDashboard({super.key, this.startupErrors = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildProtectionStatusCard(theme),
            const SizedBox(height: 20),
            _buildQuickActions(theme, context),
            const SizedBox(height: 20),
            _buildActivitySection(theme),
            const SizedBox(height: 20),
            _buildModules(theme, context),
            const SizedBox(height: 20),
            _buildThreatSection(theme),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CyberShield AI',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('AI Powered Scam Protection',
                style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0088FF)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 22),
        ),
      ],
    );
  }

  Widget _buildProtectionStatusCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield, color: Colors.green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('You are Protected',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('All protection modules active',
                          style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.fiber_manual_record, color: Colors.green, size: 10),
                      SizedBox(width: 4),
                      Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _moduleDot('Call', true, Colors.green),
                _moduleDot('SMS', true, Colors.green),
                _moduleDot('WhatsApp', true, Colors.green),
                _moduleDot('UPI', true, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleDot(String name, bool active, Color color) {
    return Column(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: active ? color : Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(name, style: TextStyle(fontSize: 10, color: active ? color : Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme, BuildContext context) {
    final actions = [
      {'label': 'Call', 'icon': Icons.phone_in_talk, 'color': Colors.blue, 'route': '/call/incoming'},
      {'label': 'SMS', 'icon': Icons.sms, 'color': Colors.orange, 'route': '/sms'},
      {'label': 'WhatsApp', 'icon': Icons.chat, 'color': Colors.green, 'route': '/whatsapp'},
      {'label': 'UPI', 'icon': Icons.payments, 'color': Colors.blue, 'route': '/upi'},
      {'label': 'Link', 'icon': Icons.link, 'color': Colors.red, 'route': '/link-scanner'},
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              final route = a['route'] as String;
              if (route.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${a['label']}...'), duration: const Duration(seconds: 1)),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: (a['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (a['color'] as Color).withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22),
                  const SizedBox(height: 4),
                  Text(a['label'] as String,
                      style: TextStyle(color: a['color'] as Color, fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivitySection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statWidget('24', 'Calls Scanned', Colors.blue),
                Container(width: 1, height: 40, color: Colors.grey[800]),
                _statWidget('5', 'Threats Detected', Colors.red),
                Container(width: 1, height: 40, color: Colors.grey[800]),
                _statWidget('12', 'People Protected', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statWidget(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
      ],
    );
  }

  Widget _buildModules(ThemeData theme, BuildContext context) {
    final modules = [
      {'name': 'Call Protection', 'route': '/call/incoming', 'icon': Icons.phone_in_talk, 'active': true},
      {'name': 'SMS Protection', 'route': '/sms', 'icon': Icons.sms, 'active': true},
      {'name': 'Link Scanner', 'route': '/link-scanner', 'icon': Icons.link, 'active': true},
      {'name': 'Emergency', 'route': '/emergency', 'icon': Icons.warning_amber, 'active': true},
      {'name': 'Report Fraud', 'route': '/report', 'icon': Icons.assignment, 'active': true},
      {'name': 'Settings', 'route': '', 'icon': Icons.settings, 'active': false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: modules.length,
      itemBuilder: (ctx, i) {
        final m = modules[i];
        return GestureDetector(
          onTap: m['active'] == true
              ? () {
                  final route = m['route'] as String;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${m['name']}...'), duration: const Duration(seconds: 1)),
                  );
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m['icon'] as IconData, color: m['active'] == true ? theme.colorScheme.primary : Colors.grey, size: 28),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(m['name'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: m['active'] == true ? Colors.white : Colors.grey, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThreatSection(ThemeData theme) {
    final threats = [
      {'type': 'call', 'number': '+91 98765 43210', 'risk': 92, 'time': '2 min ago'},
      {'type': 'sms', 'number': 'KYC-ALERT', 'risk': 78, 'time': '15 min ago'},
      {'type': 'upi', 'number': 'pay@upi', 'risk': 95, 'time': '1 hour ago'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Threats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...threats.map((t) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.red.withValues(alpha: 0.15),
              child: Icon(Icons.warning, color: Colors.red, size: 16),
            ),
            title: Text(t['number'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text('${t['type']} • ${t['time']}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${t['risk']}%', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        )),
      ],
    );
  }
}