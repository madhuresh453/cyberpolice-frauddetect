import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../utils/constants.dart';

final deepfakeProvider = StateNotifierProvider<DeepfakeNotifier, DeepfakeState>((ref) => DeepfakeNotifier(ref));

class DeepfakeState {
  final bool loading; final bool detectionActive; final int totalAnalyses;
  final int fraudDetected; final int safeAnalyses; final List<dynamic> recentAnalyses;
  final Map<String, dynamic>? currentAnalysis; final String? error;

  const DeepfakeState({this.loading = false, this.detectionActive = true, this.totalAnalyses = 0,
    this.fraudDetected = 0, this.safeAnalyses = 0, this.recentAnalyses = const [],
    this.currentAnalysis, this.error});

  DeepfakeState copyWith({bool? loading, bool? detectionActive, int? totalAnalyses,
    int? fraudDetected, int? safeAnalyses, List<dynamic>? recentAnalyses,
    Map<String, dynamic>? currentAnalysis, String? error}) =>
    DeepfakeState(loading: loading ?? this.loading, detectionActive: detectionActive ?? this.detectionActive,
      totalAnalyses: totalAnalyses ?? this.totalAnalyses, fraudDetected: fraudDetected ?? this.fraudDetected,
      safeAnalyses: safeAnalyses ?? this.safeAnalyses, recentAnalyses: recentAnalyses ?? this.recentAnalyses,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis, error: error);
}

class DeepfakeNotifier extends StateNotifier<DeepfakeState> {
  final Ref _ref; final ApiClient _api = ApiClient();
  DeepfakeNotifier(this._ref) : super(const DeepfakeState()) { loadStats(); }

  Future<void> loadStats() async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.get('${ApiEndpoints.deepfakeResult}/stats');
      final d = r.data as Map<String, dynamic>;
      state = DeepfakeState(detectionActive: d['detection_active'] ?? true,
        totalAnalyses: d['total_analyses'] ?? 0, fraudDetected: d['fraud_detected'] ?? 0,
        safeAnalyses: d['safe_analyses'] ?? 0, recentAnalyses: d['recent_analyses'] as List<dynamic>? ?? []);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<Map<String, dynamic>?> analyzeVoice(String filePath) async {
    state = state.copyWith(loading: true);
    try {
      final formData = {'file_path': filePath};
      final r = await _api.post(ApiEndpoints.deepfakeVoice, data: formData);
      state = state.copyWith(currentAnalysis: r.data as Map<String, dynamic>, loading: false);
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); return null; }
  }

  Future<Map<String, dynamic>?> analyzeVideo(String filePath) async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.post(ApiEndpoints.deepfakeVideo, data: {'file_path': filePath});
      state = state.copyWith(currentAnalysis: r.data as Map<String, dynamic>, loading: false);
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); return null; }
  }

  Future<Map<String, dynamic>?> analyzeRealtime() async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.post(ApiEndpoints.deepfakeRealtime);
      state = state.copyWith(currentAnalysis: r.data as Map<String, dynamic>, loading: false);
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); return null; }
  }

  Future<Map<String, dynamic>?> getAnalysisResult(String analysisId) async {
    try {
      final r = await _api.get('${ApiEndpoints.deepfakeResult}/$analysisId');
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }
}