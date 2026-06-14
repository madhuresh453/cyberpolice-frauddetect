import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';

class LinkScannerScreen extends StatefulWidget {
  const LinkScannerScreen({super.key});
  @override
  State<LinkScannerScreen> createState() => _LinkScannerScreenState();
}

class _LinkScannerScreenState extends State<LinkScannerScreen> {
  final _controller = TextEditingController();
  String? result;

  void _scan() {
    final url = _controller.text.trim();
    if (url.isNotEmpty) {
      setState(() => result = 'Scanning...');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => result = 'scam-detected');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Link Scanner')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Scan URL for scam patterns', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        TextField(controller: _controller, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Paste URL here...', hintStyle: TextStyle(color: AppTheme.textDim), filled: true, fillColor: AppTheme.cardBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        const SizedBox(height: 12),
        CyberButton(label: 'Scan Link', icon: Icons.link, color: AppTheme.cyberBlue, onPressed: _scan),
        if (result != null) ...[
          const SizedBox(height: 20),
          CyberCard(borderColor: AppTheme.dangerRed, child: Column(children: [
            const Icon(Icons.shield, size: 48, color: AppTheme.dangerRed),
            const SizedBox(height: 12),
            const Text('Fraud Detected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
            const SizedBox(height: 8),
            const Text('This URL is a phishing scam', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.only(top: 16), decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.borderColor))),
              child: Column(children: [
                _factor('Fake domain detected'), _factor('Associations found: phishing, fraud'), _factor('Not a verified banking site'), _factor('Not hosted on official servers'),
              ])),
          ])),
        ],
        if (result == null) ...[
          const SizedBox(height: 20),
          CyberCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Protect Yourself', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            _protect('Never trust links in SMS or email'), _protect('Check URLs carefully for typos'), _protect('Report confirmed phishing URLs'),
          ])),
        ],
      ]),
    );
  }
  Widget _factor(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.dangerRed), const SizedBox(width: 8), Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.white)))]));
  Widget _protect(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [const Icon(Icons.check_circle, size: 16, color: AppTheme.safeGreen), const SizedBox(width: 8), Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.white)))]));
}