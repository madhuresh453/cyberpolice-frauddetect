import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../themes/raksaar_theme.dart';

class IncomingCallScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? callerName;

  const IncomingCallScreen({super.key, this.phoneNumber, this.callerName});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final number = widget.phoneNumber ?? '+91 98765 43210';
    final name = widget.callerName ?? 'Unknown Number';

    // Risk analysis (mock)
    final riskScore = 85;
    final isHighRisk = riskScore > 60;

    return Scaffold(
      backgroundColor: isHighRisk ? Colors.red.withValues(alpha: 0.08) : theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Incoming call header
            const Text('Incoming Call', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),

            // Caller avatar
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (ctx, child) => Container(
                width: 100 + (_pulseAnim.value * 20),
                height: 100 + (_pulseAnim.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isHighRisk
                        ? [Colors.red.withValues(alpha: 0.6), Colors.red.withValues(alpha: 0.2)]
                        : [Colors.green.withValues(alpha: 0.6), Colors.green.withValues(alpha: 0.2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isHighRisk ? Colors.red : Colors.green).withValues(alpha: 0.3),
                      blurRadius: 30 + (_pulseAnim.value * 20),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  isHighRisk ? Icons.warning_amber_rounded : Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Number
            Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(color: Colors.grey[500], fontSize: 16)),

            const SizedBox(height: 20),

            // Risk card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isHighRisk ? Colors.red.withValues(alpha: 0.12) : Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHighRisk ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    isHighRisk ? '⚠ High Risk Detected' : '✓ Safe Call',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isHighRisk ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Risk Score: $riskScore/100',
                      style: TextStyle(color: isHighRisk ? Colors.red : Colors.green)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Risk factors
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _factorRow('Spam Reports', 'High', Colors.red),
                  _factorRow('Scam History', 'Found', Colors.red),
                  _factorRow('Fake KYC Pattern', 'Detected', Colors.red),
                  _factorRow('Caller Verified', 'Unknown', Colors.orange),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.call_end),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/call/analysis', extra: {'phone': number}),
                        icon: const Icon(Icons.call),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _factorRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}