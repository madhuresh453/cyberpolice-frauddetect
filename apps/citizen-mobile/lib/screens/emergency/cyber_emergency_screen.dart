import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/raksaar_theme.dart';

class CyberEmergencyScreen extends StatefulWidget {
  const CyberEmergencyScreen({super.key});

  @override
  State<CyberEmergencyScreen> createState() => _CyberEmergencyScreenState();
}

class _CyberEmergencyScreenState extends State<CyberEmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  final List<bool> _savedItems = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Emergency'),
        backgroundColor: Colors.red.withValues(alpha: 0.15),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Panic header
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, child) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.2 + (_pulseCtrl.value * 0.2)),
                    Colors.red.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3 + (_pulseCtrl.value * 0.4)),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red.withValues(alpha: 0.8 + (_pulseCtrl.value * 0.2))),
                  const SizedBox(height: 12),
                  const Text('I Got Scammed',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 4),
                  const Text('Need Immediate Help?',
                      style: TextStyle(fontSize: 13, color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Evidence Collection
          const Text('Collect Evidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _actionCard('Save Call Logs', Icons.phone, Colors.blue, 0),
          _actionCard('Save SMS Records', Icons.message, Colors.green, 1),
          _actionCard('Save Screenshots', Icons.screenshot, Colors.orange, 2),
          _actionCard('Generate Evidence Report', Icons.description, Colors.red, 3),

          const SizedBox(height: 24),

          // Emergency actions
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _allSaved ? _onReportComplaint : null,
              icon: const Icon(Icons.local_police),
              label: Text(_allSaved ? 'Report to Cyber Cell' : 'Save All Evidence First'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.family_restroom),
            label: const Text('Notify Family Members'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  bool get _allSaved => _savedItems.every((e) => e);

  Widget _actionCard(String title, IconData icon, Color color, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: _savedItems[index]
            ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
            : ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _savedItems[index] = true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
      ),
    );
  }

  void _onReportComplaint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Evidence saved. Case report generated. Forwarding to Cyber Cell...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
}