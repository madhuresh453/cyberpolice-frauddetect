import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

final aiCopilotProvider = StateNotifierProvider<AiCopilotNotifier, AiCopilotState>((ref) => AiCopilotNotifier(ref));

class AiCopilotState {
  final bool loading;
  final List<Map<String, dynamic>> messages;
  final String? error;
  const AiCopilotState({this.loading = false, this.messages = const [], this.error});
  AiCopilotState copyWith({bool? loading, List<Map<String, dynamic>>? messages, String? error}) =>
    AiCopilotState(loading: loading ?? this.loading, messages: messages ?? this.messages, error: error);
}

class AiCopilotNotifier extends StateNotifier<AiCopilotState> {
  final ApiClient _api = ApiClient();
  AiCopilotNotifier(_) : super(const AiCopilotState());

  Future<void> sendMessage(String message) async {
    state = state.copyWith(loading: true);
    try {
      final response = await _api.post('/ai-copilot/chat', data: {'message': message});
      final data = response.data;
      final reply = data['reply'] as String? ?? '';
      final updated = List<Map<String, dynamic>>.from(state.messages)
        ..add({'from': 'user', 'text': message, 'time': DateTime.now().toIso8601String()})
        ..add({'from': 'ai', 'text': reply, 'time': DateTime.now().toIso8601String()});
      state = state.copyWith(messages: updated, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> getAnalysis() async {
    state = state.copyWith(loading: true);
    try {
      final response = await _api.get('/ai-copilot/analysis');
      final data = response.data;
      state = state.copyWith(loading: false, messages: [...state.messages, {'from': 'ai', 'text': data['analysis'] ?? 'No analysis available', 'time': DateTime.now().toIso8601String()}]);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}