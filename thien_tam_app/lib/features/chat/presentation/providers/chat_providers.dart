import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/chat_service.dart';
import '../../data/models/chat_message.dart';

// Chat service provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// Chat history state provider
class ChatHistoryNotifier extends StateNotifier<List<ChatMessage>> {
  ChatHistoryNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearHistory() {
    state = [];
  }

  void removeLastMessage() {
    if (state.isNotEmpty) {
      state = state.sublist(0, state.length - 1);
    }
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryNotifier, List<ChatMessage>>((ref) {
      return ChatHistoryNotifier();
    });

// Loading state provider
final chatLoadingProvider = StateProvider<bool>((ref) => false);

// Error state provider
final chatErrorProvider = StateProvider<String?>((ref) => null);
