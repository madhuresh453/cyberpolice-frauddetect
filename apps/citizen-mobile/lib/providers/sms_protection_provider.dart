import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../utils/constants.dart';

final smsProtectionProvider = StateNotifierProvider<SmsProtectionNotifier, SmsProtectionState>((ref) => SmsProtectionNotifier(ref));

class SmsProtectionState {
  final bool loading;
  final bool protectionActive;
  final int totalSms;
  final int fraudDetected;
  final int safeMessages;
  final int blockedSpam;
  final List<dynamic> recentSms;
  final String? error;

  const SmsProtectionState({
    this.loading = false,
    this.protectionActive = true,
    this.totalSms = 0,
    this.fraudDetected = 0,
    this.safeMessages = 0,
    this.blockedSpam = 0,
    this.recentSms = const [],
    this.error,
  });

  SmsProtectionState copyWith({
    bool? loading, bool? protectionActive, int? totalSms, int? fraudDetected,
    int? safeMessages, int? blockedSpam, List<dynamic>? recentSms, String? error,
  }) => SmsProtectionState(
    loading: loading ?? this.loading, protectionActive: protectionActive ?? this.protectionActive,
    totalSms: totalSms ?? this.totalSms, fraudDetected: fraudDetected ?? this.fraudDetected,
    safeMessages: safeMessages ?? this.safeMessages, blockedSpam: blockedSpam ?? this.blockedSpam,
    recentSms: recentSms ?? this.recentSms, error: error,
  );
}

class SmsProtectionNotifier extends StateNotifier<SmsProtectionState> {
  final Ref _ref;
  final ApiClient _api = ApiClient();
  SmsProtectionNotifier(this._ref) : super(const SmsProtectionState()) { loadStats(); }

  Future<void> loadStats() async {
    state = state.copyWith(loading: true);
    try {
      final response = await _api.get(ApiEndpoints.smsProtection);
      final data = response.data as Map<String, dynamic>;
      state = SmsProtectionState(
        protectionActive: data['protection_active'] ?? true,
        totalSms: data['total_sms'] ?? 0, fraudDetected: data['fraud_detected'] ?? 0,
        safeMessages: data['safe_messages'] ?? 0, blockedSpam: data['blocked_spam'] ?? 0,
        recentSms: data['recent_sms'] as List<dynamic>? ?? [],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> toggleProtection() async {
    try {
      await _api.post('${ApiEndpoints.smsProtection}/toggle');
      state = state.copyWith(protectionActive: !state.protectionActive);
    } catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> reportSms(String sender, String message) async {
    try {
      await _api.post(ApiEndpoints.reportSms, data: {'sender': sender, 'message': message});
    } catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<Map<String, dynamic>?> analyzeSms(String text) async {
    try {
      final response = await _api.post('${ApiEndpoints.smsProtection}/analyze', data: {'text': text});
      return response.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }
}