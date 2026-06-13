import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String phoneNumber;
  final String fullName;
  final String name;
  final String userType;
  final List<String> roles;
  final List<String> permissions;
  final String status;
  final bool mfaEnabled;
  final bool biometricEnabled;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? deviceInfo;

  const UserModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    this.name = '',
    this.userType = 'citizen',
    this.roles = const ['citizen'],
    this.permissions = const [],
    this.status = 'active',
    this.mfaEnabled = false,
    this.biometricEnabled = false,
    this.lastLoginAt,
    this.createdAt,
    this.profileImageUrl,
    this.deviceInfo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phone'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      userType: json['user_type'] ?? 'citizen',
      roles: List<String>.from(json['roles'] ?? ['citizen']),
      permissions: List<String>.from(json['permissions'] ?? []),
      status: json['status'] ?? 'active',
      mfaEnabled: json['mfa_enabled'] ?? false,
      biometricEnabled: json['biometric_enabled'] ?? false,
      lastLoginAt: json['last_login_at'] != null ? DateTime.tryParse(json['last_login_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      profileImageUrl: json['profile_image_url'],
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'user_type': userType,
      'roles': roles,
      'permissions': permissions,
      'status': status,
      'mfa_enabled': mfaEnabled,
      'biometric_enabled': biometricEnabled,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'profile_image_url': profileImageUrl,
    };
  }

  @override
  List<Object?> get props => [id, email, phoneNumber, fullName, userType, status];

  UserModel copyWith({
    String? id, String? email, String? phoneNumber, String? fullName,
    String? userType, List<String>? roles, List<String>? permissions,
    String? status, bool? mfaEnabled, bool? biometricEnabled,
    DateTime? lastLoginAt, DateTime? createdAt, String? profileImageUrl,
  }) => UserModel(
    id: id ?? this.id, email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    fullName: fullName ?? this.fullName, userType: userType ?? this.userType,
    roles: roles ?? this.roles, permissions: permissions ?? this.permissions,
    status: status ?? this.status, mfaEnabled: mfaEnabled ?? this.mfaEnabled,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    createdAt: createdAt ?? this.createdAt,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
  );
}

class FamilyMemberModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final String status;

  const FamilyMemberModel({
    required this.id, this.name = '', this.phone = '',
    this.relation = '', this.status = 'active',
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      relation: json['relation'] ?? json['relationship'] ?? '',
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone_number': phone,
    'relation': relation, 'status': status,
  };

  FamilyMemberModel copyWith({String? name, String? phone, String? relation, String? status}) =>
    FamilyMemberModel(id: id, name: name ?? this.name, phone: phone ?? this.phone,
      relation: relation ?? this.relation, status: status ?? this.status);

  @override
  List<Object?> get props => [id, name, phone, relation, status];
}

class TrustScoreModel extends Equatable {
  final int score;
  final String status;
  final int totalReports;
  final int safeReports;
  final int fraudReports;
  final int pendingReports;
  final List<RiskFactor> riskFactors;
  final DateTime lastUpdated;
  final List<ScoreHistory> history;

  const TrustScoreModel({
    this.score = 750,
    this.status = 'Safe',
    this.totalReports = 0,
    this.safeReports = 0,
    this.fraudReports = 0,
    this.pendingReports = 0,
    this.riskFactors = const [],
    required this.lastUpdated,
    this.history = const [],
  });

  /// Alias for score - used by some screens
  double get riskScore => score.toDouble();

  /// Alias for score - used by digital_trust_screen
  double get trustLevel => score.toDouble();

  /// Alias for status - used for confidence display
  String get riskLevel => status;

  /// Alias for history
  List<ScoreHistory> get confidence => history;

