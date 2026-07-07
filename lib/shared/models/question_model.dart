import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    required String flashcardId,
    required String questionText,
    required String type, // 'multiple_choice' hoặc 'essay'
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    required DateTime createdAt,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}
