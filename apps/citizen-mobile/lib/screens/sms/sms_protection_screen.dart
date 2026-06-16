import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../themes/raksaar_theme.dart';

class SmsProtectionScreen extends ConsumerStatefulWidget {
  const SmsProtectionScreen({super.key});

  @override
  ConsumerState<SmsProtectionScreen> createState() => _SmsProtectionScreenState();
}

class _SmsProtectionScreenState extends ConsumerState<SmsProtectionScreen> {
  final List<MockSms> _messages = MockSms.generate();
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filter == 'all'
        ? _messages
        : _messages.where((m) => m.risk == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Protection'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, size: 12, color: Colors.green),
                SizedBox(width: 4),
                Text('Active', style: TextStyle(color: Colors.green, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', 'all', Colors.blue),
                  const SizedBox(width: 8),
                  _filterChip('Safe', 'safe', Colors.green),
                  const SizedBox(width: 8),
                  _filterChip('Suspicious', 'suspicious', Colors.orange),
                  const SizedBox(width: 8),
                  _filterChip('Dangerous', 'dangerous', Colors.red),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Messages
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey[500]),
                        const SizedBox(height: 12),
                        Text('No messages', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _buildSmsCard(filtered[i], theme),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, Color color) {
    final selected = _filter == value;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.grey)),
      selected: selected,
      onSelected: (v) => setState(() => _filter = value),
      selectedColor: color.withValues(alpha: 0.7),
      backgroundColor: Colors.grey.withValues(alpha: 0.1),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildSmsCard(MockSms sms, ThemeData theme) {
    Color riskColor;
    switch (sms.risk) {
      case 'safe': riskColor = Colors.green; break;
      case 'suspicious': riskColor = Colors.orange; break;
      case 'dangerous': riskColor = Colors.red; break;
      default: riskColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(sms.sender,
                      style: TextStyle(color: riskColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(sms.risk.toUpperCase(),
                      style: TextStyle(color: riskColor, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(sms.body, style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(sms.time, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class MockSms {
  final String sender;
  final String body;
  final String risk;
  final String time;

  MockSms({required this.sender, required this.body, required this.risk, required this.time});

  static List<MockSms> generate() {
    return [
      MockSms(sender: 'AD-LOAN', body: 'Congratulations! You are pre-approved for ₹5,00,000 loan. Low interest. Apply now.', risk: 'suspicious', time: '2 min ago'),
      MockSms(sender: 'HDFC-BK', body: 'Your HDFC account is about to be blocked. Update KYC immediately: hdfc-verify.cc', risk: 'dangerous', time: '5 min ago'),
      MockSms(sender: 'Delivery-PT', body: 'Your package is out for delivery. Track here: bit.ly/track-123', risk: 'suspicious', time: '12 min ago'),
      MockSms(sender: 'MESSAGE', body: 'OTP 48291 for your Paytm transaction. Do not share.', risk: 'safe', time: '18 min ago'),
      MockSms(sender: 'SBI-ALERT', body: 'Your SBI account login from new device. If not you, block: sbisecure.cc', risk: 'dangerous', time: '25 min ago'),
      MockSms(sender: 'AMAZON', body: 'Genuine order confirmation - Your item will arrive tomorrow', risk: 'safe', time: '1 hour ago'),
      MockSms(sender: 'VK-BANKAL', body: 'Alert: Your account has been compromised. Call 1800-XXX-XXXX immediately', risk: 'dangerous', time: '2 hours ago'),
      MockSms(sender: 'IRCTC', body: 'Your train ticket is confirmed. PNR: 1234567890', risk: 'safe', time: '3 hours ago'),
    ];
  }
}