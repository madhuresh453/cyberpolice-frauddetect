import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class FraudHeatmapScreen extends StatelessWidget {
  const FraudHeatmapScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background, appBar: AppBar(title: const Text('Fraud Heatmap')),
    body: Column(children: [
      Container(height: 200, margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderColor)), child: const Center(child: Text('Mapbox India Map', style: TextStyle(color: AppTheme.textSecondary)))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        _chip('All India'), _chip('Maharashtra'), _chip('Delhi'), _chip('Karnataka'),
      ])),
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        _locationItem('Mumbai', '1,234 cases', AppTheme.dangerRed),
        _locationItem('Delhi', '987 cases', AppTheme.dangerRed),
        _locationItem('Bangalore', '756 cases', AppTheme.warningOrange),
        _locationItem('Pune', '543 cases', AppTheme.warningOrange),
        _locationItem('Chennai', '432 cases', AppTheme.warningOrange),
        _locationItem('Hyderabad', '321 cases', AppTheme.successGreen),
      ])),
    ]),
  );
  Widget _chip(String label) => Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderColor)), child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)));
  Widget _locationItem(String city, String cases, Color color) => Container(margin: const EdgeInsets.only(bottom: 8), decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(12), child: Row(children: [
    Icon(Icons.location_on, color: color, size: 20), const SizedBox(width: 12), Expanded(child: Text(city, style: const TextStyle(color: AppTheme.textPrimary))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(cases, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
  ]));
}