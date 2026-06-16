import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.phoneNumber,
    this.fullName,
    this.error,
    this.mfaQrCode,
    this.mfaSecret,
  });

  AuthState copyWith({AuthStatus? status, String? email, String? phoneNumber, String? fullName, String? error, String? mfaQrCode, String? mfaSecret}) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      error: error,
      mfaQrCode: mfaQrCode ?? this.mfaQrCode,
      mfaSecret: mfaSecret ?? this.mfaSecret,
    );
  }
}

class AuthProvider extends StateNotifier<AuthState> {
  final ApiClient _api = ApiClient();

  AuthProvider() : super(AuthState()) {
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final box = Hive.box('auth');
    final token = box.get('jwt_token');
    if (token != null && token.toString().isNotEmpty) {
      state = AuthState(status: AuthStatus.authenticated, email: box.get('email'), fullName: box.get('fullName'));
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _api.login(email, password);
      final token = result['token'] ?? result['data']?['token'] ?? '';
      await _api.setToken(token);
      final box = Hive.box('auth');
      await box.put('email', email);
      state = state.copyWith(status: AuthStatus.authenticated, email: email);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> register({required String email, required String password, required String fullName, required String phoneNumber}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _api.register(email, password, fullName, phoneNumber);
      final token = result['token'] ?? result['data']?['token'] ?? '';
      await _api.setToken(token);
      state = state.copyWith(status: AuthStatus.authenticated, email: email, fullName: fullName);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
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
      final token = result['token'] ?? result['data']?['token'] ?? '';
      await _api.setToken(token);
      state = state.copyWith(status: AuthStatus.authenticated, phoneNumber: phoneNumber);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    final box = Hive.box('auth');
    await box.clear();
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  void rememberDevice() {
    // TODO: implement device fingerprint
  }

  Future<void> phoneLogin(String phone, String otp) async => verifyOtp(phoneNumber: phone, otp: otp);
  Future<void> googleLogin() async {}
  Future<void> biometricLogin() async {}
  Future<void> forgotPassword(String email) async {}
  Future<void> resetPassword(String code, String newPassword) async {}
  Future<void> verifyMfaLogin(String code) async {}
}

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) => AuthProvider());