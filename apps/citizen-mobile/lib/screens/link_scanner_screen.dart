import 'package:flutter/material.dart';
import '../themes/raksaar_theme.dart';

class LinkScannerScreen extends StatefulWidget {
  const LinkScannerScreen({super.key});

  @override
  State<LinkScannerScreen> createState() => _LinkScannerScreenState();
}

class _LinkScannerScreenState extends State<LinkScannerScreen> {
  final _urlCtrl = TextEditingController();
  bool _scanning = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  void _scan() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _scanning = true;
      _result = null;
    });

    // Simulate scan delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock analysis
    final isSuspicious = url.contains('verify') || url.contains('update') || url.contains('bank');
    final isSecure = url.startsWith('https');
    final domainAge = isSuspicious ? '2 days' : '3 years';

    setState(() {
      _scanning = false;
      _result = {
        'url': url,
        'riskScore': isSuspicious ? 85 : (isSecure ? 10 : 40),
        'hasSSL': isSecure,
        'domainAge': domainAge,
        'isPhishing': isSuspicious,
        'isReported': isSuspicious,
        'threats': isSuspicious ? ['Phishing detected', 'Newly registered', 'Suspicious domain', 'Reported by community'] : ['No threats detected'],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Link Scanner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Input
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.link, size: 40, color: Colors.blue),
                const SizedBox(height: 12),
                TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Paste suspicious link here',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _scan(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _scanning ? null : _scan,
                    icon: _scanning
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.security),
                    label: Text(_scanning ? 'Scanning...' : 'Scan Link'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Results
          if (_result != null) ...[
            // Risk card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (_result!['riskScore'] as int) > 60
                    ? Colors.red.withValues(alpha: 0.1)
                    : (_result!['riskScore'] as int) > 30
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (_result!['riskScore'] as int) > 60
                      ? Colors.red
                      : (_result!['riskScore'] as int) > 30
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    (_result!['riskScore'] as int) > 60
                        ? Icons.dangerous
                        : Icons.check_circle,
                    size: 48,
                    color: (_result!['riskScore'] as int) > 60
                        ? Colors.red
                        : (_result!['riskScore'] as int) > 30
                            ? Colors.orange
                            : Colors.green,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (_result!['riskScore'] as int) > 60
                        ? 'Dangerous Link'
                        : (_result!['riskScore'] as int) > 30
                            ? 'Suspicious Link'
                            : 'Safe Link',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: (_result!['riskScore'] as int) > 60
                          ? Colors.red
                          : (_result!['riskScore'] as int) > 30
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Risk Score: ${_result!['riskScore']}/100',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Analysis Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _detailRow('URL', _result!['url']),
                    _detailRow('SSL Certificate', _result!['hasSSL'] ? 'Valid ✓' : 'Missing ✗'),
                    _detailRow('Domain Age', _result!['domainAge']),
                    _detailRow('Phishing Risk', _result!['isPhishing'] ? 'Yes ⚠' : 'No ✓'),
                    _detailRow('Community Reports', _result!['isReported'] ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Threats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Threats Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...(_result!['threats'] as List).map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            t == 'No threats detected' ? Icons.check_circle : Icons.warning,
                            color: t == 'No threats detected' ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(t.toString(), style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}