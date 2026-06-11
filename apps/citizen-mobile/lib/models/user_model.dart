class UserModel {
  final String id;
  final String email;
  final String phoneNumber;
  final String fullName;
  final String role;
  final String status;

  UserModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        phoneNumber: json['phone_number'] ?? '',
        fullName: json['full_name'] ?? '',
        role: json['role'] ?? 'citizen',
        status: json['status'] ?? 'active',
      );

  String get name => fullName;
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone_number': phoneNumber,
        'full_name': fullName,
        'role': role,
        'status': status,
      };
}

class TrustScoreModel {
  final String phoneNumber;
  final int trustScore;
  final String riskCategory;
  final String verificationStatus;
  final int totalReports;
  final List<String> reasons;
  final List<RiskFactor> riskFactors;
  final List<TrendPoint> trend;

  TrustScoreModel({
    required this.phoneNumber,
    required this.trustScore,
    required this.riskCategory,
    required this.verificationStatus,
    required this.totalReports,
    required this.reasons,
    required this.riskFactors,
    required this.trend,
  });

  factory TrustScoreModel.fromJson(Map<String, dynamic> json) => TrustScoreModel(
        phoneNumber: json['phone_number'] ?? '',
        trustScore: json['trust_score'] ?? 50,
        riskCategory: json['risk_category'] ?? 'unknown',
        verificationStatus: json['verification_status'] ?? 'unverified',
        totalReports: json['total_reports'] ?? 0,
        reasons: List<String>.from(json['reasons'] ?? []),
        riskFactors: (json['risk_factors'] as List?)?.map((e) => RiskFactor.fromJson(e)).toList() ?? [],
        trend: (json['trend'] as List?)?.map((e) => TrendPoint.fromJson(e)).toList() ?? [],
      );

  int get score => trustScore;
  String get status => riskCategory[0].toUpperCase() + riskCategory.substring(1);
  int get riskScore => 100 - trustScore;

  bool get isSafe => riskCategory == 'safe';
  bool get isLow => riskCategory == 'low';
  bool get isMedium => riskCategory == 'medium';
  bool get isHigh => riskCategory == 'high';
  bool get isCritical => riskCategory == 'critical';
}

class RiskFactor {
  final String factor;
  final int impact;
  final String details;

  RiskFactor({required this.factor, required this.impact, required this.details});

  factory RiskFactor.fromJson(Map<String, dynamic> json) => RiskFactor(
        factor: json['factor'] ?? '',
        impact: json['impact'] ?? 0,
        details: json['details'] ?? '',
      );
}

class TrendPoint {
  final String date;
  final int count;

  TrendPoint({required this.date, required this.count});

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
        date: json['date'] ?? '',
        count: json['count'] ?? 0,
      );
}

class FraudReportModel {
  final String id;
  final String type;
  final String status;
  final String? description;
  final DateTime createdAt;
  final String? fraudType;

  FraudReportModel({
    required this.id,
    required this.type,
    required this.status,
    this.description,
    required this.createdAt,
    this.fraudType,
  });

  factory FraudReportModel.fromJson(Map<String, dynamic> json) => FraudReportModel(
        id: json['id'] ?? '',
        type: json['type'] ?? '',
        status: json['status'] ?? '',
        description: json['description'] ?? json['notes'] ?? '',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        fraudType: json['fraud_type'] ?? json['type'] ?? '',
      );
}

class EmergencySosModel {
  final String id;
  final String status;
  final String message;

  EmergencySosModel({required this.id, required this.status, required this.message});

  factory EmergencySosModel.fromJson(Map<String, dynamic> json) => EmergencySosModel(
        id: json['id'] ?? '',
        status: json['status'] ?? '',
        message: json['message'] ?? '',
      );
}

class FamilyMemberModel {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final String status;

  FamilyMemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    required this.status,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) => FamilyMemberModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        relation: json['relation'] ?? '',
        status: json['status'] ?? 'pending',
      );
}

class AnalysisResult {
  final String id;
  final String status;
  final int confidence;
  final Map<String, dynamic>? results;

  AnalysisResult({
    required this.id,
    required this.status,
    required this.confidence,
    this.results,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        id: json['id'] ?? '',
        status: json['status'] ?? '',
        confidence: json['confidence'] ?? 0,
        results: json['results'],
      );

  bool get isDeepfake => confidence > 70;
  String get riskLevel => confidence > 85 ? 'high' : confidence > 60 ? 'medium' : 'low';
}