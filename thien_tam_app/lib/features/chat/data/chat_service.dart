import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config.dart';
import 'models/chat_message.dart';

class ChatService {
  final String baseUrl = AppConfig.apiBaseUrl;

  /// Send a chat message to the Zen Master
  Future<String> sendMessage({
    required String prompt,
    List<ChatMessage>? history,
    double temperature = 0.7,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat/ask');

      final body = {
        'prompt': prompt,
        'temperature': temperature,
        if (history != null && history.isNotEmpty)
          'history': history.map((m) => m.toJson()).toList(),
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['text'] as String? ??
            'Xin lỗi, con. Thầy không thể trả lời lúc này.';
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['error'] ?? 'Không thể kết nối với Thiền Sư');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  /// Check if the chat service is available
  Future<bool> checkStatus() async {
    try {
      final url = Uri.parse('$baseUrl/chat/status');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['configured'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
