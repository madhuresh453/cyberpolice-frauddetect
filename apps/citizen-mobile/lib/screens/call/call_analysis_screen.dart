import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class CallAnalysisScreen extends StatefulWidget {
  final String? phoneNumber;
  const CallAnalysisScreen({super.key, this.phoneNumber});
  @override
  State<CallAnalysisScreen> createState() => _CallAnalysisScreenState();
}

class _CallAnalysisScreenState extends State<CallAnalysisScreen> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  int progress = 0;
  final steps = ['Checking Number Database', 'Voice Analysis', 'Keyword Detection', 'Scam Pattern Matching', 'Risk Calculation'];

  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true); _simulate(); }
  @override void dispose() { _c.dispose(); super.dispose(); }

  void _simulate() async {
    for (int i = 0; i <= steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => progress = i);
    }
    if (mounted) context.go('/call/high-risk');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 20),
        Row(children: [
          GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: Colors.white)),
          const Spacer(),
          const Text('Analyzing Call', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
        ]),
        const SizedBox(height: 40),
        AnimatedBuilder(animation: _c, builder: (context, child) {
          final v = _c.value;
          return Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: AppTheme.cyberBlue.withValues(alpha: 0.3 + (v * 0.7)), width: 3),
            boxShadow: [BoxShadow(color: AppTheme.cyberBlue.withValues(alpha: 0.1 * v), blurRadius: 20 + (v * 20))]),
            child: Center(child: Text('${(progress / steps.length * 100).toInt()}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.cyberBlue))));
        }),
        const SizedBox(height: 32),
        ...steps.asMap().entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
          Icon(e.key < progress ? Icons.check_circle : e.key == progress ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 20, color: e.key < progress ? AppTheme.safeGreen : e.key == progress ? AppTheme.cyberBlue : AppTheme.textDim),
          const SizedBox(width: 10),
          Text(e.value, style: TextStyle(color: e.key < progress ? AppTheme.safeGreen : e.key == progress ? Colors.white : AppTheme.textDim, fontSize: 13)),
        ]))),
        const SizedBox(height: 24),
        const Text('AI Pipeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _pipelineItem('Speech', Icons.hearing), const Icon(Icons.arrow_forward, size: 16, color: AppTheme.textDim),
            _pipelineItem('Text', Icons.text_fields), const Icon(Icons.arrow_forward, size: 16, color: AppTheme.textDim),
            _pipelineItem('NLP', Icons.psychology), const Icon(Icons.arrow_forward, size: 16, color: AppTheme.textDim),
            _pipelineItem('Risk', Icons.shield), const Icon(Icons.arrow_forward, size: 16, color: AppTheme.textDim),
            _pipelineItem('Alert', Icons.warning),
          ])),
      ]))),
    );
  }

  Widget _pipelineItem(String label, IconData icon) {
    return Column(children: [Icon(icon, size: 18, color: AppTheme.textSecondary), Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary))]);
  }
}