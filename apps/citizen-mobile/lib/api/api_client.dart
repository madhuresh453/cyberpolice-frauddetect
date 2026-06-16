import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../core/config/app_config.dart';

/// Production API client connecting to CyberShield backend
class ApiClient {
  static String get baseUrl => AppConfig.apiV1;
  static String get aiBaseUrl => AppConfig.aiBaseUrl;
  
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  Future<Map<String, String>> _headers() async {
    final box = await Hive.openBox('auth');
    final token = box.get('jwt_token', defaultValue: '');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse> get(String path) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[API] GET $uri');
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) throw ApiException(response.statusCode, body['message'] ?? 'Request failed');
    return ApiResponse(body);
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? data}) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl$path');
    debugPrint('[API] POST $uri');
    final response = await http.post(uri, headers: headers, body: data != null ? jsonEncode(data) : null)
        .timeout(const Duration(seconds: 10));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) throw ApiException(response.statusCode, body['message'] ?? 'Request failed');
    return ApiResponse(body);
  }

  Future<ApiResponse> delete(String path) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 10));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) throw ApiException(response.statusCode, body['message'] ?? 'Delete failed');
    return ApiResponse(body);
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? data}) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(uri, headers: headers, body: data != null ? jsonEncode(data) : null)
        .timeout(const Duration(seconds: 10));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) throw ApiException(response.statusCode, body['message'] ?? 'Put failed');
    return ApiResponse(body);
  }

  /// Set auth token in Hive
  Future<void> setToken(String token) async {
    final box = await Hive.openBox('auth');
    await box.put('jwt_token', token);
  }

  /// Clear auth token
  Future<void> clearToken() async {
    final box = await Hive.openBox('auth');
    await box.delete('jwt_token');
  }

  // AI Gateway calls
  Future<ApiResponse> analyzeCall(String phoneNumber, {String? audioPath}) async {
    return post('/ai/analyze/call', data: {'phone_number': phoneNumber, 'audio_path': audioPath});
  }

  Future<ApiResponse> analyzeText(String text, {String? phoneNumber}) async {
    return post('/ai/analyze/text', data: {'text': text, 'phone_number': phoneNumber});
  }

  Future<ApiResponse> analyzeSms(String text, {String? sender}) async {
    return post('/ai/analyze/sms', data: {'text': text, 'sender': sender ?? ''});
  }

  Future<ApiResponse> analyzeWhatsapp(String text, {String? sender}) async {
    return post('/ai/analyze/whatsapp', data: {'text': text, 'sender': sender ?? ''});
  }

  // Auth
  Future<ApiResponse> login(String email, String password) async {
    return post('/auth/login', data: {'email': email, 'password': password});
  }

  Future<ApiResponse> register(String email, String password, String fullName, String phoneNumber, {String userType = 'citizen'}) async {
    return post('/auth/register', data: {
      'email': email, 'password': password, 'full_name': fullName,
      'phone_number': phoneNumber, 'user_type': userType,
    });
  }

  Future<ApiResponse> sendOtp(String phoneNumber) async {
    return post('/auth/otp/login', data: {'phone_number': phoneNumber});
  }

  Future<ApiResponse> verifyOtp(String phoneNumber, String otp) async {
    return post('/auth/otp/verify', data: {'phone_number': phoneNumber, 'otp': otp});
  }

  // OSINT / Trust Score
  Future<ApiResponse> checkPhoneReputation(String phoneNumber) async {
    return post('/osint/phone', data: {'phone_number': phoneNumber});
  }

  Future<ApiResponse> checkUpiReputation(String upiId) async {
    return post('/osint/upi', data: {'upi_id': upiId});
  }

  // Fraud Reporting
  Future<ApiResponse> reportFraud(Map<String, dynamic> report) async {
    return post('/citizen/reports', data: report);
  }
}

/// Wrapper around API responses for backward compat
class ApiResponse {
  final Map<String, dynamic> _body;
  ApiResponse(this._body);

  /// Root data field (many endpoints return { success: true, data: {} })
  Map<String, dynamic> get data => _body['data'] as Map<String, dynamic>? ?? _body;

  /// Success flag
  bool get success => _body['success'] == true;

  /// Raw response body
  Map<String, dynamic> get body => _body;

  dynamic operator [](String key) => _body[key];
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}