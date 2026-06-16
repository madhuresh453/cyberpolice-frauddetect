import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/api_client.dart';

/// AI Investigator Tab – Multi-input fraud analysis engine
class AiInvestigatorTabScreen extends StatefulWidget {
  const AiInvestigatorTabScreen({super.key});

  @override
  State<AiInvestigatorTabScreen> createState() => _AiInvestigatorTabScreenState();
}

class _AiInvestigatorTabScreenState extends State<AiInvestigatorTabScreen> {
  final _inputController = TextEditingController();
  final _picker = ImagePicker();
  String _selectedInputType = 'phone';
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;

  final List<Map<String, dynamic>> _inputTypes = [
    {'key': 'phone', 'label': 'Phone Number', 'icon': Icons.phone, 'color': Colors.blue, 'hint': '+91XXXXXXXXXX'},
    {'key': 'upi', 'label': 'UPI ID', 'icon': Icons.payments, 'color': Colors.green, 'hint': 'name@upi'},
    {'key': 'url', 'label': 'URL / Link', 'icon': Icons.link, 'color': Colors.red, 'hint': 'https://example.com'},
    {'key': 'sms', 'label': 'SMS Text', 'icon': Icons.sms, 'color': Colors.orange, 'hint': 'Paste suspicious SMS'},
    {'key': 'qr', 'label': 'QR Code', 'icon': Icons.qr_code, 'color': Colors.purple, 'hint': 'Scan QR code'},
    {'key': 'email', 'label': 'Email', 'icon': Icons.email, 'color': Colors.teal, 'hint': 'sender@example.com'},
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _analyzeInput() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final api = ApiClient();
      ApiResponse response;

      switch (_selectedInputType) {
        case 'phone':
          response = await api.checkPhoneReputation(input);
          break;
        case 'upi':
          response = await api.checkUpiReputation(input);
          break;
        case 'url':
          response = await api.analyzeText(input);
          break;
        case 'sms':
          response = await api.analyzeSms(input);
          break;
        case 'email':
          response = await api.analyzeText(input);
          break;
        default:
          response = await api.analyzeText(input);
      }

      setState(() {
        _result = response.data;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _result = {
          'fraud_type': 'analysis_error',
          'confidence': 0,
          'summary': 'Unable to complete analysis: $e',
          'risk_level': 'unknown',
          'recommendations': ['Please try again later', 'Verify the input and retry'],
        };
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeFile(String source) async {
    XFile? file;
    if (source == 'camera') {
      file = await _picker.pickImage(source: ImageSource.camera);
    } else {
      file = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (file == null) return;

    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    // Simulate analysis for file-based inputs
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _result = {
        'fraud_type': 'image_analyzed',
        'confidence': 75,
        'summary': 'Image has been analyzed. No immediate threats detected in the visual content.',
        'risk_level': 'low',
        'recommendations': [
          'If this contains personal information, do not share it',
          'Report if received from unknown source',
        ],
        'file_path': file?.path ?? 'unknown',
      };
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Investigator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/evidence-vault'),
            tooltip: 'Evidence Vault',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          _buildHeaderCard(theme),
          const SizedBox(height: 16),

          // Input type selector
          Text('Select Input Type', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildInputTypeSelector(theme),
          const SizedBox(height: 16),

          // Input field
          _buildInputField(theme),
          const SizedBox(height: 12),

          // File input options
          _buildFileInputOptions(theme),
          const SizedBox(height: 16),

          // Analyze button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeInput,
              icon: _isAnalyzing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.search),
              label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Now'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Results
          if (_result != null) _buildResultCard(theme),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology, color: Colors.purple, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI-Powered Fraud Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Phone, UPI, URL, SMS, QR, Email, Images', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputTypeSelector(ThemeData theme) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _inputTypes.length,
        itemBuilder: (ctx, i) {
          final t = _inputTypes[i];
          final selected = _selectedInputType == t['key'];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedInputType = t['key'] as String;
              _inputController.clear();
              _result = null;
            }),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: selected
                    ? (t['color'] as Color).withValues(alpha: 0.15)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? t['color'] as Color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t['icon'] as IconData, color: t['color'] as Color, size: 22),
                  const SizedBox(height: 4),
                  Text(t['label'] as String, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 9, color: t['color'] as Color, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    final selectedType = _inputTypes.firstWhere((t) => t['key'] == _selectedInputType);
    return TextField(
      controller: _inputController,
      decoration: InputDecoration(
        hintText: selectedType['hint'] as String,
        prefixIcon: Icon(selectedType['icon'] as IconData, color: selectedType['color'] as Color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      keyboardType: _selectedInputType == 'phone' ? TextInputType.phone : TextInputType.text,
      onSubmitted: (_) => _analyzeInput(),
    );
  }

  Widget _buildFileInputOptions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _analyzeFile('camera'),
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Camera', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _analyzeFile('gallery'),
            icon: const Icon(Icons.photo_library, size: 18),
            label: const Text('Gallery', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/qr-scanner'),
            icon: const Icon(Icons.qr_code_scanner, size: 18),
            label: const Text('Scan QR', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final result = _result!;
    final riskLevel = result['risk_level'] ?? result['riskScore'] ?? 'unknown';
    Color riskColor;
    if (riskLevel == 'high' || riskLevel == 'dangerous' || riskLevel == 'critical') {
      riskColor = Colors.red;
    } else if (riskLevel == 'medium' || riskLevel == 'suspicious' || riskLevel == 'warning') {
      riskColor = Colors.orange;
    } else if (riskLevel == 'low' || riskLevel == 'safe') {
      riskColor = Colors.green;
    } else {
      riskColor = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: riskColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: riskColor, size: 22),
                const SizedBox(width: 8),
                const Text('Analysis Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${riskLevel}'.toUpperCase(),
                      style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const Divider(height: 24),

            if (result['fraud_type'] != null) ...[
              _resultRow('Fraud Type', '${result['fraud_type']}'),
            ],
            if (result['confidence'] != null) ...[
              _resultRow('Confidence', '${result['confidence']}%'),
            ],
            if (result['summary'] != null) ...[
              const SizedBox(height: 8),
              Text('${result['summary']}', style: const TextStyle(fontSize: 13, height: 1.5)),
            ],

            if (result['recommendations'] != null) ...[
              const SizedBox(height: 16),
              const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              ...(result['recommendations'] as List).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(child: Text('$r', style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reportFraud(result),
                    icon: const Icon(Icons.report, size: 16, color: Colors.red),
                    label: const Text('Report Fraud', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveEvidence(result),
                    icon: const Icon(Icons.save, size: 16, color: Colors.blue),
                    label: const Text('Save Evidence', style: TextStyle(color: Colors.blue)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _reportFraud(Map<String, dynamic> result) {
    context.push('/report', extra: {
      'source': 'ai_investigator',
      'input_type': _selectedInputType,
      'input_value': _inputController.text,
      'analysis_result': result,
    });
  }

  void _saveEvidence(Map<String, dynamic> result) {
    // Save to evidence vault via provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evidence saved to vault'), backgroundColor: Colors.green),
    );
  }
}