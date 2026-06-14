import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/widgets.dart';

class FamilyProtectionScreen extends StatelessWidget {
  const FamilyProtectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cyberBlack,
      appBar: AppBar(title: const Text('Family Protection')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        CyberCard(borderColor: AppTheme.safeGreen, child: Column(children: [
          const Icon(Icons.family_restroom, size: 48, color: AppTheme.safeGreen),
          const SizedBox(height: 12),
          const Text('Protecting 5 Family Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.safeGreen)),
          Text('AI monitoring for scam patterns', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
        ])),
        const SizedBox(height: 20),
        _member('Rahul Kumar', 'Father', '5 calls blocked', AppTheme.safeGreen),
        _member('Priya Kumar', 'Mother', '0 threats', AppTheme.safeGreen),
        _member('Amit Kumar', 'Brother', '2 threats detected', AppTheme.warningOrange),
        _member('Neha Sharma', 'Sister', '1 scam blocked', AppTheme.warningOrange),
        _member('Ravi Verma', 'Uncle', '0 threats', AppTheme.safeGreen),
        const SizedBox(height: 20),
        CyberButton(label: 'Add Family Member', icon: Icons.person_add, color: AppTheme.cyberBlue, onPressed: () {}),
        const SizedBox(height: 12),
        CyberButton(label: 'Call Family Emergency', icon: Icons.phone, color: AppTheme.dangerRed, onPressed: () => context.go('/emergency')),
      ]),
    );
  }
  Widget _member(String name, String relation, String status, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.person, color: color, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(relation, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        StatusBadge(label: status, color: color),
      ]),
    ]));
}