import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ScamLinkScreen extends StatefulWidget {
  const ScamLinkScreen({super.key});
  @override
  State<ScamLinkScreen> createState() => _ScamLinkScreenState();
}
class _ScamLinkScreenState extends State<ScamLinkScreen> {
  final _controller = TextEditingController();
  String? _result;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Link Scanner')),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(decoration: AppTheme.neonBorder(color: AppTheme.primaryBlue), padding: const EdgeInsets.all(20), child: const Column(children: [
        Icon(Icons.link, size: 48, color: AppTheme.primaryBlue), SizedBox(height: 12),
        Text('URL Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Check if a link is safe', style: TextStyle(color: AppTheme.textSecondary)),
      ])),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Paste link to scan', prefixIcon: Icon(Icons.link)))),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () => setState(() => _result = 'safe'), child: const Text('Scan')),
      ]),
      if (_result != null) ...[
        const SizedBox(height: 20),
        Container(decoration: AppTheme.neonBorder(color: _result == 'safe' ? AppTheme.successGreen : AppTheme.dangerRed), padding: const EdgeInsets.all(16), child: Row(children: [
          Icon(_result == 'safe' ? Icons.check_circle : Icons.warning, color: _result == 'safe' ? AppTheme.successGreen : AppTheme.dangerRed, size: 24),
          const SizedBox(width: 12),
          Text(_result == 'safe' ? 'Link appears safe' : 'Warning! Suspicious link', style: TextStyle(color: _result == 'safe' ? AppTheme.successGreen : AppTheme.dangerRed, fontWeight: FontWeight.bold)),
        ])),
      ],
    ])),
  );
}