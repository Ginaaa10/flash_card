import 'package:freezed_annotation/freezed_annotation.dart';
import 'stroke_model.dart';

part 'flashcard_face_model.freezed.dart';
part 'flashcard_face_model.g.dart';

/// An extra side of a flashcard, beyond the built-in Front and Back sides.
///
/// Front and Back keep their own dedicated fields on [FlashcardModel] so that
/// flashcards saved before extra sides existed still load without migration.
@freezed
class FlashcardFace with _$FlashcardFace {
  const factory FlashcardFace({
    required String id,
    required String name,
    @Default([]) List<StrokeModel> strokes,
    String? text,
    String? recognizedText,
    String? backgroundImage,
  }) = _FlashcardFace;

  factory FlashcardFace.fromJson(Map<String, dynamic> json) =>
      _$FlashcardFaceFromJson(json);
}
