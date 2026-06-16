import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

final trustScoreRepositoryProvider = Provider<TrustScoreRepository>((ref) => TrustScoreRepository());

class TrustScoreRepository {
  final ApiClient _api = ApiClient();

  Future<TrustScoreModel> getTrustScore(String phoneNumber) async {
    try {
      final response = await _api.get('${ApiEndpoints.trustScore}/$phoneNumber');
      return TrustScoreModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FraudReportModel>> getHistory({int limit = 10}) async {
    try {
      final response = await _api.get('${ApiEndpoints.history}?limit=$limit');
      final data = response.data as List<dynamic>;
      return data.map((e) => FraudReportModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFamilyProtection() async {
    try {
      final response = await _api.get(ApiEndpoints.familyProtection);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<FraudReportModel> reportFraud(Map<String, dynamic> reportData) async {
    try {
      final response = await _api.post(ApiEndpoints.reportCall, data: reportData);
      return FraudReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> blockNumber(String phoneNumber) async {
    try {
      await _api.post(ApiEndpoints.blockNumber, data: {'phone_number': phoneNumber});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmergencySos(Map<String, dynamic> sosData) async {
    try {
      await _api.post(ApiEndpoints.emergencySos, data: sosData);
    } catch (e) {
      rethrow;
    }
  }

  Future<FraudReportModel> reportCall(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiEndpoints.reportCall, data: data);
      return FraudReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FraudReportModel> reportSms(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiEndpoints.reportSms, data: data);
      return FraudReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FraudReportModel> reportWhatsapp(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiEndpoints.reportWhatsapp, data: data);
      return FraudReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboard(String phoneNumber) async {
    try {
      final response = await _api.get('${ApiEndpoints.dashboard}/$phoneNumber');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Aliases for backward compatibility
  Future<void> sendEmergencySosWithDetails(String location, String message) async {
    await sendEmergencySos({
      'location': location,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<FraudReportModel> reportCallWithNotes(String phoneNumber, String notes) async {
    return reportCall({'phone_number': phoneNumber, 'notes': notes, 'type': 'CALL'});
  }
  
  Future<FraudReportModel> reportSmsWithDetails(String sender, String message) async {
    return reportSms({'sender': sender, 'message': message, 'type': 'SMS'});
  }
  
  Future<FraudReportModel> reportWhatsappWithDetails(String sender, String message) async {
    return reportWhatsapp({'sender': sender, 'message': message, 'type': 'WHATSAPP'});
  }
}