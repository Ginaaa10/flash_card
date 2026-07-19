import 'dart:developer' as developer;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';

class RecognitionResult {
  final String text;
  final List<RecognitionCandidate> candidates;
  final double confidence;

  RecognitionResult({
    required this.text,
    required this.candidates,
    required this.confidence,
  });
}

class RecognitionCandidate {
  final String text;
  final double score;

  RecognitionCandidate({required this.text, required this.score});
}

class RecognitionService {
  static final RecognitionService _instance = RecognitionService._internal();
  factory RecognitionService() => _instance;
  RecognitionService._internal();

  DigitalInkRecognizer? _recognizer;
  String _selectedLanguage = 'en-US';

  void setLanguage(String language) {
    _selectedLanguage = language;
    _recognizer?.close();
    _recognizer = null;
  }

  String get selectedLanguage => _selectedLanguage;

  DigitalInkRecognizer get _getRecognizer {
    if (_recognizer == null) {
      _recognizer = DigitalInkRecognizer(
        languageCode: _selectedLanguage,
      );
    }
    return _recognizer!;
  }

  Future<RecognitionResult?> recognizeStrokes(
    List<StrokeModel> strokes, {
    int maxCandidates = 3,
  }) async {
    if (strokes.isEmpty) return null;

    try {
      final ink = Ink();
      for (final stroke in strokes) {
        final inkStroke = Stroke();
        for (final point in stroke.points) {
          inkStroke.points.add(
            StrokePoint(
              x: point.x,
              y: point.y,
              t: point.time.toInt(),
            ),
          );
        }
        ink.strokes.add(inkStroke);
      }

      final candidates = await _getRecognizer.recognize(ink);

      if (candidates.isEmpty) return null;

      final recognizedText = candidates.first.text;
      final recognitionCandidates = candidates.take(maxCandidates).map((c) {
        return RecognitionCandidate(
          text: c.text,
          score: c.score,
        );
      }).toList();

      final confidence = candidates.first.score;

      return RecognitionResult(
        text: recognizedText,
        candidates: recognitionCandidates,
        confidence: confidence,
      );
    } catch (e) {
      developer.log('Recognition error: $e', name: 'RecognitionService');
      return null;
    }
  }

  void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }
}
