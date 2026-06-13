import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

final emergencyProvider = StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) => EmergencyNotifier(ref));

class EmergencyState {
  final bool loading; final bool sosActive; final double? latitude; final double? longitude;
  final String? locationAddress; final List<EmergencyContactModel> contacts;
  final int emergencyQueue; final String? error;
  const EmergencyState({this.loading = false, this.sosActive = false, this.latitude, this.longitude,
    this.locationAddress, this.contacts = const [], this.emergencyQueue = 0, this.error});
  EmergencyState copyWith({bool? loading, bool? sosActive, double? latitude, double? longitude,
    String? locationAddress, List<EmergencyContactModel>? contacts, int? emergencyQueue, String? error}) =>
    EmergencyState(loading: loading ?? this.loading, sosActive: sosActive ?? this.sosActive,
      latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress, contacts: contacts ?? this.contacts,
      emergencyQueue: emergencyQueue ?? this.emergencyQueue, error: error);
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  final Ref _ref; final ApiClient _api = ApiClient();
  EmergencyNotifier(this._ref) : super(const EmergencyState()) { loadContacts(); }

  Future<void> loadContacts() async {
    try {
      final response = await _api.get(ApiEndpoints.emergencyContact);
      final data = response.data as List<dynamic>;
      state = state.copyWith(contacts: data.map((e) => EmergencyContactModel.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> triggerSos({double? latitude, double? longitude, String? address}) async {
    state = state.copyWith(loading: true);
    try {
      await _api.post(ApiEndpoints.emergencySos, data: {
        'latitude': latitude ?? state.latitude, 'longitude': longitude ?? state.longitude,
        'address': address ?? state.locationAddress, 'timestamp': DateTime.now().toIso8601String(),
      });
      state = state.copyWith(sosActive: true, loading: false);
    } catch (e) { state = state.copyWith(error: e.toString(), loading: false); }
  }

  Future<void> cancelSos() async {
    try { await _api.post('${ApiEndpoints.emergencySos}/cancel'); }
    catch (e) { state = state.copyWith(error: e.toString()); }
    state = state.copyWith(sosActive: false);
  }

  Future<void> addContact(String name, String phone, String relation) async {
    try { await _api.post(ApiEndpoints.emergencyContact, data: {'name': name, 'phone_number': phone, 'relation': relation}); await loadContacts(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> removeContact(String id) async {
    try { await _api.delete('${ApiEndpoints.emergencyContact}/$id'); await loadContacts(); }
    catch (e) { state = state.copyWith(error: e.toString()); }
  }

  Future<void> updateLocation(double lat, double lng) async {
    state = state.copyWith(latitude: lat, longitude: lng);
  }
}