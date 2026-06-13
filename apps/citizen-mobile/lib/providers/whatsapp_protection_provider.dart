import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../utils/constants.dart';

final whatsappProtectionProvider = StateNotifierProvider<WhatsappProtectionNotifier, WhatsappProtectionState>((ref) => WhatsappProtectionNotifier(ref));

class WhatsappProtectionState {
  final bool loading; final bool protectionActive; final int totalMessages;
  final int fraudDetected; final int safeMessages; final List<dynamic> recentMessages;
  final String? error;
  const WhatsappProtectionState({this.loading = false, this.protectionActive = true,
    this.totalMessages = 0, this.fraudDetected = 0, this.safeMessages = 0,
    this.recentMessages = const [], this.error});
  WhatsappProtectionState copyWith({bool? loading, bool? protectionActive, int? totalMessages,
    int? fraudDetected, int? safeMessages, List<dynamic>? recentMessages, String? error}) =>
    WhatsappProtectionState(loading: loading ?? this.loading, protectionActive: protectionActive ?? this.protectionActive,
      totalMessages: totalMessages ?? this.totalMessages, fraudDetected: fraudDetected ?? this.fraudDetected,
      safeMessages: safeMessages ?? this.safeMessages, recentMessages: recentMessages ?? this.recentMessages, error: error);
}

class WhatsappProtectionNotifier extends StateNotifier<WhatsappProtectionState> {
  final Ref _ref; final ApiClient _api = ApiClient();
  WhatsappProtectionNotifier(this._ref) : super(const WhatsappProtectionState()) { loadStats(); }

  Future<void> loadStats() async {
    state = state.copyWith(loading: true);
    try {
      final response = await _api.get(ApiEndpoints.whatsappProtection);
      final d = response.data as Map<String, dynamic>;
      state = WhatsappProtectionState(protectionActive: d['protection_active'] ?? true,
        totalMessages: d['total_messages'] ?? 0, fraudDetected: d['fraud_detected'] ?? 0,
        safeMessages: d['safe_messages'] ?? 0, recentMessages: d['recent_messages'] as List<dynamic>? ?? []);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<void> toggleProtection() async {
    try { await _api.post('${ApiEndpoints.whatsappProtection}/toggle'); state = state.copyWith(protectionActive: !state.protectionActive); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> reportMessage(String sender, String message) async {
    try { await _api.post(ApiEndpoints.reportWhatsapp, data: {'sender': sender, 'message': message}); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<Map<String, dynamic>?> analyzeMessage(String text) async {
    try { final r = await _api.post('${ApiEndpoints.whatsappProtection}/analyze', data: {'text': text}); return r.data as Map<String, dynamic>; }
    catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }
}