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
      return TrustScoreModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FraudReportModel>> getHistory({int page = 1, int limit = 20, String? status, String? type}) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      final response = await _api.get(ApiEndpoints.history, queryParameters: queryParams);
      final data = response.data as Map<String, dynamic>;
      final reports = (data['data'] as List).map((e) => FraudReportModel.fromJson(e as Map<String, dynamic>)).toList();
      return reports;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> blockNumber(String phoneNumber, {String? reason}) async {
    try {
      await _api.post(ApiEndpoints.blockNumber, data: {
        'phone_number': phoneNumber,
        'reason': reason ?? 'User blocked',
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFamilyProtection() async {
    try {
      final response = await _api.get(ApiEndpoints.familyProtection);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reportCall(String caller, String receiver, {String? notes, int? duration}) async {
    try {
      final response = await _api.post(ApiEndpoints.reportCall, data: {
        'caller_number': caller,
        'receiver_number': receiver,
        'notes': notes,
        'duration': duration ?? 0,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reportSms(String fromNumber, String messageBody) async {
    try {
      final response = await _api.post(ApiEndpoints.reportSms, data: {
        'from_number': fromNumber,
        'message_body': messageBody,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reportWhatsapp(String fromNumber, String messageBody, {List<String>? mediaUrls}) async {
    try {
      final response = await _api.post(ApiEndpoints.reportWhatsapp, data: {
        'from_number': fromNumber,
        'message_body': messageBody,
        'media_urls': mediaUrls ?? [],
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendEmergencySos({Map<String, dynamic>? location, String? message}) async {
    try {
      final response = await _api.post(ApiEndpoints.emergencySos, data: {
        'location': location,
        'message': message ?? 'SOS Emergency',
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> uploadEvidence(String reportId, String fileUrl, String fileType, {String? description}) async {
    try {
      await _api.post(ApiEndpoints.evidenceUpload, data: {
        'report_id': reportId,
        'file_url': fileUrl,
        'file_type': fileType,
        'description': description,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }
}