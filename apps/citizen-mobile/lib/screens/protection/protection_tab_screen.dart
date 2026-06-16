import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Protection Tab – Central hub for all protection modules
class ProtectionTabScreen extends StatelessWidget {
  const ProtectionTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protection Engine'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.green, size: 10),
                SizedBox(width: 4),
                Text('ACTIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Protection Score Card
            _buildProtectionScoreCard(theme),
            const SizedBox(height: 20),

            // Module Grid
            Text('Protection Modules', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildModuleGrid(context, theme),
            const SizedBox(height: 20),

            // Recent Activity
            Text('Recent Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRecentActivity(theme),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionScoreCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80, height: 80,
                    child: CircularProgressIndicator(
                      value: 0.87,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('87', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('/100', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cyber Safety Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Strong protection active', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _miniStat('Call', '✓', Colors.green),
                      const SizedBox(width: 12),
                      _miniStat('SMS', '✓', Colors.green),
                      const SizedBox(width: 12),
                      _miniStat('UPI', '✓', Colors.green),
                      const SizedBox(width: 12),
                      _miniStat('Link', '✓', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 9)),
      ],
    );
  }

  Widget _buildModuleGrid(BuildContext context, ThemeData theme) {
    final modules = [
      _Module('Call Protection', Icons.phone_in_talk, Colors.blue, '/call/incoming', 'Active', Colors.green),
      _Module('SMS Protection', Icons.sms, Colors.orange, '/sms', 'Active', Colors.green),
      _Module('WhatsApp Protection', Icons.chat, Colors.green, '/whatsapp', 'Active', Colors.green),
      _Module('UPI Protection', Icons.payments, Colors.blue, '/upi', 'Active', Colors.green),
      _Module('Link Scanner', Icons.link, Colors.red, '/link-scanner', 'Active', Colors.green),
      _Module('APK Scanner', Icons.android, Colors.purple, '/fake-apk', 'Active', Colors.green),
      _Module('Deepfake Detection', Icons.face, Colors.teal, '/deepfake', 'Active', Colors.green),
      _Module('Screen Sharing', Icons.screen_share, Colors.amber, '/screen-sharing', 'Monitor', Colors.orange),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: modules.length,
      itemBuilder: (ctx, i) {
        final m = modules[i];
        return GestureDetector(
          onTap: () {
            final route = m.route;
            if (route.isNotEmpty) {
              context.push(route);
            }
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: m.iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(m.icon, color: m.iconColor, size: 20),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: m.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(m.status, style: TextStyle(color: m.statusColor, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(m.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final activities = [
      _Activity('Suspicious call blocked', '+91 98765 43210', '2 min ago', Colors.red),
      _Activity('SMS scanned – safe', 'Bank-Alert', '15 min ago', Colors.green),
      _Activity('UPI request verified', 'merchant@upi', '1 hour ago', Colors.green),
      _Activity('Link flagged – phishing', 'bit.ly/xxx', '3 hours ago', Colors.red),
    ];

    return Column(
      children: activities.map((a) => Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: a.color.withValues(alpha: 0.15),
            child: Icon(a.color == Colors.red ? Icons.warning : Icons.check_circle, color: a.color, size: 16),
          ),
          title: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          subtitle: Text(a.subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          trailing: Text(a.time, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ),
      )).toList(),
    );
  }
}

class _Module {
  final String name;
  final IconData icon;
  final Color iconColor;
  final String route;
  final String status;
  final Color statusColor;
  _Module(this.name, this.icon, this.iconColor, this.route, this.status, this.statusColor);
}

class _Activity {
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  _Activity(this.title, this.subtitle, this.time, this.color);
}