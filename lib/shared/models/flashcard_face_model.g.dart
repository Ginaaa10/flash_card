// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_face_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashcardFaceImpl _$$FlashcardFaceImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardFaceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      strokes: (json['strokes'] as List<dynamic>?)
              ?.map((e) => StrokeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      text: json['text'] as String?,
      recognizedText: json['recognizedText'] as String?,
      backgroundImage: json['backgroundImage'] as String?,
    );

Map<String, dynamic> _$$FlashcardFaceImplToJson(_$FlashcardFaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'strokes': instance.strokes.map((e) => e.toJson()).toList(),
      'text': instance.text,
      'recognizedText': instance.recognizedText,
      'backgroundImage': instance.backgroundImage,
    };
