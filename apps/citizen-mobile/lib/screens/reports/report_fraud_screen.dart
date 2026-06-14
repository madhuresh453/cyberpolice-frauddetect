import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class ReportFraudScreen extends StatefulWidget {
  const ReportFraudScreen({super.key});
  @override
  State<ReportFraudScreen> createState() => _ReportFraudScreenState();
}

class _ReportFraudScreenState extends State<ReportFraudScreen> {
  String selectedType = 'Phone Scam';
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();

  final types = [
    ('Phone Scam', Icons.phone, AppTheme.dangerRed),
    ('SMS Spam', Icons.message, AppTheme.warningOrange),
    ('UPI Fraud', Icons.payments, AppTheme.dangerRed),
    ('Phishing Link', Icons.link, AppTheme.warningOrange),
    ('Fake App', Icons.android, AppTheme.dangerRed),
    ('WhatsApp Scam', Icons.chat, AppTheme.warningOrange),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Report Fraud')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Select Fraud Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: types.map((t) => GestureDetector(
            onTap: () => setState(() => selectedType = t.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selectedType == t.$1 ? t.$3.withValues(alpha: 0.15) : AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedType == t.$1 ? t.$3 : AppTheme.borderColor, width: selectedType == t.$1 ? 2 : 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(t.$2, size: 18, color: selectedType == t.$1 ? t.$3 : AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(t.$1, style: TextStyle(fontSize: 13, color: selectedType == t.$1 ? t.$3 : AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              ]),
            ),
          )).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Fraudster Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '+91 XXXXX XXXXX',
            hintStyle: TextStyle(color: AppTheme.textDim),
            filled: true,
            fillColor: AppTheme.cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Describe the Scam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'What happened? What did they say?',
            hintStyle: TextStyle(color: AppTheme.textDim),
            filled: true,
            fillColor: AppTheme.cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Text('Evidence from the selected channel will be attached automatically', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
        const SizedBox(height: 20),
        CyberButton(label: 'Submit Report', icon: Icons.send, color: AppTheme.safeGreen, onPressed: () => context.go('/report/success')),
        const SizedBox(height: 16),
      ]),
    );
  }
}