import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class IncomingCallScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? callerName;
  const IncomingCallScreen({super.key, this.phoneNumber, this.callerName});
  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  double riskScore = 0;
  bool analyzing = true;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _simulate();
  }

  void _simulate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { riskScore = 85; analyzing = false; });
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final danger = riskScore > 50;
    final color = danger ? AppTheme.dangerRed : AppTheme.safeGreen;
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Incoming Call', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              StatusBadge(label: 'LIVE', color: AppTheme.dangerRed),
            ]),
            const SizedBox(height: 20),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                PulseContainer(size: 120, color: analyzing ? AppTheme.cyberBlue : color,
                  child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: (analyzing ? AppTheme.cyberBlue : color).withValues(alpha: 0.15), border: Border.all(color: (analyzing ? AppTheme.cyberBlue : color).withValues(alpha: 0.5), width: 2)),
                    child: Icon(analyzing ? Icons.radar : (danger ? Icons.warning_rounded : Icons.check_circle), size: 40, color: analyzing ? AppTheme.cyberBlue : color))),
                const SizedBox(height: 24),
                Text(widget.phoneNumber ?? '+91 98765 43210', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(widget.callerName ?? 'Unknown Number', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 24),
                if (analyzing) ...[
                  const AiAnalysisIndicator(message: 'Analyzing caller...'),
                ] else ...[
                  CyberCard(borderColor: color, child: Column(children: [
                    Text('Risk Score: ${riskScore.toInt()}/100', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 8),
                    Text(danger ? 'High Risk Detected' : 'Safe Call', style: TextStyle(fontSize: 14, color: color)),
                    const SizedBox(height: 12),
                    if (danger) ...[
                      _riskFactor('Spam reports', AppTheme.dangerRed),
                      _riskFactor('Scam history', AppTheme.dangerRed),
                      _riskFactor('Fake KYC behavior', AppTheme.warningOrange),
                    ],
                  ])),
                ],
              ]),
            ),
            if (!analyzing) Row(children: [
              Expanded(child: CyberButton(label: danger ? 'Reject' : 'Accept', color: danger ? AppTheme.dangerRed : AppTheme.safeGreen, icon: danger ? Icons.call_end : Icons.call,
                onPressed: () => context.go(danger ? '/call/high-risk' : '/call/safe'))),
              const SizedBox(width: 12),
              Expanded(child: CyberButton(label: 'Report', color: AppTheme.warningOrange, icon: Icons.report,
                onPressed: () => context.go('/report'))),
            ]),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _riskFactor(String text, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
      Icon(Icons.warning_amber_rounded, size: 14, color: color),
      const SizedBox(width: 6),
      Text(text, style: TextStyle(fontSize: 12, color: color)),
    ]));
  }
}

// Simple AI analysis indicator
class AiAnalysisIndicator extends StatefulWidget {
  final String message;
  const AiAnalysisIndicator({super.key, required this.message});
  @override
  State<AiAnalysisIndicator> createState() => _AiAnalysisIndicatorState();
}
class _AiAnalysisIndicatorState extends State<AiAnalysisIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _c, builder: (context, child) => Column(children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle,
        border: Border.all(color: AppTheme.cyberBlue.withValues(alpha: 0.3 + (_c.value * 0.7)), width: 3),
        boxShadow: [BoxShadow(color: AppTheme.cyberBlue.withValues(alpha: 0.1 * _c.value), blurRadius: 20 + (_c.value * 20))]),
        child: const Icon(Icons.radar, size: 36, color: AppTheme.cyberBlue)),
      const SizedBox(height: 16),
      Text(widget.message, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
    ]));
  }
}