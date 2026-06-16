import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

/// Auth repository - delegates to ApiClient.
/// Auth logic is in auth_provider.dart (StateNotifier).
class AuthRepository {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _api.login(email, password);
    return result.data;
  }

  Future<Map<String, dynamic>> register(String email, String password, String fullName, String phoneNumber) async {
    final result = await _api.register(email, password, fullName, phoneNumber);
    return result.data;
  }

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final result = await _api.sendOtp(phoneNumber);
    return result.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    final result = await _api.verifyOtp(phoneNumber, otp);
    return result.data;
  }

  Future<void> logout() async {
    await _api.clearToken();
  }

  Future<void> saveToken(String token) async {
    await _api.setToken(token);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());