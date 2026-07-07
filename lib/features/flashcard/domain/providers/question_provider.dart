import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flash_card_app/shared/models/question_model.dart';
import 'package:flash_card_app/shared/services/firestore_service.dart';
import 'package:flash_card_app/features/recognition/domain/services/question_generator_service.dart';

class QuestionNotifier extends StateNotifier<List<QuestionModel>> {
  final QuestionGeneratorService _generatorService = QuestionGeneratorService();
  
  QuestionNotifier() : super([]) {
    loadQuestions();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadQuestions() async {
    _isLoading = true;
    try {
      // TODO: Implement Firebase Firestore method to get all questions
      // state = await FirestoreService.getAllQuestions();
    } catch (e) {
      print('Error loading questions: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<List<QuestionModel>> generateQuestions({
    required String text,
    required String flashcardId,
    required String questionType,
    int numberOfQuestions = 3,
  }) async {
    try {
      final questions = await _generatorService.generateQuestionsFromText(
        text: text,
        flashcardId: flashcardId,
        questionType: questionType,
        numberOfQuestions: numberOfQuestions,
      );
      
      // Thêm vào state
      state = [...state, ...questions];
      
      // TODO: Lưu vào Firestore
      // for (var question in questions) {
      //   await FirestoreService.saveQuestion(question);
      // }
      
      return questions;
    } catch (e) {
      print('Error generating questions: $e');
      rethrow;
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      state = state.where((q) => q.id != questionId).toList();
      // TODO: Xóa từ Firestore
      // await FirestoreService.deleteQuestion(questionId);
    } catch (e) {
      print('Error deleting question: $e');
      rethrow;
    }
  }

  Future<void> updateQuestion(QuestionModel question) async {
    try {
      state = [
        for (final q in state)
          if (q.id == question.id) question else q,
      ];
      // TODO: Cập nhật trên Firestore
      // await FirestoreService.saveQuestion(question);
    } catch (e) {
      print('Error updating question: $e');
      rethrow;
    }
  }

  List<QuestionModel> getQuestionsByFlashcard(String flashcardId) {
    return state.where((q) => q.flashcardId == flashcardId).toList();
  }
}

final questionProvider = StateNotifierProvider<QuestionNotifier, List<QuestionModel>>(
  (ref) {
    return QuestionNotifier();
  },
);

final questionsByFlashcardProvider = Provider.family<List<QuestionModel>, String>(
  (ref, flashcardId) {
    final questions = ref.watch(questionProvider);
    return questions.where((q) => q.flashcardId == flashcardId).toList();
  },
);
