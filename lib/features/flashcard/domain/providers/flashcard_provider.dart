import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';
import 'package:flash_card_app/shared/services/firestore_service.dart';

class FlashcardNotifier extends StateNotifier<List<FlashcardModel>> {
  bool _isLoading = false;
  
  FlashcardNotifier() : super([]) {
    loadFlashcards();
  }

  bool get isLoading => _isLoading;

  Future<void> loadFlashcards() async {
    if (state.isNotEmpty) return;
    _isLoading = true;
    try {
      state = await FirestoreService.getAllFlashcards();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshFlashcards() async {
    _isLoading = true;
    try {
      state = await FirestoreService.getAllFlashcards();
    } finally {
      _isLoading = false;
    }
  }

  FlashcardModel? getFlashcard(String id) {
    try {
      return state.firstWhere((fc) => fc.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<FlashcardModel> createFlashcard({
    required String title,
    List<StrokeModel>? frontStrokes,
    List<StrokeModel>? backStrokes,
  }) async {
    final now = DateTime.now();
    final flashcard = FlashcardModel(
      id: const Uuid().v4(),
      title: title,
      frontStrokes: frontStrokes ?? [],
      backStrokes: backStrokes ?? [],
      createdAt: now,
      updatedAt: now,
      tags: [],
      reviewCount: 0,
    );
    await FirestoreService.saveFlashcard(flashcard);
    state = [flashcard, ...state];
    return flashcard;
  }

  Future<void> updateFlashcard(FlashcardModel flashcard) async {
    final updated = flashcard.copyWith(updatedAt: DateTime.now());
    await FirestoreService.saveFlashcard(updated);
    state = [
      for (final fc in state)
        if (fc.id == updated.id) updated else fc,
    ];
  }

  Future<void> updateFrontStrokes(String id, List<StrokeModel> strokes) async {
    final flashcard = getFlashcard(id);
    if (flashcard != null) {
      await updateFlashcard(flashcard.copyWith(frontStrokes: strokes));
    }
  }

  Future<void> updateBackStrokes(String id, List<StrokeModel> strokes) async {
    final flashcard = getFlashcard(id);
    if (flashcard != null) {
      await updateFlashcard(flashcard.copyWith(backStrokes: strokes));
    }
  }

  Future<void> updateRecognizedText(String id, {
    String? frontText,
    String? backText,
  }) async {
    final flashcard = getFlashcard(id);
    if (flashcard != null) {
      await updateFlashcard(flashcard.copyWith(
        frontRecognizedText: frontText ?? flashcard.frontRecognizedText,
        backRecognizedText: backText ?? flashcard.backRecognizedText,
      ));
    }
  }

  Future<void> deleteFlashcard(String id) async {
    await FirestoreService.deleteFlashcard(id);
    state = state.where((fc) => fc.id != id).toList();
  }

  Future<void> deleteAllFlashcards() async {
    await FirestoreService.deleteAllFlashcards();
    state = [];
  }

  void searchFlashcards(String query) {
    if (query.isEmpty) {
      loadFlashcards();
      return;
    }
    final lowerQuery = query.toLowerCase();
    state = state.where((fc) {
      return fc.title.toLowerCase().contains(lowerQuery) ||
          (fc.frontRecognizedText?.toLowerCase().contains(lowerQuery) ??
              false) ||
          (fc.backRecognizedText?.toLowerCase().contains(lowerQuery) ??
              false) ||
          fc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<void> incrementReviewCount(String id) async {
    final flashcard = getFlashcard(id);
    if (flashcard != null) {
      await updateFlashcard(flashcard.copyWith(
        reviewCount: flashcard.reviewCount + 1,
        lastReviewedAt: DateTime.now(),
      ));
    }
  }
}

final flashcardProvider =
    StateNotifierProvider<FlashcardNotifier, List<FlashcardModel>>((ref) {
  return FlashcardNotifier();
});

final flashcardByIdProvider =
    Provider.family<FlashcardModel?, String>((ref, id) {
  final flashcards = ref.watch(flashcardProvider);
  try {
    return flashcards.firstWhere((fc) => fc.id == id);
  } catch (_) {
    return null;
  }
});

final flashcardSearchProvider = StateProvider<String>((ref) => '');

final filteredFlashcardProvider = Provider<List<FlashcardModel>>((ref) {
  final flashcards = ref.watch(flashcardProvider);
  final searchQuery = ref.watch(flashcardSearchProvider);

  if (searchQuery.isEmpty) return flashcards;

  final lowerQuery = searchQuery.toLowerCase();
  return flashcards.where((fc) {
    return fc.title.toLowerCase().contains(lowerQuery) ||
        (fc.frontRecognizedText?.toLowerCase().contains(lowerQuery) ?? false) ||
        (fc.backRecognizedText?.toLowerCase().contains(lowerQuery) ?? false) ||
        fc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }).toList();
});
