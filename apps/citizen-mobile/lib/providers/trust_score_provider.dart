import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

final trustScoreProvider = StateNotifierProvider<TrustScoreNotifier, TrustScoreState>((ref) => TrustScoreNotifier(ref));

class TrustScoreState {
  final bool loading; final TrustScoreModel? trustScore; final List<dynamic> scoreHistory;
  final List<dynamic> riskFactors; final String? error;
  const TrustScoreState({this.loading = false, this.trustScore, this.scoreHistory = const [],
    this.riskFactors = const [], this.error});
  TrustScoreState copyWith({bool? loading, TrustScoreModel? trustScore, List<dynamic>? scoreHistory,
    List<dynamic>? riskFactors, String? error}) => TrustScoreState(loading: loading ?? this.loading,
      trustScore: trustScore ?? this.trustScore, scoreHistory: scoreHistory ?? this.scoreHistory,
      riskFactors: riskFactors ?? this.riskFactors, error: error);
}

class TrustScoreNotifier extends StateNotifier<TrustScoreState> {
  final Ref _ref; final ApiClient _api = ApiClient();
  TrustScoreNotifier(this._ref) : super(const TrustScoreState());

  Future<void> loadTrustScore(String phoneNumber) async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.get('${ApiEndpoints.trustScore}/$phoneNumber');
      final d = r.data as Map<String, dynamic>;
      state = TrustScoreState(trustScore: TrustScoreModel.fromJson(d),
        scoreHistory: d['history'] as List<dynamic>? ?? [],
        riskFactors: d['risk_factors'] as List<dynamic>? ?? []);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<void> refreshScore(String phoneNumber) async {
    try {
      final r = await _api.post('${ApiEndpoints.trustScore}/refresh', data: {'phone_number': phoneNumber});
      final d = r.data as Map<String, dynamic>;
      state = state.copyWith(trustScore: TrustScoreModel.fromJson(d));
    } catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<Map<String, dynamic>?> checkNumber(String phoneNumber) async {
    try {
      final r = await _api.get('${ApiEndpoints.trustScore}/check/$phoneNumber');
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<Map<String, dynamic>?> checkUpiId(String upiId) async {
    try {
      final r = await _api.get('${ApiEndpoints.trustScore}/upi/$upiId');
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<Map<String, dynamic>?> checkBankAccount(String accountNumber, String ifsc) async {
    try {
      final r = await _api.post('${ApiEndpoints.trustScore}/bank', data: {'account_number': accountNumber, 'ifsc': ifsc});
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<Map<String, dynamic>?> checkWebsite(String url) async {
    try {
      final r = await _api.post('${ApiEndpoints.trustScore}/website', data: {'url': url});
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<Map<String, dynamic>?> checkEmail(String email) async {
    try {
      final r = await _api.post('${ApiEndpoints.trustScore}/email', data: {'email': email});
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }
}