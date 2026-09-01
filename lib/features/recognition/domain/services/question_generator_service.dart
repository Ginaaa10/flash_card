import 'package:uuid/uuid.dart';
import 'package:flash_card_app/shared/models/question_model.dart';

class QuestionGeneratorService {
  // Simulated AI question generation
  // In production, this would call an AI API like Claude, ChatGPT, etc.
  
  Future<List<QuestionModel>> generateQuestionsFromText({
    required String text,
    required String flashcardId,
    required String questionType,
    int numberOfQuestions = 3,
  }) async {
    if (text.isEmpty) {
      throw Exception('Text cannot be empty');
    }

    final questions = <QuestionModel>[];
    final sentences = _splitIntoSentences(text);

    if (questionType == 'essay') {
      questions.addAll(
        _generateEssayQuestions(sentences, flashcardId, numberOfQuestions),
      );
    } else if (questionType == 'multiple_choice') {
      questions.addAll(
        _generateMultipleChoiceQuestions(sentences, flashcardId, numberOfQuestions),
      );
    }

    return questions;
  }

  List<QuestionModel> _generateEssayQuestions(
    List<String> sentences,
    String flashcardId,
    int numberOfQuestions,
  ) {
    final questions = <QuestionModel>[];
    
    for (int i = 0; i < numberOfQuestions && i < sentences.length; i++) {
      final sentence = sentences[i].trim();
      if (sentence.length > 10) {
        questions.add(
          QuestionModel(
            id: const Uuid().v4(),
            flashcardId: flashcardId,
            questionText: _generateEssayQuestion(sentence),
            type: 'essay',
            explanation: sentence,
            createdAt: DateTime.now(),
          ),
        );
      }
    }
    
    return questions;
  }

  List<QuestionModel> _generateMultipleChoiceQuestions(
    List<String> sentences,
    String flashcardId,
    int numberOfQuestions,
  ) {
    final questions = <QuestionModel>[];
    
    for (int i = 0; i < numberOfQuestions && i < sentences.length; i++) {
      final sentence = sentences[i].trim();
      if (sentence.length > 10) {
        final keyWords = _extractKeyWords(sentence);
        if (keyWords.isNotEmpty) {
          questions.add(
            QuestionModel(
              id: const Uuid().v4(),
              flashcardId: flashcardId,
              questionText: _generateMultipleChoiceQuestion(sentence, keyWords.first),
              type: 'multiple_choice',
              options: _generateOptions(sentence, keyWords),
              correctAnswer: keyWords.first,
              explanation: sentence,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    }
    
    return questions;
  }

  String _generateEssayQuestion(String sentence) {
    final verbs = ['Explain', 'Describe', 'Analyze', 'Discuss', 'What do you understand about'];
    final verb = verbs[sentence.hashCode % verbs.length];
    return '$verb: $sentence';
  }

  String _generateMultipleChoiceQuestion(String sentence, String keyword) {
    return 'Which of the following best describes "$keyword" in the context of: $sentence?';
  }

  List<String> _extractKeyWords(String sentence) {
    final words = sentence.split(RegExp(r'\s+'));
    // Lọc các từ có độ dài > 3 và không phải từ dừng
    return words
        .where((w) => w.length > 3)
        .where((w) => !_isStopWord(w))
        .take(5)
        .toList();
  }

  List<String> _generateOptions(String sentence, List<String> keyWords) {
    final options = <String>{};
    
    if (keyWords.isNotEmpty) {
      options.add(keyWords.first); // Đáp án đúng
    }
    
    // Thêm các điểm lạc đường
    final distractors = [
      'A generic term that does not apply',
      'The opposite concept',
      'A related but different concept',
    ];
    
    for (var i = 0; i < 3 && options.length < 4; i++) {
      options.add(distractors[i % distractors.length]);
    }
    
    return options.toList()..shuffle();
  }

  List<String> _splitIntoSentences(String text) {
    return text
        .split(RegExp(r'[.!?]+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  bool _isStopWord(String word) {
    const stopWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has',
      'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should', 'may',
      'might', 'must', 'can', 'this', 'that', 'these', 'those', 'i', 'you',
      'he', 'she', 'it', 'we', 'they', 'what', 'which', 'who', 'when', 'where',
      'why', 'how'
    };
    return stopWords.contains(word.toLowerCase());
  }
}
