import 'package:freezed_annotation/freezed_annotation.dart';
import 'stroke_model.dart';

part 'flashcard_model.freezed.dart';
part 'flashcard_model.g.dart';

@freezed
class FlashcardModel with _$FlashcardModel {
  const factory FlashcardModel({
    required String id,
    required String title,
    required List<StrokeModel> frontStrokes,
    required List<StrokeModel> backStrokes,
    String? frontRecognizedText,
    String? backRecognizedText,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<String> tags,
    @Default(0) int reviewCount,
    DateTime? lastReviewedAt,
  }) = _FlashcardModel;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) => _$FlashcardModelFromJson(json);
}