import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AuthRepository {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _api.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      await _handleAuthResponse(data);
      
      final userResponse = await _api.get(ApiEndpoints.me);
      return UserModel.fromJson(userResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> register(String email, String phone, String password, String name) async {
    try {
      final response = await _api.post(ApiEndpoints.register, data: {
        'email': email,
        'phone_number': phone,
        'password': password,
        'full_name': name,
        'user_type': 'citizen',
      });
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('access_token') || data.containsKey('tokens')) {
        await _handleAuthResponse(data);
      }
      return UserModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> sendOtp(String phone) async {
    try {
      await _api.post(ApiEndpoints.otpLogin, data: {
        'phone_number': phone,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> verifyOtp(String phone, String otp) async {
    try {
      final response = await _api.post(ApiEndpoints.otpVerify, data: {
        'phone_number': phone,
        'otp': otp,
      });
      final data = response.data as Map<String, dynamic>;
      await _handleAuthResponse(data);
      
      final userResponse = await _api.get(ApiEndpoints.me);
      return UserModel.fromJson(userResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> phoneLogin(String phone) async {
    try {
      await _api.post(ApiEndpoints.phoneLogin, data: {
        'phone_number': phone,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> googleLogin() async {
    try {
      // In production, receive Google ID token from Google Sign-In
      final response = await _api.post(ApiEndpoints.googleLogin, data: {
        'id_token': 'google_id_token_placeholder', // Replace with actual Google sign-in
      });
      final data = response.data as Map<String, dynamic>;
      await _handleAuthResponse(data);
      
      final userResponse = await _api.get(ApiEndpoints.me);
      return UserModel.fromJson(userResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _api.post(ApiEndpoints.forgotPassword, data: {
        'email': email,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _api.post(ApiEndpoints.resetPassword, data: {
        'reset_token': token,
        'new_password': newPassword,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _api.post(ApiEndpoints.changePassword, data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> setupMfa() async {
    try {
      final response = await _api.post(ApiEndpoints.mfaSetup);
      final data = response.data as Map<String, dynamic>;
      return {
        'secret': data['secret'] ?? '',
        'qr_code': data['qr_code_svg'] != null 
            ? _decodeSvgQrCode(data['qr_code_svg'])
            : null,
        'recovery_codes': List<String>.from(data['recovery_codes'] ?? []),
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> verifyMfa(String code) async {
    try {
      await _api.post(ApiEndpoints.mfaVerify, data: {
        'code': code,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> verifyMfaLogin(String? code, String? recoveryCode) async {
    try {
      final response = await _api.post('/auth/mfa/login', data: {
        if (code != null) 'code': code,
        if (recoveryCode != null) 'recovery_code': recoveryCode,
      });
      final data = response.data as Map<String, dynamic>;
      await _handleAuthResponse(data);
      
      final userResponse = await _api.get(ApiEndpoints.me);
      return UserModel.fromJson(userResponse.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _api.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoints.logout);
    } catch (_) {}
    await _clearAuth();
  }

  Future<void> forceLogout() async {
    try {
      await _api.post('/auth/sessions/revoke-all');
    } catch (_) {}
    await _clearAuth();
  }

  Future<void> revokeSession(String sessionId) async {
    try {
      await _api.post('${ApiEndpoints.sessionRevoke}/$sessionId');
    } catch (_) {}
  }

  Future<void> registerDevice(String fcmToken) async {
    try {
      final deviceId = await _storage.read(key: StorageKeys.deviceId);
      await _api.post(ApiEndpoints.registerDevice, data: {
        'fcm_token': fcmToken,
        'device_id': deviceId ?? '',
        'platform': 'mobile',
        'app_version': '1.0.0',
      });
    } catch (_) {}
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.put('/auth/me', data: data);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) return null;
      final response = await _api.post(ApiEndpoints.refresh, data: {
        'refresh_token': refreshToken,
      });
      final data = response.data as Map<String, dynamic>;
      await _api.setToken(data['access_token'] as String);
      await _storage.write(key: StorageKeys.refreshToken, value: data['refresh_token'] as String);
      return data['access_token'] as String;
    } catch (_) {
      await _clearAuth();
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: StorageKeys.jwtToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    
    if (accessToken != null) {
      await _api.setToken(accessToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
    if (data.containsKey('user_id')) {
      await _storage.write(key: StorageKeys.userId, value: data['user_id'].toString());
    }
    // Check MFA required
    if (data.containsKey('mfa_required') && data['mfa_required'] == true) {
      throw MfaRequiredException();
    }
  }

  Future<void> _clearAuth() async {
    await _api.clearToken();
    await _storage.delete(key: StorageKeys.jwtToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
  }

  Uint8List? _decodeSvgQrCode(String svg) {
    // In production, convert SVG to PNG bytes
    // For now return null and show SVG in WebView
    return null;
  }

  String _handleError(dynamic error) {
    if (error is MfaRequiredException) throw error;
    final msg = error.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('unauthorized')) return 'Invalid credentials';
    if (msg.contains('409') || msg.contains('already exists')) return 'Account already exists';
    if (msg.contains('400') || msg.contains('invalid')) return 'Invalid input. Please check your details.';
    if (msg.contains('423') || msg.contains('locked')) return 'Account temporarily locked. Try again later.';
    if (msg.contains('429') || msg.contains('too many')) return 'Too many attempts. Please wait.';
    if (msg.contains('timeout') || msg.contains('connection')) return 'Connection error. Please try again.';
    if (msg.contains('otp')) return 'Invalid OTP. Please try again.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'Something went wrong. Please try again.';
  }
}

