import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

final alertProvider = StateNotifierProvider<AlertNotifier, AlertState>((ref) => AlertNotifier(ref));

class AlertState {
  final bool loading; final List<AlertModel> alerts; final int unreadCount;
  final String? error;
  const AlertState({this.loading = false, this.alerts = const [], this.unreadCount = 0, this.error});
  AlertState copyWith({bool? loading, List<AlertModel>? alerts, int? unreadCount, String? error}) =>
    AlertState(loading: loading ?? this.loading, alerts: alerts ?? this.alerts,
      unreadCount: unreadCount ?? this.unreadCount, error: error);
}

class AlertNotifier extends StateNotifier<AlertState> {
  final ApiClient _api = ApiClient();
  AlertNotifier(_) : super(const AlertState()) { loadAlerts(); }

  Future<void> loadAlerts() async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.get(ApiEndpoints.liveAlerts);
      final data = r.data;
      final alerts = (data['alerts'] as List<dynamic>?)
          ?.map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];
      state = AlertState(alerts: alerts, unreadCount: alerts.where((a) => !a.read).length);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<void> markAsRead(String alertId) async {
    try { await _api.post('${ApiEndpoints.liveAlerts}/$alertId/read'); await loadAlerts(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> markAllAsRead() async {
    try { await _api.post('${ApiEndpoints.liveAlerts}/read-all'); await loadAlerts(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> dismissAlert(String alertId) async {
    try { await _api.delete('${ApiEndpoints.liveAlerts}/$alertId'); await loadAlerts(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }
}