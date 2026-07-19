import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AiService {
  static const String _apiKeyPref = 'ai_api_key';
  static const String _providerPref = 'ai_provider';
  static const String _connectedPref = 'ai_connected';

  static Future<bool> get isConnected async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_connectedPref) ?? false;
  }

  static Future<void> saveApiKey(String provider, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
    await prefs.setString(_providerPref, provider);
    await prefs.setBool(_connectedPref, true);
  }

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref);
  }

  static Future<String?> getProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_providerPref);
  }

  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
    await prefs.remove(_providerPref);
    await prefs.setBool(_connectedPref, false);
  }

  static Future<List<String>?> generateWrongAnswers({
    required String question,
    required String correctAnswer,
    int count = 3,
  }) async {
    final apiKey = await getApiKey();
    final provider = await getProvider();

    if (apiKey == null || apiKey.isEmpty || provider == null) {
      return null;
    }

    try {
      switch (provider) {
        case 'gemini':
          return await _generateWithGemini(apiKey, question, correctAnswer, count);
        case 'openai':
          return await _generateWithOpenAI(apiKey, question, correctAnswer, count);
        default:
          return null;
      }
    } catch (e) {
      print('AI generation error: $e');
      return null;
    }
  }

  static Future<List<String>> _generateWithGemini(
    String apiKey,
    String question,
    String correctAnswer,
    int count,
  ) async {
    final prompt = '''Bạn là một trợ lý tạo câu hỏi trắc nghiệm. Dựa vào câu hỏi và đáp án đúng dưới đây, hãy tạo $count đáp án sai nhưng hợp lý, có thể gây nhầm lẫn với đáp án đúng. Các đáp án sai phải liên quan đến cùng chủ đề và có định dạng/phong cách tương tự đáp án đúng.

Câu hỏi: $question
Đáp án đúng: $correctAnswer

Chỉ trả về một mảng JSON chứa các đáp án sai, không giải thích. Ví dụ: ["dap an sai 1", "dap an sai 2", "dap an sai 3"]''';

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 200,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      return _parseJsonArray(text);
    }
    throw Exception('Gemini API error: ${response.statusCode}');
  }

  static Future<List<String>> _generateWithOpenAI(
    String apiKey,
    String question,
    String correctAnswer,
    int count,
  ) async {
    final prompt = '''Bạn là một trợ lý tạo câu hỏi trắc nghiệm. Dựa vào câu hỏi và đáp án đúng dưới đây, hãy tạo $count đáp án sai nhưng hợp lý, có thể gây nhầm lẫn với đáp án đúng. Các đáp án sai phải liên quan đến cùng chủ đề và có định dạng/phong cách tương tự đáp án đúng.

Câu hỏi: $question
Đáp án đúng: $correctAnswer

Chỉ trả về một mảng JSON chứa các đáp án sai, không giải thích. Ví dụ: ["dap an sai 1", "dap an sai 2", "dap an sai 3"]''';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.8,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices'][0]['message']['content'] as String;
      return _parseJsonArray(text);
    }
    throw Exception('OpenAI API error: ${response.statusCode}');
  }

  static List<String> _parseJsonArray(String text) {
    try {
      final cleaned = text.trim();
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');
      if (start == -1 || end == -1) return [];

      final jsonStr = cleaned.substring(start, end + 1);
      final List<dynamic> parsed = jsonDecode(jsonStr);
      return parsed.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }
}
