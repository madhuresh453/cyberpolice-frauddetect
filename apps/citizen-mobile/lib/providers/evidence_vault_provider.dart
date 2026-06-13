import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../utils/constants.dart';

final evidenceVaultProvider = StateNotifierProvider<EvidenceVaultNotifier, EvidenceVaultState>((ref) => EvidenceVaultNotifier(ref));

class EvidenceVaultState {
  final bool loading; final int totalFiles; final double usedStorage;
  final int syncedFiles; final int pendingSync; final List<dynamic> files;
  final String? error;

  const EvidenceVaultState({this.loading = false, this.totalFiles = 0, this.usedStorage = 0,
    this.syncedFiles = 0, this.pendingSync = 0, this.files = const [], this.error});

  EvidenceVaultState copyWith({bool? loading, int? totalFiles, double? usedStorage,
    int? syncedFiles, int? pendingSync, List<dynamic>? files, String? error}) =>
    EvidenceVaultState(loading: loading ?? this.loading, totalFiles: totalFiles ?? this.totalFiles,
      usedStorage: usedStorage ?? this.usedStorage, syncedFiles: syncedFiles ?? this.syncedFiles,
      pendingSync: pendingSync ?? this.pendingSync, files: files ?? this.files, error: error);
}

class EvidenceVaultNotifier extends StateNotifier<EvidenceVaultState> {
  final Ref _ref; final ApiClient _api = ApiClient();
  EvidenceVaultNotifier(this._ref) : super(const EvidenceVaultState()) { loadFiles(); }

  Future<void> loadFiles() async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.get(ApiEndpoints.evidenceUpload);
      final d = r.data as Map<String, dynamic>;
      state = EvidenceVaultState(totalFiles: d['total_files'] ?? 0, usedStorage: (d['used_storage'] ?? 0).toDouble(),
        syncedFiles: d['synced_files'] ?? 0, pendingSync: d['pending_sync'] ?? 0,
        files: d['files'] as List<dynamic>? ?? []);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<Map<String, dynamic>?> uploadFile(String filePath, String fileType) async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.post(ApiEndpoints.evidenceUpload, data: {
        'file_path': filePath, 'file_type': fileType, 'timestamp': DateTime.now().toIso8601String(),
      });
      await loadFiles();
      return r.data as Map<String, dynamic>;
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); return null; }
  }

  Future<void> deleteFile(String fileId) async {
    try { await _api.delete('${ApiEndpoints.evidenceUpload}/$fileId'); await loadFiles(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> syncFiles() async {
    try { await _api.post(ApiEndpoints.offlineSync); await loadFiles(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<String?> getFileUrl(String fileId) async {
    try {
      final r = await _api.get('${ApiEndpoints.evidenceUpload}/$fileId/download');
      final d = r.data as Map<String, dynamic>; return d['url'] as String?;
    } catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }
}