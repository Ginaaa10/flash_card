// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashcardModelImpl _$$FlashcardModelImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      frontStrokes: (json['frontStrokes'] as List<dynamic>)
          .map((e) => StrokeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      backStrokes: (json['backStrokes'] as List<dynamic>)
          .map((e) => StrokeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      frontRecognizedText: json['frontRecognizedText'] as String?,
      backRecognizedText: json['backRecognizedText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      lastReviewedAt: json['lastReviewedAt'] == null
          ? null
          : DateTime.parse(json['lastReviewedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      groupName: json['groupName'] as String?,
    );

Map<String, dynamic> _$$FlashcardModelImplToJson(
        _$FlashcardModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'frontStrokes': instance.frontStrokes.map((e) => e.toJson()).toList(),
      'backStrokes': instance.backStrokes.map((e) => e.toJson()).toList(),
      'frontRecognizedText': instance.frontRecognizedText,
      'backRecognizedText': instance.backRecognizedText,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'reviewCount': instance.reviewCount,
      'lastReviewedAt': instance.lastReviewedAt?.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'groupName': instance.groupName,
    };
