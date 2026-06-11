import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _api.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _api.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
    await _api.setToken(response.data['access_token']);
    await _storage.write(key: StorageKeys.refreshToken, value: response.data['refresh_token']);
  }

  Future<void> register(String email, String phone, String password, String name) async {
    final response = await _api.post(ApiEndpoints.register, data: {
      'email': email,
      'phone_number': phone,
      'password': password,
      'full_name': name,
    });
    await _api.setToken(response.data['access_token']);
  }

  Future<void> logout() async {
    await _api.clearToken();
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: StorageKeys.jwtToken);
    return token != null && token.isNotEmpty;
  }
}