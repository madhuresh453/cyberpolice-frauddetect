import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/api_client.dart';
import 'local_notification_service.dart';

/// Background protection service - 24/7 monitoring for calls, SMS, WhatsApp
/// Bridges Flutter with native Android Kotlin services
class BackgroundService {
  static final BackgroundService _instance = BackgroundService._();
  factory BackgroundService() => _instance;
  BackgroundService._();

  bool _initialized = false;
  bool _callMonitoringActive = false;
  bool _smsMonitoringActive = false;
  bool _whatsappMonitoringActive = false;

  final ApiClient _api = ApiClient();

  // MethodChannels for native Android communication
  static const MethodChannel _serviceChannel = MethodChannel('com.cybershield/protection');
  static const MethodChannel _callChannel = MethodChannel('com.cybershield/call_protection');
  static const MethodChannel _overlayChannel = MethodChannel('com.cybershield/overlay');

  // Event streams for real-time UI updates
  final _callEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _smsEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _whatsappEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _alertController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get callEvents => _callEventController.stream;
  Stream<Map<String, dynamic>> get smsEvents => _smsEventController.stream;
  Stream<Map<String, dynamic>> get whatsappEvents => _whatsappEventController.stream;
  Stream<Map<String, dynamic>> get alerts => _alertController.stream;

