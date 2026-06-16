import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridge between Flutter and Android native services
class RaksaarNativeBridge {
  static const _channel = MethodChannel('com.cybershield.ai/bridge');
  static const _eventChannel = EventChannel('com.cybershield.ai/events');

  static final RaksaarNativeBridge _instance = RaksaarNativeBridge._();
  factory RaksaarNativeBridge() => _instance;
  RaksaarNativeBridge._() {
    _setupEventListeners();
  }

  final StreamController<Map<String, dynamic>> _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  void _setupEventListeners() {
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map) {
        _eventController.add(Map<String, dynamic>.from(event));
      } else if (event is String) {
        try {
          _eventController.add(jsonDecode(event) as Map<String, dynamic>);
        } catch (_) {}
      }
    });
  }

  /// Start call protection service
  Future<bool> startCallProtection() async {
    try {
      final result = await _channel.invokeMethod<bool>('startCallProtection') ?? false;
      debugPrint('[NativeBridge] Call protection: $result');
      return result;
    } catch (e) {
      debugPrint('[NativeBridge] startCallProtection error: $e');
      return false;
    }
  }

  /// Stop call protection service
  Future<bool> stopCallProtection() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopCallProtection') ?? false;
      debugPrint('[NativeBridge] Call protection stopped: $result');
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Get current call state
  Future<Map<String, dynamic>> getCallState() async {
    try {
      final result = await _channel.invokeMethod<Map>('getCallState') ?? {};
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'state': 'IDLE', 'number': null};
    }
  }

  /// Start SMS protection
  Future<bool> startSmsProtection() async {
    try {
      return await _channel.invokeMethod<bool>('startSmsProtection') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get fraud score for a phone number from native classifier
  Future<Map<String, dynamic>> analyzeNumber(String phoneNumber) async {
    try {
      final result = await _channel.invokeMethod<Map>('analyzeNumber', {'number': phoneNumber}) ?? {};
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'score': 0, 'risk': 'unknown', 'sources': []};
    }
  }

  /// Show fraud alert overlay
  Future<void> showFraudAlert(Map<String, dynamic> alertData) async {
    try {
      await _channel.invokeMethod('showFraudAlert', alertData);
    } catch (e) {
      debugPrint('[NativeBridge] showFraudAlert error: $e');
    }
  }

  /// Encrypt evidence file
  Future<String?> encryptFile(String filePath) async {
    try {
      return await _channel.invokeMethod<String>('encryptFile', {'path': filePath});
    } catch (e) {
      return null;
    }
  }

  /// Generate evidence hash
  Future<String?> generateHash(String data) async {
    try {
      return await _channel.invokeMethod<String>('generateHash', {'data': data});
    } catch (e) {
      return null;
    }
  }

  /// Trigger SOS alert (silent or full)
  Future<bool> triggerSOS({bool silent = false}) async {
    try {
      return await _channel.invokeMethod<bool>('triggerSOS', {'silent': silent}) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Share emergency location
  Future<bool> shareLocation() async {
    try {
      return await _channel.invokeMethod<bool>('shareLocation') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Start audio recording for evidence
  Future<String?> startRecording() async {
    try {
      return await _channel.invokeMethod<String>('startRecording');
    } catch (e) {
      return null;
    }
  }

  /// Stop audio recording
  Future<String?> stopRecording() async {
    try {
      return await _channel.invokeMethod<String>('stopRecording');
    } catch (e) {
      return null;
    }
  }

  /// Check if a WhatsApp notification is fraudulent
  Future<Map<String, dynamic>> analyzeNotification(String packageName, String title, String text) async {
    try {
      final result = await _channel.invokeMethod<Map>('analyzeNotification', {
        'package': packageName, 'title': title, 'text': text,
      }) ?? {};
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'is_fraud': false, 'score': 0};
    }
  }
}