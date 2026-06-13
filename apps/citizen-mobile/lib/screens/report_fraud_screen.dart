import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_theme.dart';
import '../repositories/trust_score_repository.dart';

class ReportFraudScreen extends ConsumerStatefulWidget {
  const ReportFraudScreen({super.key});
  @override
  ConsumerState<ReportFraudScreen> createState() => _ReportFraudScreenState();
}

class _ReportFraudScreenState extends ConsumerState<ReportFraudScreen> {
  String? _selectedType;
  final _numberController = TextEditingController();
  final _detailsController = TextEditingController();
  final _amountController = TextEditingController();
  bool _submitting = false;
  final List<String> _evidencePaths = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _numberController.dispose();
    _detailsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (kIsWeb) return;
    final image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() => _evidencePaths.add(image.path));
    }
  }

  Future<void> _submit() async {
    if (_selectedType == null || _numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all required fields'), backgroundColor: AppTheme.warningOrange));
      return;
    }
    setState(() => _submitting = true);
    try {
      final repo = ref.read(trustScoreRepositoryProvider);
      switch (_selectedType) {
        case 'CALL':
          await repo.reportCall({
            'phone_number': _numberController.text,
            'notes': _detailsController.text,
            'type': 'CALL',
          });
          break;
        case 'SMS':
          await repo.reportSms({
            'sender': _numberController.text,
            'message': _detailsController.text,
            'type': 'SMS',
          });
          break;
        case 'WHATSAPP':
          await repo.reportWhatsapp({
            'sender': _numberController.text,
            'message': _detailsController.text,
            'type': 'WHATSAPP',
          });
          break;
        default:
          await repo.reportCall({
            'phone_number': _numberController.text,
            'notes': _detailsController.text,
            'type': _selectedType ?? 'CALL',
          });
      }
      if (mounted) context.go('/report-submitted');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.dangerRed));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Report Fraud')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Select fraud type', style: TextStyle(color: AppTheme.textSecondary)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _typeChip('CALL', 'Fraud Call', Icons.phone, AppTheme.dangerRed),
        _typeChip('SMS', 'Fraud SMS', Icons.sms, AppTheme.warningOrange),
        _typeChip('WHATSAPP', 'WhatsApp', Icons.chat, AppTheme.successGreen),
        _typeChip('UPI', 'UPI Fraud', Icons.payments, AppTheme.primaryBlue),
        _typeChip('WEBSITE', 'Phishing', Icons.language, const Color(0xFF8B5CF6)),
        _typeChip('APP', 'Fake App', Icons.android, AppTheme.dangerRed),
      ]),
      const SizedBox(height: 20),
      TextField(controller: _numberController, decoration: const InputDecoration(labelText: 'Suspect Number/ID *', prefixIcon: Icon(Icons.person)), keyboardType: TextInputType.phone),
      const SizedBox(height: 16),
      if (_selectedType == 'UPI') ...[
        TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.payments)), keyboardType: TextInputType.number),
        const SizedBox(height: 16),
      ],
      TextField(controller: _detailsController, decoration: const InputDecoration(labelText: 'Details', prefixIcon: Icon(Icons.description), alignLabelWithHint: true), maxLines: 3),
      const SizedBox(height: 20),
      Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Evidence', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _evidenceButton(Icons.camera_alt, 'Camera', () => _pickImage(ImageSource.camera)),
          _evidenceButton(Icons.photo_library, 'Gallery', () => _pickImage(ImageSource.gallery)),
          _evidenceButton(Icons.mic, 'Record', () {}),
        ]),
        if (_evidencePaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(height: 60, child: ListView.builder(
            scrollDirection: Axis.horizontal, itemCount: _evidencePaths.length,
            itemBuilder: (_, i) => Stack(children: [
              Container(width: 60, height: 60, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppTheme.borderColor), child: const Icon(Icons.image, color: AppTheme.textSecondary)),
              Positioned(top: -4, right: 2, child: GestureDetector(onTap: () => setState(() => _evidencePaths.removeAt(i)), child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppTheme.dangerRed, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)))),
            ]),
          )),
        ],
      ])),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Report'),
      )),
    ]),
  );

  Widget _typeChip(String type, String label, IconData icon, Color color) {
    final selected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: selected ? color.withValues(alpha: 0.2) : AppTheme.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? color : AppTheme.borderColor, width: selected ? 2 : 1)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Text(label, style: TextStyle(color: selected ? color : AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13))]),
      ),
    );
  }

  Widget _evidenceButton(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppTheme.primaryBlue, size: 22)),
      const SizedBox(height: 4), Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
    ]),
  );
}