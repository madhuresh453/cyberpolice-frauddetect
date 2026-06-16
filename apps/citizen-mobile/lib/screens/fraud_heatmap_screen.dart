import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/widgets.dart';

class FraudHeatmapScreen extends StatelessWidget {
  const FraudHeatmapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Fraud Heatmap')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Active Scam Hotspots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Container(height: 300, decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderColor)),
          child: Stack(children: [
            Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.map_outlined, size: 64, color: AppTheme.cyberBlue.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('Live Map View', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
              const SizedBox(height: 8),
              Text('Mumbai, Delhi, Bangalore, Hyderabad', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.6))),
            ])),
            const Positioned(top: 10, left: 10, child: StatusBadge(label: 'LIVE', color: AppTheme.dangerRed)),
          ])),
        const SizedBox(height: 20),
        _hotspot('Mumbai', 1250, 'High'), _hotspot('Delhi', 980, 'High'),
        _hotspot('Bangalore', 650, 'Medium'), _hotspot('Hyderabad', 420, 'Medium'),
        _hotspot('Chennai', 310, 'Low'), _hotspot('Kolkata', 280, 'Low'),
      ]),
    );
  }
  Widget _hotspot(String city, int count, String level) {
    final color = level == 'High' ? AppTheme.dangerRed : level == 'Medium' ? AppTheme.warningOrange : AppTheme.safeGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
      child: Row(children: [
        Icon(Icons.location_on, color: color, size: 20), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(city, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const Text('High Risk Reports', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        Column(children: [
          Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const Text('reports', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ]),
      ]));
  }
}