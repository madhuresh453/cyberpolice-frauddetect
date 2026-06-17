import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/config/app_config.dart';

/// Real-time WebSocket service for citizen ↔ police communication
/// Connects to backend Socket.IO server at /ws path
class RaksaarWebSocketService {
  static final RaksaarWebSocketService _instance = RaksaarWebSocketService._();
  factory RaksaarWebSocketService() => _instance;
  RaksaarWebSocketService._();

  WebSocketChannel? _channel;
  String? _userId;
  StreamController<Map<String, dynamic>>? _eventController;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  Stream<Map<String, dynamic>>? get events => _eventController?.stream;
  bool get isConnected => _isConnected;

/// Connect to WebSocket server
Future<void> connect({
  required String userId,
  String serverUrl = '',
}) async {

  if (AppConfig.webSocketUrl.isEmpty) {
    debugPrint('[WS] Disabled - No backend websocket configured');
    return;
  }

  final url =
      serverUrl.isNotEmpty ? serverUrl : AppConfig.webSocketUrl;

  _userId = userId;
  _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  try {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;
    _reconnectAttempts = 0;

    _channel!.sink.add(jsonEncode({
      'event': 'join:citizen',
      'data': userId,
    }));

    _channel!.stream.listen(
      (message) {
        _handleMessage(message);
      },
      onError: (error) {
        debugPrint('[WS] Error: $error');
        _handleDisconnect();
      },
      onDone: () {
        debugPrint('[WS] Connection closed');
        _handleDisconnect();
      },
    );

    debugPrint('[WS] Connected to $url as citizen $userId');
  } catch (e) {
    debugPrint('[WS] Connection failed: $e');
    _handleDisconnect();
  }
}
  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = data['event'] as String?;
      final payload = data['data'] as Map<String, dynamic>?;

      if (event != null && payload != null) {
        _eventController?.add({
          'event': event,
          'data': payload,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('[WS] Parse error: $e');
    }
  }

  /// Handle disconnection and attempt reconnect
  void _handleDisconnect() {
    _isConnected = false;
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);
      debugPrint('[WS] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        if (_userId != null) {
          connect(userId: _userId!);
        }
      });
    }
  }

  /// Emit event to server
  void emit(String event, Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode({
        'event': event,
        'data': data,
        'userId': _userId,
      }));
    }
  }

  /// Report fraud detected - pushes to police instantly
  void reportFraud({
    required String type,
    required int riskScore,
    required String phoneNumber,
    double? latitude,
    double? longitude,
  }) {
    emit('fraud:report', {
      'type': type,
      'riskScore': riskScore,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'citizenId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Trigger emergency SOS
  void triggerSOS({
    required double latitude,
    required double longitude,
    required List<String> contacts,
  }) {
    emit('sos:triggered', {
      'latitude': latitude,
      'longitude': longitude,
      'contacts': contacts,
      'citizenId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Report analysis complete for police
  void reportAnalysisComplete(Map<String, dynamic> analysisResult) {
    emit('analysis:complete', {
      ...analysisResult,
      'citizenId': _userId,
    });
  }

  /// Listen for specific events
  Stream<Map<String, dynamic>> onEvent(String eventName) {
    if (_eventController == null) {
      return StreamController<Map<String, dynamic>>.broadcast().stream;
    }
    return _eventController!.stream.where(
      (event) => event['event'] == eventName,
    );
  }

  /// Listen for police case updates
  Stream<Map<String, dynamic>> get onCaseStatusChanged =>
      onEvent('case:status');

  Stream<Map<String, dynamic>> get onCaseAssigned =>
      onEvent('case:assigned');

  Stream<Map<String, dynamic>> get onInvestigationUpdate =>
      onEvent('investigation:update');

  Stream<Map<String, dynamic>> get onCaseClosed =>
      onEvent('case:closed');

  /// Disconnect
  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _eventController?.close();
    _isConnected = false;
    debugPrint('[WS] Disconnected');
  }
}