  bool get isCallMonitoringActive => _callMonitoringActive;
  bool get isSmsMonitoringActive => _smsMonitoringActive;
  bool get isWhatsappMonitoringActive => _whatsappMonitoringActive;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _serviceChannel.setMethodCallHandler(_handleNativeMethodCall);
      _callChannel.setMethodCallHandler(_handleCallEvent);
      _overlayChannel.setMethodCallHandler(_handleOverlayCommand);
      _initialized = true;
      debugPrint('[BackgroundService] Initialized');
    } catch (e) {
      debugPrint('[BackgroundService] Init error: $e');
    }
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onServiceStatus':
        _alertController.add({'type': 'service_status', 'data': call.arguments});
        break;
      case 'onAppForegrounded':
        _alertController.add({'type': 'app_foregrounded'});
        break;
    }
    return null;
  }

  Future<dynamic> _handleCallEvent(MethodCall call) async {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    switch (args['event']) {
      case 'call_warning':
      case 'call_high_risk':
        _callEventController.add(args);
        await _showHighRiskOverlay(args);
        break;
      case 'call_safe':
        _callEventController.add(args);
        break;
      case 'call_error':
        debugPrint('[CallProtection] Error: ${args['error']}');
        break;
      default:
        _callEventController.add(args);
    }
    return null;
  }

  Future<dynamic> _handleOverlayCommand(MethodCall call) async {
    switch (call.method) {
      case 'blockNumber':
        await blockNumber(call.arguments as String);
        break;
      case 'reportFraud':
        await reportFraud(Map<String, dynamic>.from(call.arguments as Map));
        break;
    }
    return null;
  }

  /// Start all protection services
  Future<void> startAllServices() async {
    await init();
    await startCallMonitoring();
    await startSmsMonitoring();
    await startWhatsappMonitoring();
    try {
      await _serviceChannel.invokeMethod('startForegroundService');
      debugPrint('[BackgroundService] All services started');
    } catch (e) {
      debugPrint('[BackgroundService] Foreground service error: $e');
    }
  }

  /// Start 24/7 call monitoring via native service
  Future<void> startCallMonitoring() async {
    try {
      await _serviceChannel.invokeMethod('startCallMonitoring');
      _callMonitoringActive = true;
      await _saveState('call_monitoring', 'true');
      debugPrint('[BackgroundService] Call monitoring active');
    } catch (e) {
      debugPrint('[BackgroundService] Start call monitoring error: $e');
    }
  }

  Future<void> stopCallMonitoring() async {
    try {
      await _serviceChannel.invokeMethod('stopCallMonitoring');
      _callMonitoringActive = false;
      await _saveState('call_monitoring', 'false');
      debugPrint('[BackgroundService] Call monitoring stopped');
    } catch (e) {
      debugPrint('[BackgroundService] Stop call monitoring error: $e');
    }
  }

  /// Start SMS monitoring
  Future<void> startSmsMonitoring() async {
    try {
      await _serviceChannel.invokeMethod('startSmsMonitoring');
      _smsMonitoringActive = true;
      await _saveState('sms_monitoring', 'true');
      debugPrint('[BackgroundService] SMS monitoring active');
    } catch (e) {
      debugPrint('[BackgroundService] Start SMS monitoring error: $e');
    }
  }

  Future<void> stopSmsMonitoring() async {
    try {
      await _serviceChannel.invokeMethod('stopSmsMonitoring');
      _smsMonitoringActive = false;
      await _saveState('sms_monitoring', 'false');
      debugPrint('[BackgroundService] SMS monitoring stopped');
    } catch (e) {
      debugPrint('[BackgroundService] Stop SMS monitoring error: $e');
    }
  }

  /// Start WhatsApp monitoring
  Future<void> startWhatsappMonitoring() async {
    try {
      await _serviceChannel.invokeMethod('startWhatsappMonitoring');
      _whatsappMonitoringActive = true;
      await _saveState('whatsapp_monitoring', 'true');
      debugPrint('[BackgroundService] WhatsApp monitoring active');
    } catch (e) {
      debugPrint('[BackgroundService] Start WhatsApp monitoring error: $e');
    }
  }

  Future<void> stopWhatsappMonitoring() async {
    try {
      await _serviceChannel.invokeMethod('stopWhatsappMonitoring');
      _whatsappMonitoringActive = false;
      await _saveState('whatsapp_monitoring', 'false');
      debugPrint('[BackgroundService] WhatsApp monitoring stopped');
    } catch (e) {
      debugPrint('[BackgroundService] Stop WhatsApp monitoring error: $e');
    }
  }

  /// Show fraud warning overlay (delegated to native Android)
  Future<void> _showHighRiskOverlay(Map<String, dynamic> data) async {
    try {
      await _overlayChannel.invokeMethod('showWarning', {
        'phoneNumber': data['phoneNumber'] ?? '',
        'trustScore': data['trust_score'] ?? '50',
        'riskCategory': data['risk_category'] ?? 'medium',
        'callType': data['call_type'] ?? 'INCOMING',
      });
    } catch (e) {
      debugPrint('[Overlay] Error: $e');
    }
  }

  /// Block a number via native + API
  Future<void> blockNumber(String number) async {
    try {
      await _serviceChannel.invokeMethod('blockNumber', number);
      await _api.post('/api/v1/citizen/block-number', data: {'phone_number': number});
      debugPrint('[Block] Number blocked: $number');
    } catch (e) {
      debugPrint('[Block] Error: $e');
    }
  }

  /// Report fraud via API
  Future<void> reportFraud(Map<String, dynamic> data) async {
    try {
      await _api.post('/api/v1/osint/report-fraud', data: data);
      await _overlayChannel.invokeMethod('dismissOverlay');
      debugPrint('[Report] Fraud reported');
    } catch (e) {
      debugPrint('[Report] Error: $e');
    }
  }

  /// SMS received callback from native SmsReceiver
  Future<void> onSmsReceived(Map<String, dynamic> smsData) async {
    _smsEventController.add(smsData);
    try {
      final result = await _api.analyzeSms(smsData['message'] ?? '');
      final riskScore = int.tryParse('${result['risk_score']}') ?? 0;
      if (riskScore >= 70) {
        await LocalNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '🚨 Fraud SMS Detected',
          body: 'From: ${smsData['sender']}\nRisk: $riskScore%',
        );
      } else if (riskScore >= 40) {
        await LocalNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '⚠️ Suspicious SMS',
          body: 'From: ${smsData['sender']}\nRisk: $riskScore%',
        );
      }
    } catch (e) {
      debugPrint('[SMS] Analysis error: $e');
    }
  }

  /// WhatsApp message callback from native service
  Future<void> onWhatsAppMessage(Map<String, dynamic> msgData) async {
    _whatsappEventController.add(msgData);
    try {
      final result = await _api.analyzeWhatsapp(msgData['message'] ?? '');
      final riskScore = int.tryParse('${result['risk_score']}') ?? 0;
      if (riskScore >= 70) {
        await LocalNotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '🚨 Suspicious WhatsApp',
          body: 'From: ${msgData['sender']}\nRisk: $riskScore%',
        );
      }
    } catch (e) {
      debugPrint('[WhatsApp] Analysis error: $e');
    }
  }

  /// Stop all services
  Future<void> stopAllServices() async {
    await stopCallMonitoring();
    await stopSmsMonitoring();
    await stopWhatsappMonitoring();
    try {
      await _serviceChannel.invokeMethod('stopForegroundService');
    } catch (e) {
      debugPrint('[BackgroundService] Stop error: $e');
    }
    debugPrint('[BackgroundService] All services stopped');
  }

  /// Restore monitoring state on app restart
  Future<void> restoreState() async {
    final box = await Hive.openBox('settings');
    if (box.get('call_monitoring') == 'true') await startCallMonitoring();
    if (box.get('sms_monitoring') == 'true') await startSmsMonitoring();
    if (box.get('whatsapp_monitoring') == 'true') await startWhatsappMonitoring();
  }

  Future<void> _saveState(String key, String value) async {
    final box = await Hive.openBox('settings');
    await box.put(key, value);
  }

  void dispose() {
    _callEventController.close();
    _smsEventController.close();
    _whatsappEventController.close();
    _alertController.close();
  }
}