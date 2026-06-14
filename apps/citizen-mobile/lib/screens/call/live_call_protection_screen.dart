import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class LiveCallProtectionScreen extends StatefulWidget {
  const LiveCallProtectionScreen({super.key});
  @override
  State<LiveCallProtectionScreen> createState() => _LiveCallProtectionScreenState();
}

class _LiveCallProtectionScreenState extends State<LiveCallProtectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  double riskScore = 35;
  final keywords = ['bank', 'verify', 'account', 'otp'];
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('+91 98765 43210', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Call Duration: 02:15', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.safeGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.safeGreen.withValues(alpha: 0.3))),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.safeGreen)),
              const SizedBox(width: 6), const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.safeGreen)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        // Waveform
        AnimatedBuilder(animation: _c, builder: (context, child) {
          return Container(height: 80, decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
            child: CustomPaint(painter: _WaveformPainter(_c.value, AppTheme.cyberBlue.withValues(alpha: 0.5)), size: const Size(double.infinity, 80)));
        }),
        const SizedBox(height: 16),
        // Detected Keywords
        SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: keywords.map((k) => Container(
          margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3))),
          child: Text(k, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.dangerRed)),
        )).toList())),
        const SizedBox(height: 20),
        // Risk Score
        const Text('Live Risk Score', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Row(children: [
          const RiskMeter(score: 35, size: 80, showLabel: false),
          const SizedBox(width: 20),
          Expanded(child: CyberCard(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _row('Audio Analysis', 'Running', AppTheme.safeGreen),
            _row('Keyword Detection', 'Active', AppTheme.cyberBlue),
            _row('Intent Analysis', 'Monitoring', AppTheme.warningOrange),
          ]))),
        ]),
        const SizedBox(height: 20),
        const Text('AI Pipeline', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _pipeItem('Audio'), Icon(Icons.arrow_forward, size: 14, color: AppTheme.textDim),
            _pipeItem('STT'), Icon(Icons.arrow_forward, size: 14, color: AppTheme.textDim),
            _pipeItem('Keywords'), Icon(Icons.arrow_forward, size: 14, color: AppTheme.textDim),
            _pipeItem('Intent'), Icon(Icons.arrow_forward, size: 14, color: AppTheme.textDim),
            _pipeItem('Risk'),
          ])),
        const SizedBox(height: 16),
        CyberButton(label: 'End Call', icon: Icons.call_end, color: AppTheme.dangerRed, onPressed: () => context.go('/call/summary')),
      ]))),
    );
  }
  Widget _row(String label, String status, Color color) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
    Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    const Spacer(), Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  ]));
  Widget _pipeItem(String label) => Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary));
}

class _WaveformPainter extends CustomPainter {
  final double phase; final Color color;
  _WaveformPainter(this.phase, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2;
    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height / 2 + (size.height / 4) * (x.sin() + (x * 0.05 + phase * 3).sin() + (x * 0.02 + phase).cos());
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension on double { double sin() => (this * 0.1).sin(); double cos() => (this * 0.1).cos(); }