  factory TrustScoreModel.fromJson(Map<String, dynamic> json) {
    return TrustScoreModel(
      score: json['score'] ?? json['trust_score'] ?? 0,
      status: json['status'] ?? json['risk_category'] ?? 'Safe',
      totalReports: json['total_reports'] ?? json['totalReports'] ?? 0,
      safeReports: json['safe_reports'] ?? json['safeReports'] ?? 0,
      fraudReports: json['fraud_reports'] ?? json['fraudReports'] ?? 0,
      pendingReports: json['pending_reports'] ?? json['pendingReports'] ?? 0,
      riskFactors: (json['risk_factors'] as List<dynamic>?)
          ?.map((e) => RiskFactor.fromJson(e))
          .toList() ?? [],
      lastUpdated: (json['last_updated'] != null && json['last_updated'] is String)
          ? (DateTime.tryParse(json['last_updated']) ?? DateTime.now())
          : DateTime.now(),
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => ScoreHistory.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score, 'status': status, 'total_reports': totalReports,
    'safe_reports': safeReports, 'fraud_reports': fraudReports,
    'pending_reports': pendingReports, 'last_updated': lastUpdated.toIso8601String(),
  };

  @override
  List<Object?> get props => [score, status, totalReports];
}

class RiskFactor extends Equatable {
  final String name;
  final String severity;
  final String description;
  final DateTime detected;

  const RiskFactor({
    required this.name,
    this.severity = 'low',
    this.description = '',
    required this.detected,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      name: json['name'] ?? '',
      severity: json['severity'] ?? 'low',
      description: json['description'] ?? '',
      detected: json['detected'] != null
          ? DateTime.tryParse(json['detected']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [name, severity];
}

class ScoreHistory extends Equatable {
  final int score;
  final String event;
  final DateTime timestamp;

  const ScoreHistory({
    this.score = 0,
    this.event = '',
    required this.timestamp,
  });

  factory ScoreHistory.fromJson(Map<String, dynamic> json) {
    return ScoreHistory(
      score: json['score'] ?? 0,
      event: json['event'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [score, event, timestamp];
}

class FraudReportModel extends Equatable {
  final String id;
  final String type;
  final String fraudType;
  final String status;
  final String description;
  final String phoneNumber;
  final double amount;
  final DateTime createdAt;
  final String? evidenceUrl;

  const FraudReportModel({
    required this.id,
    this.type = '',
    this.fraudType = '',
    this.status = 'PENDING',
    this.description = '',
    this.phoneNumber = '',
    this.amount = 0,
    required this.createdAt,
    this.evidenceUrl,
  });

  factory FraudReportModel.fromJson(Map<String, dynamic> json) {
    return FraudReportModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: json['type'] ?? json['fraud_type'] ?? '',
      fraudType: json['fraud_type'] ?? json['type'] ?? '',
      status: json['status'] ?? 'PENDING',
      description: json['description'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phone'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      evidenceUrl: json['evidence_url'],
    );
  }

  @override
  List<Object?> get props => [id, type, status];
}

class EmergencyContactModel extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String relation;
  final bool isPrimary;

  const EmergencyContactModel({
    required this.id,
    this.name = '',
    this.phoneNumber = '',
    this.relation = '',
    this.isPrimary = false,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phone'] ?? '',
      relation: json['relation'] ?? '',
      isPrimary: json['is_primary'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, phoneNumber];
}

class CallLogModel extends Equatable {
  final String id;
  final String phoneNumber;
  final String callerName;
  final String direction;
  final String status;
  final int duration;
  final double riskScore;
  final bool isFraud;
  final DateTime timestamp;
  final String? transcript;

  const CallLogModel({
    required this.id,
    this.phoneNumber = '',
    this.callerName = '',
    this.direction = 'incoming',
    this.status = 'safe',
    this.duration = 0,
    this.riskScore = 0,
    this.isFraud = false,
    required this.timestamp,
    this.transcript,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      phoneNumber: json['phone_number'] ?? json['phone'] ?? '',
      callerName: json['caller_name'] ?? '',
      direction: json['direction'] ?? 'incoming',
      status: json['status'] ?? 'safe',
      duration: json['duration'] ?? 0,
      riskScore: (json['risk_score'] ?? 0).toDouble(),
      isFraud: json['is_fraud'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      transcript: json['transcript'],
    );
  }

  @override
  List<Object?> get props => [id, phoneNumber, status];
}

class AlertModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final String severity;
  final String type;
  final bool read;
  final DateTime timestamp;

  const AlertModel({
    required this.id,
    this.title = '',
    this.message = '',
    this.severity = 'info',
    this.type = 'general',
    this.read = false,
    required this.timestamp,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'info',
      type: json['type'] ?? 'general',
      read: json['read'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, title, severity, read];
}