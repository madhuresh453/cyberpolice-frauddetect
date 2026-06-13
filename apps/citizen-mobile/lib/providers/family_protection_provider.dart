import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../utils/constants.dart';

final familyProtectionProvider = StateNotifierProvider<FamilyProtectionNotifier, FamilyProtectionState>((ref) => FamilyProtectionNotifier(ref));

class FamilyProtectionState {
  final bool loading; final List<dynamic> members; final bool seniorMode;
  final bool childProtection; final int alertsToday; final String? error;
  const FamilyProtectionState({this.loading = false, this.members = const [], this.seniorMode = false,
    this.childProtection = false, this.alertsToday = 0, this.error});
  FamilyProtectionState copyWith({bool? loading, List<dynamic>? members, bool? seniorMode,
    bool? childProtection, int? alertsToday, String? error}) =>
    FamilyProtectionState(loading: loading ?? this.loading, members: members ?? this.members,
      seniorMode: seniorMode ?? this.seniorMode, childProtection: childProtection ?? this.childProtection,
      alertsToday: alertsToday ?? this.alertsToday, error: error);
}

class FamilyProtectionNotifier extends StateNotifier<FamilyProtectionState> {
  final Ref _ref; final ApiClient _api = ApiClient();
  FamilyProtectionNotifier(this._ref) : super(const FamilyProtectionState()) { loadMembers(); }

  Future<void> loadMembers() async {
    state = state.copyWith(loading: true);
    try {
      final r = await _api.get(ApiEndpoints.familyProtection);
      final d = r.data as Map<String, dynamic>;
      state = FamilyProtectionState(members: d['members'] as List<dynamic>? ?? [],
        seniorMode: d['senior_mode'] ?? false, childProtection: d['child_protection'] ?? false,
        alertsToday: d['alerts_today'] ?? 0);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<void> addMember(String name, String phone, String relation) async {
    try { await _api.post(ApiEndpoints.familyProtection, data: {'name': name, 'phone_number': phone, 'relation': relation}); await loadMembers(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> removeMember(String memberId) async {
    try { await _api.delete('${ApiEndpoints.familyProtection}/$memberId'); await loadMembers(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> toggleSeniorMode() async {
    try { await _api.post('${ApiEndpoints.familyProtection}/senior-mode/toggle'); state = state.copyWith(seniorMode: !state.seniorMode); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> toggleChildProtection() async {
    try { await _api.post('${ApiEndpoints.familyProtection}/child-protection/toggle'); state = state.copyWith(childProtection: !state.childProtection); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<Map<String, dynamic>?> getMemberTrustScore(String phone) async {
    try { final r = await _api.get('${ApiEndpoints.familyProtection}/trust-score/$phone'); return r.data as Map<String, dynamic>; }
    catch (e) { state = state.copyWith(error: e.toString()); return null; }
  }

  Future<void> sendEmergencyToFamily(String message) async {
    try { await _api.post('${ApiEndpoints.familyProtection}/emergency', data: {'message': message}); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }
}