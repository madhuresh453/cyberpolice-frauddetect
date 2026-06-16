import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../utils/constants.dart';

final bankProtectionProvider = StateNotifierProvider<BankProtectionNotifier, BankProtectionState>((ref) => BankProtectionNotifier(ref));

class BankProtectionState {
  final bool loading; final bool protectionActive; final int accountsLinked;
  final int fraudDetected; final int freezeRequests; final double amountSaved;
  final List<dynamic> recentActivity; final String? error;

  const BankProtectionState({this.loading = false, this.protectionActive = true, this.accountsLinked = 0,
    this.fraudDetected = 0, this.freezeRequests = 0, this.amountSaved = 0, this.recentActivity = const [], this.error});

  BankProtectionState copyWith({bool? loading, bool? protectionActive, int? accountsLinked,
    int? fraudDetected, int? freezeRequests, double? amountSaved, List<dynamic>? recentActivity, String? error}) =>
    BankProtectionState(loading: loading ?? this.loading, protectionActive: protectionActive ?? this.protectionActive,
      accountsLinked: accountsLinked ?? this.accountsLinked, fraudDetected: fraudDetected ?? this.fraudDetected,
      freezeRequests: freezeRequests ?? this.freezeRequests, amountSaved: amountSaved ?? this.amountSaved,
      recentActivity: recentActivity ?? this.recentActivity, error: error);
}

class BankProtectionNotifier extends StateNotifier<BankProtectionState> {
  final Ref _ref; final ApiClient _api = ApiClient();
  BankProtectionNotifier(this._ref) : super(const BankProtectionState()) { loadStats(); }

  Future<void> loadStats() async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.get(ApiEndpoints.bankProtection);
      final d = r.data;
      state = BankProtectionState(protectionActive: d['protection_active'] ?? true,
        accountsLinked: d['accounts_linked'] ?? 0, fraudDetected: d['fraud_detected'] ?? 0,
        freezeRequests: d['freeze_requests'] ?? 0, amountSaved: (d['amount_saved'] ?? 0).toDouble(),
        recentActivity: d['recent_activity'] as List<dynamic>? ?? []);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<Map<String, dynamic>?> verifyAccount(String accountNumber, String ifsc) async {
    try {
      final r = await _api.post(ApiEndpoints.bankVerify, data: {'account_number': accountNumber, 'ifsc': ifsc});
      return r.data;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<Map<String, dynamic>?> requestFreeze(String accountNumber, String reason) async {
    try {
      final r = await _api.post(ApiEndpoints.bankFreeze, data: {'account_number': accountNumber, 'reason': reason});
      state = state.copyWith(freezeRequests: state.freezeRequests + 1);
      return r.data;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<Map<String, dynamic>?> emergencyFreeze(String accountNumber) async {
    try {
      final r = await _api.post('${ApiEndpoints.bankFreeze}/emergency', data: {'account_number': accountNumber});
      return r.data;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<Map<String, dynamic>?> disputeTransaction(String transactionId, String reason) async {
    try {
      final r = await _api.post(ApiEndpoints.bankDispute, data: {'transaction_id': transactionId, 'reason': reason});
      return r.data;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<List<dynamic>> getFreezeRequests() async {
    try {
      final r = await _api.get(ApiEndpoints.bankFreeze);
      return r.data as List<dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString()); return []; }
  }
}