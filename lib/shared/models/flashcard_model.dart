import 'package:freezed_annotation/freezed_annotation.dart';
import 'flashcard_face_model.dart';
import 'stroke_model.dart';

part 'flashcard_model.freezed.dart';
part 'flashcard_model.g.dart';

@freezed
class FlashcardModel with _$FlashcardModel {
  const FlashcardModel._();

  const factory FlashcardModel({
    required String id,
    required String title,
    required List<StrokeModel> frontStrokes,
    required List<StrokeModel> backStrokes,
    @Default('Front') String frontName,
    @Default('Back') String backName,
    String? frontText,
    String? backText,
    String? frontRecognizedText,
    String? backRecognizedText,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<String> tags,
    @Default(0) int reviewCount,
    DateTime? lastReviewedAt,
    @Default(false) bool isFavorite,
    String? groupName,
    String? frontBackgroundImage,
    String? backBackgroundImage,
    @Default([]) List<FlashcardFace> extraFaces,
    @Default('solid') String borderStyle,
    @Default(0xFF6366F1) int borderColor,
    @Default(2.0) double borderWidth,
    @Default(16.0) double borderRadius,
  }) = _FlashcardModel;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) => _$FlashcardModelFromJson(json);

  /// Total number of sides, including the built-in Front and Back.
  int get faceCount => 2 + extraFaces.length;
}
