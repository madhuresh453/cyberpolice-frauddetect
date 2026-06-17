import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart';
import '../../themes/raksaar_theme.dart';
import '../../core/config/app_config.dart';

final aiAnalysisProvider = StateProvider<String?>((ref) => null);
final aiResultProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, text) async {
  final api = ApiClient();
  final response = await api.analyzeText(text);
  return response.data;
});

class AiInvestigatorScreen extends ConsumerStatefulWidget {
  const AiInvestigatorScreen({super.key});

  @override
  ConsumerState<AiInvestigatorScreen> createState() => _AiInvestigatorScreenState();
}

class _AiInvestigatorScreenState extends ConsumerState<AiInvestigatorScreen> {
  final _textController = TextEditingController();
  String _analysisType = 'text';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultAsync = _textController.text.isNotEmpty
        ? ref.watch(aiResultProvider(_textController.text))
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Investigator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'text', label: Text('Text'), icon: Icon(Icons.text_fields, size: 16)),
                ButtonSegment(value: 'sms', label: Text('SMS'), icon: Icon(Icons.message, size: 16)),
                ButtonSegment(value: 'call', label: Text('Call'), icon: Icon(Icons.phone, size: 16)),
                ButtonSegment(value: 'url', label: Text('URL'), icon: Icon(Icons.link, size: 16)),
              ],
              selected: {_analysisType},
              onSelectionChanged: (v) => setState(() => _analysisType = v.first),
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: _analysisType == 'text' ? 'Paste suspicious message or call transcript...' :
                          _analysisType == 'sms' ? 'Paste suspicious SMS text...' :
                          _analysisType == 'call' ? 'Paste call transcript...' :
                          'Paste suspicious URL...',
                alignLabelWithHint: true,
              ),
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                  ref.invalidate(aiResultProvider(_textController.text));
                },
                icon: const Icon(Icons.radar),
                label: const Text('Analyze with AI'),
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: resultAsync?.when(
                data: (result) => _AnalysisResultCard(result: result, theme: theme),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, size: 48, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      Text('Connect to AI Gateway', style: TextStyle(color: Colors.grey[500])),
                      Text(AppConfig.aiBaseUrl, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                ),
              ) ?? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radar, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text('Enter text above to analyze', style: TextStyle(color: Colors.grey[500])),
                    Text('Powered by CyberShield AI', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final ThemeData theme;
  const _AnalysisResultCard({required this.result, required this.theme});

  @override
  Widget build(BuildContext context) {
    final scamType = result['primary_scam_type'] as String? ?? 'Unknown';
    final riskScore = (result['risk_score'] as num?)?.toInt() ?? 0;
    final keywords = (result['keywords_found'] as List?) ?? [];
    final color = riskScore >= 70 ? RaksaarColors.riskCritical :
                 riskScore >= 40 ? RaksaarColors.riskHigh :
                 RaksaarColors.riskSafe;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.radar, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Risk Assessment', style: theme.textTheme.titleSmall),
                      Text(result['verdict'] as String? ?? scamType,
                          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$riskScore%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ],
            ),
            if (keywords.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              Text('Detected Indicators', style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: keywords.map((k) => Chip(
                  label: Text(k.toString(), style: const TextStyle(fontSize: 12)),
                  backgroundColor: RaksaarColors.riskCritical.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                )).toList(),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => context.push('/report'),
                icon: const Icon(Icons.description, size: 16),
                label: const Text('View Full Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}