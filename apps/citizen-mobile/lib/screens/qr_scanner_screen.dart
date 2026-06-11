import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('QR Scanner')),
    body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 250, height: 250, decoration: BoxDecoration(border: Border.all(color: AppTheme.primaryBlue, width: 2), borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.qr_code_scanner, size: 80, color: AppTheme.primaryBlue))),
      const SizedBox(height: 24), const Text('Scan QR Code', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 8), const Text('Point camera at a QR code to verify', style: TextStyle(color: AppTheme.textSecondary)),
      const SizedBox(height: 32),
      ElevatedButton(onPressed: () {}, child: const Text('Open Camera')),
      const SizedBox(height: 16),
      Container(margin: const EdgeInsets.symmetric(horizontal: 32), decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: const Column(children: [
        Text('Recent Scans', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height: 8),
        Text('No recent scans', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
    ]),
  );
}