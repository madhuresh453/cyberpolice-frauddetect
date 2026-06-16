import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../utils/constants.dart';

final upiProtectionProvider = StateNotifierProvider<UpiProtectionNotifier, UpiProtectionState>((ref) => UpiProtectionNotifier(ref));

class UpiProtectionState {
  final bool loading; final bool protectionActive; final int transactionsToday;
  final int fraudDetected; final int safeTransactions; final double amountSaved;
  final List<dynamic> recentTransactions; final String? error;

  const UpiProtectionState({this.loading = false, this.protectionActive = true, this.transactionsToday = 0,
    this.fraudDetected = 0, this.safeTransactions = 0, this.amountSaved = 0, this.recentTransactions = const [], this.error});

  UpiProtectionState copyWith({bool? loading, bool? protectionActive, int? transactionsToday,
    int? fraudDetected, int? safeTransactions, double? amountSaved, List<dynamic>? recentTransactions, String? error}) =>
    UpiProtectionState(loading: loading ?? this.loading, protectionActive: protectionActive ?? this.protectionActive,
      transactionsToday: transactionsToday ?? this.transactionsToday, fraudDetected: fraudDetected ?? this.fraudDetected,
      safeTransactions: safeTransactions ?? this.safeTransactions, amountSaved: amountSaved ?? this.amountSaved,
      recentTransactions: recentTransactions ?? this.recentTransactions, error: error);
}

class UpiProtectionNotifier extends StateNotifier<UpiProtectionState> {
  final Ref _ref; final ApiClient _api = ApiClient();
  UpiProtectionNotifier(this._ref) : super(const UpiProtectionState()) { loadStats(); }

  Future<void> loadStats() async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.get(ApiEndpoints.upiProtection);
      final d = r.data;
      state = UpiProtectionState(protectionActive: d['protection_active'] ?? true,
        transactionsToday: d['transactions_today'] ?? 0, fraudDetected: d['fraud_detected'] ?? 0,
        safeTransactions: d['safe_transactions'] ?? 0, amountSaved: (d['amount_saved'] ?? 0).toDouble(),
        recentTransactions: d['recent_transactions'] as List<dynamic>? ?? []);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<Map<String, dynamic>?> verifyUpiId(String upiId) async {
    try {
      final r = await _api.post('${ApiEndpoints.upiProtection}/verify', data: {'upi_id': upiId});
      return r.data;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<Map<String, dynamic>?> checkMerchantReputation(String upiId) async {
    try {
      final r = await _api.get('${ApiEndpoints.upiProtection}/merchant/$upiId');
      return r.data;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<void> reportFraudTransaction(Map<String, dynamic> data) async {
    try { await _api.post(ApiEndpoints.reportCall, data: {'...upi': data}); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }
}