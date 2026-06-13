import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/app_theme.dart';
import '../repositories/trust_score_repository.dart';
import '../models/user_model.dart';
import '../providers/home_provider.dart';

class DigitalTrustScreen extends ConsumerStatefulWidget {
  const DigitalTrustScreen({super.key});
  @override
  ConsumerState<DigitalTrustScreen> createState() => _DigitalTrustScreenState();
}

class _DigitalTrustScreenState extends ConsumerState<DigitalTrustScreen> {
  final _searchController = TextEditingController();
  TrustScoreModel? _searchResult;
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _lookupTrust(String phone) async {
    if (phone.isEmpty) return;
    setState(() { _searching = true; _error = null; });
    try {
      final repo = ref.read(trustScoreRepositoryProvider);
      final score = await repo.getTrustScore(phone);
      setState(() { _searchResult = score; _searching = false; });
    } catch (e) {
      setState(() { _error = 'Lookup failed: $e'; _searching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final trustScore = homeState.trustScore;

    return Scaffold(
      backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Trust Score')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Trust score circle
        Container(decoration: AppTheme.neonBorder(color: _getScoreColor(trustScore?.score ?? 0)), padding: const EdgeInsets.all(24), child: Column(children: [
          SizedBox(height: 140, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 140, height: 140, child: CircularProgressIndicator(
              value: (trustScore?.score ?? 0) / 100, strokeWidth: 10,
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation(_getScoreColor(trustScore?.score ?? 0)),
            )),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${trustScore?.score ?? 0}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _getScoreColor(trustScore?.score ?? 0))),
              Text(trustScore?.status ?? 'Unknown', style: TextStyle(color: _getScoreColor(trustScore?.score ?? 0))),
            ]),
          ])),
          const SizedBox(height: 16),
          const Text('Your Digital Trust Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4), const Text('Based on your activity and reports', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ])),
        const SizedBox(height: 20),
        // Live lookup
        const Text('Verify a Number', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(
            controller: _searchController, keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Enter phone number', prefixIcon: Icon(Icons.phone)),
          )),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _searching ? null : () => _lookupTrust(_searchController.text.trim()),
            child: _searching ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Check'),
          ),
        ]),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppTheme.dangerRed, fontSize: 12)),
        ],
        if (_searchResult != null) ...[
          const SizedBox(height: 12),
          Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Row(children: [
            Icon(_searchResult!.score >= 70 ? Icons.check_circle : Icons.warning, color: _getScoreColor(_searchResult!.score), size: 32),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Score: ${_searchResult!.score}', style: TextStyle(color: _getScoreColor(_searchResult!.score), fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_searchResult!.status, style: const TextStyle(color: AppTheme.textSecondary)),
            ])),
          ])),
        ],
        const SizedBox(height: 20),
        // Score breakdown
        const Text('Score Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _factor('Total Reports', '${trustScore?.totalReports ?? 0}', trustScore?.totalReports ?? 0, AppTheme.primaryBlue),
        _factor('Risk Score', '${trustScore?.riskScore ?? 0}', (trustScore?.score ?? 0), _getScoreColor(100 - (trustScore?.score ?? 0))),
        _factor('Trust Level', '${trustScore?.score ?? 0}', trustScore?.score ?? 0, _getScoreColor(trustScore?.score ?? 0)),
      ]),
    );
  }

  Widget _factor(String label, String value, int score, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10), decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(14),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ])),
      Container(width: 50, height: 30, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text('$score', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)))),
    ]),
  );

  Color _getScoreColor(int score) {
    if (score >= 70) return AppTheme.successGreen;
    if (score >= 40) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }
}