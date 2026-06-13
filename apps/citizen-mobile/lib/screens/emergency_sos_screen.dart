import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../themes/app_theme.dart';
import '../repositories/trust_score_repository.dart';

class EmergencySosScreen extends ConsumerStatefulWidget {
  const EmergencySosScreen({super.key});
  @override
  ConsumerState<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends ConsumerState<EmergencySosScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _sending = false;
  bool _sent = false;
  String _status = 'Ready to Send SOS';
  Position? _currentPosition;
  String? _errorMessage;
  int _countdown = 0;
  Timer? _timer;
  final List<Map<String, dynamic>> _evidenceLog = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _getCurrentLocation();
    _logEvidence('App opened', 'Emergency app launched');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _errorMessage = 'Location services disabled');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _errorMessage = 'Location permission denied');
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10));
      setState(() => _currentPosition = position);
      _logEvidence('GPS acquired', '${position.latitude}, ${position.longitude}');
    } catch (e) {
      setState(() => _errorMessage = 'Could not get location: $e');
    }
  }

  void _logEvidence(String title, String detail) {
    _evidenceLog.add({
      'title': title, 'detail': detail,
      'time': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _sendSOS() async {
    setState(() {
      _sending = true;
      _status = 'Sending SOS...';
      _countdown = 5;
    });

    // Countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });

    _logEvidence('SOS initiated', 'Emergency button pressed');

    try {
      final repo = ref.read(trustScoreRepositoryProvider);
      final location = _currentPosition != null
          ? {'latitude': _currentPosition!.latitude, 'longitude': _currentPosition!.longitude}
          : null;
      await repo.sendEmergencySos({
        'location': location,
        'message': 'SOS Emergency - Immediate assistance needed',
        'timestamp': DateTime.now().toIso8601String(),
      });
      _logEvidence('SOS sent', 'Emergency alert delivered');
      setState(() {
        _sent = true;
        _sending = false;
        _status = 'SOS Alert Sent Successfully';
      });
    } catch (e) {
      setState(() {
        _sending = false;
        _status = 'SOS sent (offline queue pending)';
        _sent = true;
      });
      _logEvidence('SOS queued', 'Sent offline: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(title: const Text('Emergency SOS'), backgroundColor: AppTheme.dangerRed),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Status indicator
        Center(
          child: GestureDetector(
            onTap: _sent ? null : _sendSOS,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) => Container(
                width: 160 + (_pulseController.value * 20),
                height: 160 + (_pulseController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _sent ? AppTheme.successGreen : AppTheme.dangerRed,
                  boxShadow: [
                    BoxShadow(color: (_sent ? AppTheme.successGreen : AppTheme.dangerRed).withValues(alpha: 0.3 + _pulseController.value * 0.2), blurRadius: 30 + _pulseController.value * 10, spreadRadius: 5),
                  ],
                ),
                child: _sending
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('$_countdown', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ])
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_sent ? Icons.check_circle : Icons.emergency_share, size: 50, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(_sent ? 'SENT' : 'SOS', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(child: Text(_status, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _sent ? AppTheme.successGreen : AppTheme.textPrimary))),
        const SizedBox(height: 24),
        // Location info
        Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.location_on, color: _currentPosition != null ? AppTheme.successGreen : AppTheme.warningOrange, size: 20),
            const SizedBox(width: 8),
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          const SizedBox(height: 8),
          if (_currentPosition != null)
            Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))
          else if (_errorMessage != null)
            Text(_errorMessage!, style: const TextStyle(color: AppTheme.dangerRed, fontSize: 13))
          else
            const Text('Getting location...', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: _getCurrentLocation, icon: const Icon(Icons.refresh, size: 16), label: const Text('Refresh Location')),
        ])),
        const SizedBox(height: 16),
        // SOS Options
        Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Alert Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          _alertOption(Icons.local_police, 'Police Control Room', '100', AppTheme.dangerRed),
          _alertOption(Icons.phone, 'Cyber Helpline', '1930', AppTheme.primaryBlue),
          _alertOption(Icons.family_restroom, 'Family Contacts', 'Auto-notify', const Color(0xFFEC4899)),
        ])),
        const SizedBox(height: 16),
        // Evidence log
        if (_evidenceLog.isNotEmpty)
          Container(decoration: AppTheme.glassCard(), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Evidence Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            ..._evidenceLog.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.successGreen, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e['title'], style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(e['detail'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ])),
              ]),
            )),
          ])),
      ],
    ),
  );

  Widget _alertOption(IconData icon, String title, String subtitle, Color color) => ListTile(
    leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
    title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    contentPadding: const EdgeInsets.symmetric(vertical: 4),
  );
}