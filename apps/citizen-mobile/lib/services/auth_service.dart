import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _api.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: StorageKeys.jwtToken);
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: StorageKeys.jwtToken);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getDeviceId() async {
    String? deviceId = await _storage.read(key: StorageKeys.deviceId);
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await _storage.write(key: StorageKeys.deviceId, value: deviceId);
    }
    return deviceId;
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoints.logout);
    } catch (_) {}
    await clearAuth();
  }

  Future<void> clearAuth() async {
    await _api.clearToken();
    await _storage.delete(key: StorageKeys.jwtToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.userProfile);
  }
}