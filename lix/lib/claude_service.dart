import 'recommendation_service.dart';

class ClaudeService {
  static Future<String> sendMessage(List<Map<String, String>> messages) async {
    final lastUserMessage = messages
        .where((m) => m['role'] == 'user')
        .lastOrNull?['text'] ?? 'Happy';

    return await RecommendationService.getRecommendation(lastUserMessage);
  }
}
