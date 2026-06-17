import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/api_client.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? phoneNumber;
  final String? fullName;
  final String? error;
  final String? mfaQrCode;
  final String? mfaSecret;
  final String? token;

  AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.phoneNumber,
    this.fullName,
    this.error,
    this.mfaQrCode,
    this.mfaSecret,
    this.token,
  });

  AuthState copyWith({AuthStatus? status, String? email, String? phoneNumber, String? fullName, String? error, String? mfaQrCode, String? mfaSecret, String? token}) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      error: error,
      mfaQrCode: mfaQrCode ?? this.mfaQrCode,
      mfaSecret: mfaSecret ?? this.mfaSecret,
      token: token ?? this.token,
    );
  }
}

class AuthProvider extends StateNotifier<AuthState> {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthProvider() : super(AuthState()) {
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      // Check secure storage first
      String? token = await _storage.read(key: 'jwt_token');
      
      // Fallback to Hive
      if (token == null || token.isEmpty) {
        final box = Hive.box('auth');
        token = box.get('jwt_token') as String?;
      }
      
      if (token != null && token.isNotEmpty) {
        // Set token for API calls
        await _api.setToken(token);
        
        // Store in both locations
        await _storage.write(key: 'jwt_token', value: token);
        final box = Hive.box('auth');
        await box.put('jwt_token', token);
        
        final email = box.get('email') as String? ?? '';
        final fullName = box.get('fullName') as String? ?? '';
        
        state = AuthState(
          status: AuthStatus.authenticated,
          email: email,
          fullName: fullName,
          token: token,
        );
      } else {
        state = AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('[Auth] Auto-login check failed: $e');
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _api.login(email, password);
      final token = result['token'] ?? result['data']?['token'] ?? '';
      
      if (token.isEmpty && result.data['accessToken'] != null) {
        await _saveToken(result.data['accessToken'] as String, email);
      } else {
        await _saveToken(token, email);
      }
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        email: email,
        token: token,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> register({required String email, required String password, required String fullName, required String phoneNumber}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _api.register(email, password, fullName, phoneNumber);
      final token = result['token'] ?? result['data']?['token'] ?? result.data['accessToken'] ?? '';
      
      if (token.isNotEmpty) {
        await _saveToken(token, email);
      }
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        email: email,
        fullName: fullName,
        token: token,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> _saveToken(String token, String email) async {
    await _api.setToken(token);
    await _storage.write(key: 'jwt_token', value: token);
    final box = Hive.box('auth');
    await box.put('jwt_token', token);
    await box.put('email', email);
  }

  Future<void> sendOtp({required String phoneNumber}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _api.sendOtp(phoneNumber);
      state = state.copyWith(status: AuthStatus.initial, phoneNumber: phoneNumber);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> verifyOtp({required String phoneNumber, required String otp}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _api.verifyOtp(phoneNumber, otp);
      final token = result['token'] ?? result['data']?['token'] ?? result.data['accessToken'] ?? '';
      
      if (token.isNotEmpty) {
        await _saveToken(token, '');
      }
      
      state = state.copyWith(status: AuthStatus.authenticated, phoneNumber: phoneNumber, token: token);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<bool> refreshAuthToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return false;
      
      final result = await _api.refreshToken(refreshToken);
      final newToken = result['token'] ?? result.data['accessToken'] ?? '';
      
      if (newToken.isNotEmpty) {
        await _api.setToken(newToken);
        await _storage.write(key: 'jwt_token', value: newToken);
        state = state.copyWith(token: newToken);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[Auth] Token refresh failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/api/v1/auth/logout');
    } catch (_) {}
    
    await _api.clearToken();
    await _storage.deleteAll();
    final box = Hive.box('auth');
    await box.clear();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  void rememberDevice() {}

  Future<void> phoneLogin(String phone, String otp) async => verifyOtp(phoneNumber: phone, otp: otp);
  Future<void> googleLogin() async {}
  Future<void> biometricLogin() async {}
  Future<void> forgotPassword(String email) async {}
  Future<void> resetPassword(String code, String newPassword) async {}
  Future<void> verifyMfaLogin(String code) async {}
  
  // Alias for logout
  Future<void> clearAuth() async => logout();
}

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) => AuthProvider());