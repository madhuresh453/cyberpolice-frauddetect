import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
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
      await _api.setToken(data['access_token'] as String);
      await _storage.write(key: StorageKeys.refreshToken, value: data['refresh_token'] as String);

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
      });
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('access_token')) {
        await _api.setToken(data['access_token'] as String);
      }
      return UserModel.fromJson(data);
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
    await _api.clearToken();
    await _storage.deleteAll();
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
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: StorageKeys.jwtToken);
    return token != null && token.isNotEmpty;
  }

  String _handleError(dynamic error) {
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('401')) return 'Invalid credentials';
      if (msg.contains('409')) return 'User already exists';
      if (msg.contains('400')) return 'Invalid input';
    }
    return 'Connection error. Please try again.';
  }
}