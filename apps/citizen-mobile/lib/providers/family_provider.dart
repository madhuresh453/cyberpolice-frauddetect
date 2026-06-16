import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamilyMember {
  final String id;
  final String name;
  final String phone;
  final bool isProtected;
  final int riskScore;
  final String role; // guardian, child, senior

  FamilyMember({
    required this.id,
    required this.name,
    required this.phone,
    this.isProtected = true,
    this.riskScore = 0,
    this.role = 'member',
  });

  FamilyMember copyWith({bool? isProtected, int? riskScore}) {
    return FamilyMember(
      id: id,
      name: name,
      phone: phone,
      isProtected: isProtected ?? this.isProtected,
      riskScore: riskScore ?? this.riskScore,
      role: role,
    );
  }
}

class FamilyState {
  final List<FamilyMember> members;

  FamilyState({this.members = const []});
}

class FamilyNotifier extends StateNotifier<FamilyState> {
  FamilyNotifier() : super(FamilyState());

  void addMember(FamilyMember member) {
    state = FamilyState(members: [...state.members, member]);
  }

  void removeMember(String id) {
    state = FamilyState(members: state.members.where((m) => m.id != id).toList());
  }

  void updateProtection(String id, bool protected) {
    state = FamilyState(
      members: state.members.map((m) => m.id == id ? m.copyWith(isProtected: protected) : m).toList(),
    );
  }

  void updateRiskScore(String id, int score) {
    state = FamilyState(
      members: state.members.map((m) => m.id == id ? m.copyWith(riskScore: score) : m).toList(),
    );
  }
}

final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  return FamilyNotifier();
});