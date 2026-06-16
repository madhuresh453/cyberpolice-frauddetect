import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/monitor_provider.dart';
import '../../themes/raksaar_theme.dart';

class MonitorCenter extends ConsumerStatefulWidget {
  const MonitorCenter({super.key});

  @override
  ConsumerState<MonitorCenter> createState() => _MonitorCenterState();
}

class _MonitorCenterState extends ConsumerState<MonitorCenter> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(monitorProvider.notifier).startMonitoring());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = ref.watch(monitorProvider);
    final events = ref.read(monitorProvider.notifier).events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protection Center'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.green, size: 10),
                SizedBox(width: 4),
                Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats Grid
            _buildStatsGrid(theme, stats),
            const SizedBox(height: 20),

            // Threat Timeline Header
            Row(
              children: [
                Icon(Icons.timeline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Live Threat Feed', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),

            // Events list
            if (events.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.shield_outlined, size: 48, color: Colors.grey[500]),
                        const SizedBox(height: 12),
                        Text('No threats detected', style: TextStyle(color: Colors.grey[500])),
                        Text('Your protection is active', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...events.take(20).map((event) => _buildThreatCard(event, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, MonitorStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _statCard(Icons.phone_in_talk, 'Active Calls', '${stats.activeCalls}',
            Colors.blue, theme),
        _statCard(Icons.sms, 'SMS Scanned', '${stats.smsScannedToday}',
            Colors.green, theme),
        _statCard(Icons.block, 'Threats Blocked', '${stats.threatsBlocked}',
            Colors.red, theme),
        _statCard(Icons.shield, 'Scam Numbers', '${stats.scamNumbersDetected}',
            Colors.orange, theme),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color, ThemeData theme) {
    return Card(
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
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatCard(ThreatEvent event, ThemeData theme) {
    Color riskColor;
    switch (event.status) {
      case 'safe': riskColor = Colors.green; break;
      case 'suspicious': riskColor = Colors.orange; break;
      case 'dangerous': riskColor = Colors.red; break;
      case 'blocked': riskColor = Colors.red; break;
      default: riskColor = Colors.grey;
    }

    IconData typeIcon;
    switch (event.type) {
      case 'call': typeIcon = Icons.phone; break;
      case 'sms': typeIcon = Icons.message; break;
      case 'whatsapp': typeIcon = Icons.chat; break;
      case 'upi': typeIcon = Icons.payments; break;
      case 'link': typeIcon = Icons.link; break;
      default: typeIcon = Icons.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: riskColor.withValues(alpha: 0.15),
          child: Icon(typeIcon, color: riskColor, size: 20),
        ),
        title: Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(
          '${event.type.toUpperCase()} • ${_formatTime(event.timestamp)}',
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: riskColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${event.riskScore}%',
            style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}