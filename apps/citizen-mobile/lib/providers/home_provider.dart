import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/trust_score_repository.dart';
import '../models/user_model.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) => HomeNotifier(ref));

class HomeState {
  final bool loading;
  final TrustScoreModel? trustScore;
  final List<FraudReportModel> recentReports;
  final Map<String, dynamic>? familyData;
  final String? error;

  const HomeState({
    this.loading = false,
    this.trustScore,
    this.recentReports = const [],
    this.familyData,
    this.error,
  });

  HomeState copyWith({
    bool? loading,
    TrustScoreModel? trustScore,
    List<FraudReportModel>? recentReports,
    Map<String, dynamic>? familyData,
    String? error,
  }) =>
      HomeState(
        loading: loading ?? this.loading,
        trustScore: trustScore ?? this.trustScore,
        recentReports: recentReports ?? this.recentReports,
        familyData: familyData ?? this.familyData,
        error: error,
      );
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref _ref;
  HomeNotifier(this._ref) : super(const HomeState());

  Future<void> loadDashboard(String phoneNumber) async {
    state = state.copyWith(loading: true);
    try {
      final repo = _ref.read(trustScoreRepositoryProvider);
      final results = await Future.wait([
        repo.getTrustScore(phoneNumber),
        repo.getHistory(limit: 5),
        repo.getFamilyProtection(),
      ]);
      state = HomeState(
        trustScore: results[0] as TrustScoreModel,
        recentReports: results[1] as List<FraudReportModel>,
        familyData: results[2] as Map<String, dynamic>,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}