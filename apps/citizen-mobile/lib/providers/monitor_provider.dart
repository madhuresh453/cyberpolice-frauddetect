import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Models for monitor data
class ThreatEvent {
  final String id;
  final String type; // call, sms, whatsapp, upi, link, apk
  final String title;
  final int riskScore;
  final DateTime timestamp;
  final String status; // blocked, safe, suspicious, dangerous

  ThreatEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.riskScore,
    required this.timestamp,
    required this.status,
  });
}

class MonitorStats {
  final int activeCalls;
  final int smsScannedToday;
  final int threatsBlocked;
  final int scamNumbersDetected;
  final int suspiciousLinksBlocked;

  MonitorStats({
    this.activeCalls = 0,
    this.smsScannedToday = 0,
    this.threatsBlocked = 0,
    this.scamNumbersDetected = 0,
    this.suspiciousLinksBlocked = 0,
  });
}

/// Monitor provider – tracks real-time protection activity
class MonitorNotifier extends StateNotifier<MonitorStats> {
  final List<ThreatEvent> _events = [];
  Timer? _simTimer;

  MonitorNotifier() : super(MonitorStats());

  List<ThreatEvent> get events => List.unmodifiable(_events);

  void startMonitoring() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _simulateThreatEvent();
    });
  }

  void stopMonitoring() {
    _simTimer?.cancel();
  }

  void _simulateThreatEvent() {
    final types = ['call', 'sms', 'whatsapp', 'upi', 'link'];
    final statuses = ['safe', 'suspicious', 'dangerous', 'blocked'];
    final titles = [
      'Scam call detected from +91-98765XXXX',
      'Phishing SMS blocked - "KYC Update"',
      'WhatsApp call risk analyzed',
      'UPI payment to unknown merchant',
      'Suspicious link scanned - hdfc-verify.xyz',
      'APK file blocked - HDFC_Update.apk',
      'Unknown caller flagged',
      'OTP scam SMS detected',
    ];

    final event = ThreatEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: types[(DateTime.now().millisecond % types.length)],
      title: titles[(DateTime.now().millisecond % titles.length)],
      riskScore: 20 + (DateTime.now().millisecond % 80),
      timestamp: DateTime.now(),
      status: statuses[(DateTime.now().millisecond % statuses.length)],
    );

    _events.insert(0, event);
    if (_events.length > 100) _events.removeLast();

    // Update stats
    state = MonitorStats(
      activeCalls: state.activeCalls + (event.type == 'call' ? 1 : 0),
      smsScannedToday: state.smsScannedToday + (event.type == 'sms' ? 1 : 0),
      threatsBlocked: state.threatsBlocked + (event.status == 'blocked' || event.status == 'dangerous' ? 1 : 0),
      scamNumbersDetected: state.scamNumbersDetected + (event.riskScore > 60 ? 1 : 0),
      suspiciousLinksBlocked: state.suspiciousLinksBlocked + (event.type == 'link' ? 1 : 0),
    );
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }
}

final monitorProvider = StateNotifierProvider<MonitorNotifier, MonitorStats>((ref) {
  return MonitorNotifier();
});