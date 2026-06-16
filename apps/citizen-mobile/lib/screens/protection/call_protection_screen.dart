import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import '../../themes/raksaar_theme.dart';

final callAnalysisProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, phoneNumber) async {
  final api = ApiClient();
  final response = await api.analyzeCall(phoneNumber);
  return response.data;
});

class CallProtectionScreen extends ConsumerWidget {
  final String? initialPhone;
  const CallProtectionScreen({super.key, this.initialPhone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Call Protection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: RaksaarColors.success,
                        boxShadow: [BoxShadow(color: RaksaarColors.success.withValues(alpha: 0.5), blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Call Protection Active', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text('Monitoring incoming calls in real-time', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch(value: true, onChanged: (v) {}),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Check Number', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // Phone number input
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Trigger analysis
                  },
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // Recent calls
            Text('Recent Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  _CallHistoryTile(
                    number: '+919XXXXXXXX',
                    risk: 92,
                    type: 'Incoming',
                    time: '2 min ago',
                  ),
                  _CallHistoryTile(
                    number: '+918XXXXXXXX', 
                    risk: 15,
                    type: 'Incoming',
                    time: '1 hour ago',
                  ),
                  _CallHistoryTile(
                    number: '+917XXXXXXXX',
                    risk: 65,
                    type: 'Missed',
                    time: '3 hours ago',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallHistoryTile extends StatelessWidget {
  final String number;
  final int risk;
  final String type;
  final String time;

  const _CallHistoryTile({
    required this.number,
    required this.risk,
    required this.type,
    required this.time,
  });

  Color _riskColor() {
    if (risk >= 80) return RaksaarColors.riskCritical;
    if (risk >= 50) return RaksaarColors.riskHigh;
    if (risk >= 30) return RaksaarColors.riskMedium;
    return RaksaarColors.riskSafe;
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(type == 'Missed' ? Icons.phone_missed : Icons.phone_in_talk, color: color, size: 20),
        ),
        title: Text(number, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('$type • $time'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$risk%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}