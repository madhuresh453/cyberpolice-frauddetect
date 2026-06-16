import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../themes/raksaar_theme.dart';
import '../../core/config/app_config.dart';

/// RAKSAAR Home Dashboard – All buttons navigate to real screens.
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
            _buildHeader(theme, context),
            const SizedBox(height: 16),
            _buildProtectionStatusCard(theme),
            const SizedBox(height: 20),
            _buildCyberSafetyScore(theme),
            const SizedBox(height: 20),
            _buildQuickActions(theme, context),
            const SizedBox(height: 20),
            _buildProtectionCards(theme, context),
            const SizedBox(height: 20),
            _buildThreatSection(theme, context),
            const SizedBox(height: 20),
            _buildRecentTimeline(theme),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RAKSAAR',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(AppConfig.appTagline,
                style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0088FF)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 22),
          ),
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

  Widget _buildCyberSafetyScore(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 60, height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60, height: 60,
                    child: CircularProgressIndicator(
                      value: 0.87,
                      strokeWidth: 5,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const Text('87', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cyber Safety Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 2),
                  Text('Strong protection active', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, BuildContext context) {
    final actions = [
      {'label': 'SOS', 'icon': Icons.emergency, 'color': Colors.red, 'route': '/emergency'},
      {'label': 'Report', 'icon': Icons.assignment, 'color': Colors.orange, 'route': '/report'},
      {'label': 'Check No.', 'icon': Icons.phone, 'color': Colors.blue, 'route': '/ai-investigator'},
      {'label': 'Check UPI', 'icon': Icons.payments, 'color': Colors.green, 'route': '/upi'},
      {'label': 'Scan QR', 'icon': Icons.qr_code_scanner, 'color': Colors.purple, 'route': '/qr-scanner'},
      {'label': 'Threat Map', 'icon': Icons.map, 'color': Colors.teal, 'route': '/heatmap'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (ctx, i) {
            final a = actions[i];
            return GestureDetector(
              onTap: () => context.push(a['route'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: (a['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (a['color'] as Color).withValues(alpha: 0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a['icon'] as IconData, color: a['color'] as Color, size: 24),
                    const SizedBox(height: 4),
                    Text(a['label'] as String,
                        style: TextStyle(color: a['color'] as Color, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProtectionCards(ThemeData theme, BuildContext context) {
    final cards = [
      _ProtectionCard('Call Protection', 'Screen incoming calls', Icons.phone_in_talk, Colors.blue, '/call/incoming'),
      _ProtectionCard('SMS Protection', 'Analyze SMS messages', Icons.sms, Colors.orange, '/sms'),
      _ProtectionCard('WhatsApp Protection', 'Monitor notifications', Icons.chat, Colors.green, '/whatsapp'),
      _ProtectionCard('UPI Protection', 'Verify UPI requests', Icons.payments, Colors.blue, '/upi'),
      _ProtectionCard('Deepfake Detection', 'Analyze media', Icons.face, Colors.teal, '/deepfake'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Protection Modules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ...cards.map((c) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(c.icon, color: c.color, size: 22),
            ),
            title: Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(c.subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(c.route),
          ),
        )),
      ],
    );
  }

  Widget _buildThreatSection(ThemeData theme, BuildContext context) {
    final threats = [
      {'type': 'call', 'number': '+91 98765 43210', 'risk': 92, 'time': '2 min ago'},
      {'type': 'sms', 'number': 'KYC-ALERT', 'risk': 78, 'time': '15 min ago'},
      {'type': 'upi', 'number': 'pay@upi', 'risk': 95, 'time': '1 hour ago'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Threats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () => context.push('/heatmap'),
              child: const Text('View All', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        ...threats.map((t) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.red.withValues(alpha: 0.15),
              child: const Icon(Icons.warning, color: Colors.red, size: 16),
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
            onTap: () => context.push('/ai-investigator'),
          ),
        )),
      ],
    );
  }

  Widget _buildRecentTimeline(ThemeData theme) {
    final events = [
      {'icon': Icons.phone, 'text': 'Call from +91 98765 43210 blocked', 'time': '2m ago', 'color': Colors.red},
      {'icon': Icons.sms, 'text': 'SMS from KYC-ALERT analyzed', 'time': '15m ago', 'color': Colors.orange},
      {'icon': Icons.check_circle, 'text': 'UPI to merchant@upi verified', 'time': '1h ago', 'color': Colors.green},
      {'icon': Icons.link, 'text': 'Link bit.ly/xxx flagged as phishing', 'time': '3h ago', 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Threat Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ...events.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(e['icon'] as IconData, color: e['color'] as Color, size: 18),
                  Container(width: 1, height: 20, color: Colors.grey[800]),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e['text'] as String, style: const TextStyle(fontSize: 12)),
                    Text(e['time'] as String, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _ProtectionCard {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  _ProtectionCard(this.name, this.subtitle, this.icon, this.color, this.route);
}