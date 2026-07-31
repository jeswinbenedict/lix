import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _groqApiKey =
      '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';

  static const String _groqModel = 'llama-3.3-70b-versatile';
  static const String _groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const bool _showDebugErrors = false;

  static Future<String> generateReply({
    required String userMessage,
    required String language,
    required String mood,
    required String intent,
    required List<Map<String, String>> conversationHistory,
  }) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) return _fallbackReply(language);

    if (_groqApiKey.isEmpty ||
        _groqApiKey == 'YOUR_GROQ_API_KEY_HERE' ||
        !_groqApiKey.startsWith('gsk_')) {
      const msg = 'Groq API key is missing or invalid.';
      debugPrint(msg);
      return _showDebugErrors ? msg : _fallbackReply(language);
    }

    try {
      final reply = await _callGroq(
        userMessage: trimmed,
        language: language,
        mood: mood,
        history: conversationHistory,
      );
      return reply ?? _fallbackReply(language);
    } on TimeoutException {
      const msg = 'Request timed out. Check your internet connection.';
      debugPrint(msg);
      return _showDebugErrors ? msg : _fallbackReply(language);
    } catch (e) {
      final msg = 'Error: $e';
      debugPrint(msg);
      return _showDebugErrors ? msg : _fallbackReply(language);
    }
  }

  static Future<String?> _callGroq({
    required String userMessage,
    required String language,
    required String mood,
    required List<Map<String, String>> history,
  }) async {
    final messages = _buildMessages(
      systemPrompt: _buildSystemPrompt(language, mood),
      history: history,
      userMessage: userMessage,
    );

    final response = await http
        .post(
          Uri.parse(_groqEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_groqApiKey',
          },
          body: jsonEncode({
            'model': _groqModel,
            'messages': messages,
            'temperature': 0.85,
            'max_tokens': 400,
            'top_p': 0.9,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = data['choices']?[0]?['message']?['content']
          ?.toString()
          .trim();
      if (text != null && text.isNotEmpty) return text;
      return null;
    }

    throw Exception('HTTP ${response.statusCode}');
  }

  static List<Map<String, String>> _buildMessages({
    required String systemPrompt,
    required List<Map<String, String>> history,
    required String userMessage,
  }) {
    final msgs = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    for (final msg in history) {
      msgs.add({
        'role': msg['role'] == 'user' ? 'user' : 'assistant',
        'content': msg['text'] ?? '',
      });
    }

    msgs.add({'role': 'user', 'content': userMessage});
    return msgs;
  }

  static String _buildSystemPrompt(String language, String mood) {
    return '''
You are Lix, a warm, friendly, and emotionally intelligent chat assistant inside a movie and music app called Lix.
Always reply entirely in $language.
Current user mood: $mood
''';
  }

  static String _fallbackReply(String language) {
    const fallbacks = <String, String>{
      'Hindi': 'अरे, कुछ गड़बड़ हो गई! एक बार फिर कोशिश करें।',
      'Tamil': 'அடடா, பிழை ஏற்பட்டது! மீண்டும் முயற்சிக்கவும்.',
      'Telugu': 'అయ్యో, సమస్య వచ్చింది! మళ్లీ ప్రయత్నించండి.',
      'Kannada': 'ಅಯ್ಯೋ, ಸಮಸ್ಯೆ ಉಂಟಾಗಿದೆ! ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Malayalam': 'അയ്യോ, പ്രശ്നം ഉണ്ടായി! വീണ്ടും ശ്രമിക്കൂ.',
      'Bengali': 'উফ, সমস্যা হয়েছে! আবার চেষ্টা করুন।',
      'Arabic': 'حدثت مشكلة! حاول مرة أخرى.',
      'Korean': '문제가 생겼어요! 다시 시도해 주세요.',
      'Japanese': '問題が発生しました。もう一度お試しください。',
      'Spanish': 'Hubo un problema. Inténtalo de nuevo.',
      'French': 'Petit souci. Réessaie.',
      'German': 'Ein Problem ist aufgetreten. Versuch es erneut.',
    };
    return fallbacks[language] ?? 'A small problem happened. Please try again.';
  }
}
