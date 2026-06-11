import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) =>
      AuthState(status: status ?? this.status, user: user ?? this.user, error: error);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> init() async {
    state = state.copyWith(status: AuthStatus.loading);
    final repo = _ref.read(authRepositoryProvider);
    final loggedIn = await repo.isLoggedIn();
    if (loggedIn) {
      try {
        final user = await repo.getCurrentUser();
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> register(String email, String phone, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.register(email, phone, password, name);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> logout() async {
    final repo = _ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}