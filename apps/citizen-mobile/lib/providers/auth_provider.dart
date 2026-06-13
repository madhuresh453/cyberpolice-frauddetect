import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../services/local_notification_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  mfaRequired,
  mfaSetupRequired,
  otpSent,
  otpRequired,
  passwordReset,
  emailVerificationRequired,
  biometricAvailable,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final String? mfaSecret;
  final Uint8List? mfaQrCode;
  final List<String>? recoveryCodes;
  final bool biometricAvailable;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.mfaSecret,
    this.mfaQrCode,
    this.recoveryCodes,
    this.biometricAvailable = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    String? mfaSecret,
    Uint8List? mfaQrCode,
    List<String>? recoveryCodes,
    bool? biometricAvailable,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
        mfaSecret: mfaSecret ?? this.mfaSecret,
        mfaQrCode: mfaQrCode ?? this.mfaQrCode,
        recoveryCodes: recoveryCodes ?? this.recoveryCodes,
        biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      );
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> _checkBiometricAvailability() async {
    try {
      // Biometric check - use platform channels or conditional import in production
      // For now, assume available on Android/iOS
      if (mounted) {
        state = state.copyWith(biometricAvailable: true);
      }
    } catch (_) {}
  }

  Future<void> init() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final loggedIn = await repo.isLoggedIn();
      if (loggedIn) {
        try {
          final user = await repo.getCurrentUser();
          state = AuthState(status: AuthStatus.authenticated, user: user);
        } catch (e) {
          // Try refresh token
          final refreshed = await repo.refreshToken();
          if (refreshed != null) {
            final user = await repo.getCurrentUser();
            state = AuthState(status: AuthStatus.authenticated, user: user);
          } else {
            state = const AuthState(status: AuthStatus.unauthenticated);
          }
        }
      } else {
        // Check for remember device
        final remembered = await _storage.read(key: StorageKeys.rememberDevice);
        if (remembered == 'true') {
          final userId = await _storage.read(key: StorageKeys.userId);
          if (userId != null) {
            // Try auto-login
            try {
              final user = await repo.getCurrentUser();
              state = AuthState(status: AuthStatus.authenticated, user: user);
              return;
            } catch (_) {}
          }
        }
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on MfaRequiredException {
      state = state.copyWith(status: AuthStatus.mfaRequired);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> register(String email, String phone, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.register(email, phone, password, name);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.sendOtp(phone);
      state = state.copyWith(status: AuthStatus.otpSent);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.verifyOtp(phone, otp);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> phoneLogin(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.phoneLogin(phone);
      state = state.copyWith(status: AuthStatus.otpSent);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> googleLogin() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.googleLogin();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> biometricLogin() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      // In production, use platform channel for biometric auth
      // For now, verify stored credentials exist
      final userId = await _storage.read(key: StorageKeys.userId);
      if (userId == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated, error: 'No saved credentials for biometric login');
        return;
      }
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.getCurrentUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.forgotPassword(email);
      state = state.copyWith(status: AuthStatus.passwordReset);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.resetPassword(token, newPassword);
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> setupMfa() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final result = await repo.setupMfa();
      state = state.copyWith(
        status: AuthStatus.mfaSetupRequired,
        mfaSecret: result['secret'],
        mfaQrCode: result['qr_code'],
        recoveryCodes: List<String>.from(result['recovery_codes'] ?? []),
      );
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> verifyMfa(String code) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.verifyMfa(code);
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> verifyMfaLogin(String? code, String? recoveryCode) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.verifyMfaLogin(code, recoveryCode);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> rememberDevice() async {
    await _storage.write(key: StorageKeys.rememberDevice, value: 'true');
    if (state.user != null) {
      await _storage.write(key: StorageKeys.userId, value: state.user!.id);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.changePassword(currentPassword, newPassword);
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  Future<void> logout() async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.logout();
    } catch (_) {}
    await _storage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> forceLogout() async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.forceLogout();
    } catch (_) {}
    await _storage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> revokeSession(String sessionId) async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.revokeSession(sessionId);
    } catch (_) {}
  }

  Future<void> registerDevice() async {
    try {
      final repo = _ref.read(authRepositoryProvider);
      String? fcmToken;
      try {
        fcmToken = await LocalNotificationService.getFcmToken();
      } catch (_) {}
      if (fcmToken != null) {
        await repo.registerDevice(fcmToken);
      }
    } catch (_) {}
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.updateProfile(data);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: _parseError(e));
    }
  }

  void clearError() {
    state = state.copyWith(error: null, status: AuthStatus.unauthenticated);
  }

  String _parseError(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('unauthorized')) return 'Invalid credentials';
    if (msg.contains('409') || msg.contains('already exists')) return 'Account already exists';
    if (msg.contains('400') || msg.contains('invalid')) return 'Invalid input. Please check your details.';
    if (msg.contains('423') || msg.contains('locked')) return 'Account temporarily locked. Try again later.';
    if (msg.contains('429') || msg.contains('too many')) return 'Too many attempts. Please wait.';
    if (msg.contains('timeout') || msg.contains('connection')) return 'Connection error. Please try again.';
    if (msg.contains('otp')) return 'Invalid OTP. Please try again.';
    if (msg.contains('mfa')) return 'MFA verification failed.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'Something went wrong. Please try again.';
  }
}

class MfaRequiredException implements Exception {
  final String message;
  MfaRequiredException([this.message = 'MFA verification required']);
  @override
  String toString() => message;
}