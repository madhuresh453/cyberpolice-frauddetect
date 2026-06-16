import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

final callProtectionProvider = StateNotifierProvider<CallProtectionNotifier, CallProtectionState>((ref) => CallProtectionNotifier(ref));

class CallProtectionState {
  final bool loading;
  final bool protectionActive;
  final int callsToday;
  final int fraudCallsBlocked;
  final int safeCalls;
  final int spamDetected;
  final List<CallLogModel> recentCalls;
  final List<CallLogModel> liveCalls;
  final String? error;

  const CallProtectionState({
    this.loading = false,
    this.protectionActive = true,
    this.callsToday = 0,
    this.fraudCallsBlocked = 0,
    this.safeCalls = 0,
    this.spamDetected = 0,
    this.recentCalls = const [],
    this.liveCalls = const [],
    this.error,
  });

  CallProtectionState copyWith({
    bool? loading,
    bool? protectionActive,
    int? callsToday,
    int? fraudCallsBlocked,
    int? safeCalls,
    int? spamDetected,
    List<CallLogModel>? recentCalls,
    List<CallLogModel>? liveCalls,
    String? error,
  }) => CallProtectionState(
    loading: loading ?? this.loading,
    protectionActive: protectionActive ?? this.protectionActive,
    callsToday: callsToday ?? this.callsToday,
    fraudCallsBlocked: fraudCallsBlocked ?? this.fraudCallsBlocked,
    safeCalls: safeCalls ?? this.safeCalls,
    spamDetected: spamDetected ?? this.spamDetected,
    recentCalls: recentCalls ?? this.recentCalls,
    liveCalls: liveCalls ?? this.liveCalls,
    error: error,
  );
}

class CallProtectionNotifier extends StateNotifier<CallProtectionState> {
  final Ref _ref;
  final ApiClient _api = ApiClient();

  CallProtectionNotifier(this._ref) : super(const CallProtectionState()) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = state.copyWith(loading: true);
    try {
      final response = await _api.get(ApiEndpoints.callProtection);
      final data = response.data;
      state = CallProtectionState(
        protectionActive: data['protection_active'] ?? true,
        callsToday: data['calls_today'] ?? 0,
        fraudCallsBlocked: data['fraud_calls_blocked'] ?? 0,
        safeCalls: data['safe_calls'] ?? 0,
        spamDetected: data['spam_detected'] ?? 0,
        recentCalls: (data['recent_calls'] as List<dynamic>?)
            ?.map((e) => CallLogModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        liveCalls: (data['live_calls'] as List<dynamic>?)
            ?.map((e) => CallLogModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> toggleProtection() async {
    try {
      await _api.post('${ApiEndpoints.callProtection}/toggle');
      state = state.copyWith(protectionActive: !state.protectionActive);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> blockNumber(String phoneNumber) async {
    try {
      await _api.post(ApiEndpoints.blockNumber, data: {'phone_number': phoneNumber});
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> reportCall(String phoneNumber) async {
    try {
      await _api.post(ApiEndpoints.reportCall, data: {'phone_number': phoneNumber});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<CallLogModel?> getCallAnalysis(String callId) async {
    try {
      final response = await _api.get('${ApiEndpoints.callProtection}/$callId');
      return CallLogModel.fromJson(response.data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}