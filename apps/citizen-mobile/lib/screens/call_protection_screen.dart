import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_theme.dart';

class CallProtectionScreen extends StatefulWidget {
  const CallProtectionScreen({super.key});

  @override
  State<CallProtectionScreen> createState() => _CallProtectionScreenState();
}

class _CallProtectionScreenState extends State<CallProtectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final bool _isAnalyzing = false;
  final double _riskScore = 45;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Call Protection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusSection(),
            _buildLiveAnalysis(),
            _buildRecentCalls(),
            _buildSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: AppTheme.neonBorder(
        color: _riskScore > 70 ? AppTheme.dangerRed : AppTheme.successGreen,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Protection Status', style: Theme.of(context).textTheme.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppTheme.successGreen),
                    SizedBox(width: 6),
                    Text('Active', style: TextStyle(color: AppTheme.successGreen, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: [
                // Wave animation rings
                ...List.generate(3, (i) => Container(
                  width: 160 + i * 40,
                  height: 160 + i * 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.successGreen.withValues(alpha: 0.3 - i * 0.1),
                      width: 1.5,
                    ),
                  ),
                )),
                // Center icon
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.phone_in_talk, color: AppTheme.successGreen, size: 35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Protection Active', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.successGreen)),
          Text('All calls are being monitored', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildLiveAnalysis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Analysis', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Container(
            decoration: AppTheme.glassCard(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.successGreen, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Real-Time Detection Active', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMetricRow('Calls Analyzed Today', '5', AppTheme.primaryBlue),
                const Divider(color: AppTheme.borderColor),
                _buildMetricRow('Fraud Calls Blocked', '2', AppTheme.dangerRed),
                const Divider(color: AppTheme.borderColor),
                _buildMetricRow('Safe Calls', '3', AppTheme.successGreen),
                const Divider(color: AppTheme.borderColor),
                _buildMetricRow('Spam Detected', '1', AppTheme.warningOrange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCalls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Calls', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _buildCallItem('+91 98765 43210', '2 min ago', 'High Risk', AppTheme.dangerRed, Icons.warning),
          _buildCallItem('+91 87654 32109', '15 min ago', 'Safe', AppTheme.successGreen, Icons.check_circle),
          _buildCallItem('+91 76543 21098', '1 hour ago', 'Spam', AppTheme.warningOrange, Icons.report),
          _buildCallItem('+91 65432 10987', '2 hours ago', 'Safe', AppTheme.successGreen, Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildCallItem(String number, String time, String status, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppTheme.glassCard(),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number, style: Theme.of(context).textTheme.titleMedium),
                Text(time, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.glassCard(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Protection Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Auto-block Fraud Calls'),
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppTheme.primaryBlue,
            ),
            SwitchListTile(
              title: const Text('Deepfake Voice Detection'),
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppTheme.primaryBlue,
            ),
            SwitchListTile(
              title: const Text('Record Suspicious Calls'),
              value: false,
              onChanged: (v) {},
              activeThumbColor: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}