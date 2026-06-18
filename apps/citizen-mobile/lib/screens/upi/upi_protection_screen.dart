import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../themes/app_theme.dart';
import '../../api/api_client.dart';

class UpiProtectionScreen extends ConsumerStatefulWidget {
  const UpiProtectionScreen({super.key});
  @override
  ConsumerState<UpiProtectionScreen> createState() => _UpiProtectionScreenState();
}

class _UpiProtectionScreenState extends ConsumerState<UpiProtectionScreen> {
  final _upiController = TextEditingController();
  bool _isChecking = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _checkUpi() async {
    final upi = _upiController.text.trim();
    if (upi.isEmpty) return;

    setState(() { _isChecking = true; _result = null; });

    try {
      final api = ApiClient();
      final response = await api.checkUpiReputation(upi);
      setState(() {
        _result = response.data;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _result = {'error': true, 'message': 'Lookup failed: $e', 'score': 0, 'risk_level': 'unknown'};
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(title: const Text('UPI Fraud Protection')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.primaryBlue.withValues(alpha: 0.1), AppTheme.primaryBlue.withValues(alpha: 0.02)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: const Column(children: [
          Icon(Icons.payments, size: 48, color: AppTheme.primaryBlue),
          SizedBox(height: 12),
          Text('UPI Protection Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('Verify any UPI ID before sending money', style: TextStyle(color: AppTheme.textSecondary)),
        ]),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _upiController,
        decoration: InputDecoration(
          labelText: 'Enter UPI ID (name@upi)',
          prefixIcon: const Icon(Icons.payments, color: AppTheme.primaryBlue),
          suffixIcon: _isChecking
            ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : IconButton(icon: const Icon(Icons.search), onPressed: _checkUpi),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        onSubmitted: (_) => _checkUpi(),
      ),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        onPressed: _isChecking ? null : _checkUpi,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR to Verify'),
      )),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: OutlinedButton(
        onPressed: () => context.push('/ai-investigator'),
        child: const Text('Check Merchant Status'),
      )),
      if (_result != null) ...[
        const SizedBox(height: 16),
        _buildResultCard(),
      ],
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Transaction History', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _txnItem('₹15,000', 'UPI transfer', AppTheme.successGreen),
          _txnItem('₹50,000', 'Suspicious merchant', AppTheme.dangerRed),
          _txnItem('₹2,500', 'QR payment', AppTheme.successGreen),
          _txnItem('₹1,00,000', 'Unknown UPI ID', AppTheme.warningOrange),
        ]),
      ),
    ]),
  );

  Widget _buildResultCard() {
    final result = _result!;
    final score = result['score'] ?? result['trust_score'] ?? 0;
    final riskLevel = result['risk_level'] ?? 'unknown';
    final color = riskLevel == 'high' ? Colors.red : riskLevel == 'medium' ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(result['error'] == true ? Icons.error : Icons.verified_user, color: color, size: 20),
            const SizedBox(width: 8),
            Text('Risk Score: $score', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('$riskLevel'.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ]),
          if (result['message'] != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${result['message']}', style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => context.push('/report'),
              style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
              child: Text('Report', style: TextStyle(color: color, fontSize: 12)),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _txnItem(String amount, String desc, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.payments, color: color, size: 18)),
      const SizedBox(width: 10),
      Expanded(child: Text(desc, style: const TextStyle(color: AppTheme.textPrimary))),
      Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    ]),
  );
}