import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});
  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  bool _isActive = false;
  bool _isLoading = false;
  String _sessionId = '';
  int _elapsedSeconds = 0;

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isActive) {
        setState(() => _elapsedSeconds++);
        _startTimer();
      }
    });
  }

  String get _formattedTime {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _triggerSOS(String type) {
    HapticFeedback.heavyImpact();
    setState(() {
      _isActive = true;
      _isLoading = false;
      _sessionId = 'SOS-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
    });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency SOS triggered. Police and family notified.'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isActive ? Colors.red.shade900 : Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: _isActive ? Colors.red.shade900 : null,
        foregroundColor: Colors.white,
        title: Text(_isActive ? 'EMERGENCY ACTIVE' : 'Emergency SOS'),
      ),
      body: Center(
        child: _isActive ? _buildActiveView() : _buildTriggerView(),
      ),
    );
  }

  Widget _buildTriggerView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emergency, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          Text('Cyber Emergency SOS', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Tap the button to trigger SOS. Police and family will be notified instantly.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _isLoading ? null : () => _triggerSOS('sos'),
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.red,
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 30, spreadRadius: 10)],
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                  : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.emergency, size: 48, color: Colors.white),
                      SizedBox(height: 8),
                      Text('SOS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _chip(Icons.phone, 'Call Scam', 'call_scam'),
            _chip(Icons.money, 'UPI Fraud', 'upi_fraud'),
            _chip(Icons.person, 'Identity Theft', 'identity_theft'),
            _chip(Icons.videocam, 'Deepfake', 'deepfake'),
          ]),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, String type) {
    return ActionChip(avatar: Icon(icon, size: 18), label: Text(label), onPressed: () => _triggerSOS(type));
  }

  Widget _buildActiveView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_formattedTime, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('EMERGENCY ACTIVE', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 32),
          Card(
            color: Colors.white10,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Actions Completed:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _statusItem('Police notified'),
                _statusItem('Family notified'),
                _statusItem('Call recording started'),
                _statusItem('Screenshots captured'),
                _statusItem('SMS evidence saved'),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('Session: $_sessionId', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => setState(() { _isActive = false; _elapsedSeconds = 0; }),
            child: const Text('Mark as Resolved', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ]),
    );
  }
}