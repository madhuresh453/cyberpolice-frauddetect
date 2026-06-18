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

  /// Log all API requests for debugging
  void _logRequest(String method, String url, {Map<String, dynamic>? body}) {
    final bodyStr = body != null ? jsonEncode(body) : '';
    final truncated = bodyStr.length > 200 ? '${bodyStr.substring(0, 200)}...' : bodyStr;
    debugPrint('[API] $method $url${body != null ? ' $truncated' : ''}');
  }

  Future<ApiResponse> get(String path) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl$path');
    _logRequest('GET', uri.toString());
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw ApiException(response.statusCode, body['message'] ?? 'Request failed');
      }
      return ApiResponse(body);
    } catch (e) {
      debugPrint('[API] GET ERROR: $e');
      rethrow;
    }
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? data}) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl$path');
    _logRequest('POST', uri.toString(), body: data);
    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      ).timeout(const Duration(seconds: 15));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw ApiException(response.statusCode, body['message'] ?? 'Request failed');
      }
      debugPrint('[API] POST OK: $path → ${response.statusCode}');
      return ApiResponse(body);
    } catch (e) {
      debugPrint('[API] POST ERROR: $path → $e');
      rethrow;
    }
  }

  Future<ApiResponse> delete(String path) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl$path');
    _logRequest('DELETE', uri.toString());
    final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 15));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) throw ApiException(response.statusCode, body['message'] ?? 'Delete failed');
    return ApiResponse(body);
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? data}) async {
    final headers = await _headers();
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(uri, headers: headers, body: data != null ? jsonEncode(data) : null)
        .timeout(const Duration(seconds: 15));
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

  /// Get auth token for native bridge
  Future<String?> getAuthToken() async {
    final box = await Hive.openBox('auth');
    return box.get('jwt_token') as String?;
  }

  // ═══════════════════════════════════════
  // AUTH ENDPOINTS (all relative to apiV1)
  // baseUrl = https://api.uni6ctf.online/api/v1
  // So /auth/login → https://api.uni6ctf.online/api/v1/auth/login ✅
  // ═══════════════════════════════════════

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

  Future<ApiResponse> refreshToken(String refreshToken) async {
    return post('/auth/refresh', data: {'refresh_token': refreshToken});
  }

  Future<ApiResponse> getProfile() async {
    return get('/auth/me');
  }

  Future<ApiResponse> changePassword(String currentPassword, String newPassword) async {
    return post('/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  // ═══════════════════════════════════════
  // OSINT ENDPOINTS
  // ═══════════════════════════════════════

  Future<ApiResponse> checkPhoneReputation(String phoneNumber) async {
    return post('/osint/phone', data: {'phone_number': phoneNumber});
  }

  Future<ApiResponse> checkUpiReputation(String upiId) async {
    return post('/osint/upi', data: {'upi_id': upiId});
  }

  Future<ApiResponse> reportFraud(Map<String, dynamic> report) async {
    return post('/osint/report-fraud', data: report);
  }

  // ═══════════════════════════════════════
  // AI ANALYSIS ENDPOINTS
  // These use aiBaseUrl which in production = https://api.uni6ctf.online
  // ═══════════════════════════════════════

  Future<ApiResponse> analyzeCall(String phoneNumber, {String? audioPath}) async {
    final uri = Uri.parse('$aiBaseUrl/api/v1/ai/analyze/call');
    final headers = await _headers();
    _logRequest('POST', uri.toString(), body: {'phone_number': phoneNumber});
    try {
      final response = await http.post(uri, headers: headers,
        body: jsonEncode({'phone_number': phoneNumber, 'audio_path': audioPath}),
      ).timeout(const Duration(seconds: 30));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse(body);
    } catch (e) {
      debugPrint('[API] AI Call analysis error: $e');
      return ApiResponse({'error': true, 'risk_score': 0, 'message': e.toString()});
    }
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

  // ═══════════════════════════════════════
  // CITIZEN ENDPOINTS
  // ═══════════════════════════════════════

  Future<ApiResponse> blockNumber(String phoneNumber) async {
    return post('/citizen/block-number', data: {'phone_number': phoneNumber});
  }

  Future<ApiResponse> getDashboard() async {
    return get('/citizen/dashboard');
  }

  Future<ApiResponse> getComplaints() async {
    return get('/citizen/complaints');
  }

  Future<ApiResponse> getAlerts() async {
    return get('/citizen/alerts');
  }
}

/// Wrapper around API responses
class ApiResponse {
  final Map<String, dynamic> _body;
  ApiResponse(this._body);

  Map<String, dynamic> get data => _body['data'] as Map<String, dynamic>? ?? _body;
  bool get success => _body['success'] == true;
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