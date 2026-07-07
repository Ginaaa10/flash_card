import 'dart:convert';
import 'package:http/http.dart' as http;

class QuestionGeneratorService {
  // Edit this URL if your backend runs elsewhere. For Android emulator use 10.0.2.2
  static const _defaultUrl = String.fromEnvironment('QUESTION_BACKEND_URL', defaultValue: 'http://10.0.2.2:8080/generate');

  static Future<String> generateFromText(String text) async {
    final uri = Uri.parse(_defaultUrl);
    final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'text': text}));
    if (resp.statusCode == 200) {
      return resp.body;
    } else {
      throw Exception('Backend error: ${resp.statusCode} ${resp.body}');
    }
  }
}
