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
      frontText: json['frontText'] as String?,
      backText: json['backText'] as String?,
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
      frontBackgroundImage: json['frontBackgroundImage'] as String?,
      backBackgroundImage: json['backBackgroundImage'] as String?,
      borderStyle: json['borderStyle'] as String? ?? 'solid',
      borderColor: (json['borderColor'] as num?)?.toInt() ?? 0xFF6366F1,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 2.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 16.0,
    );

Map<String, dynamic> _$$FlashcardModelImplToJson(
        _$FlashcardModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'frontStrokes': instance.frontStrokes,
      'backStrokes': instance.backStrokes,
      'frontText': instance.frontText,
      'backText': instance.backText,
      'frontRecognizedText': instance.frontRecognizedText,
      'backRecognizedText': instance.backRecognizedText,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'reviewCount': instance.reviewCount,
      'lastReviewedAt': instance.lastReviewedAt?.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'groupName': instance.groupName,
      'frontBackgroundImage': instance.frontBackgroundImage,
      'backBackgroundImage': instance.backBackgroundImage,
      'borderStyle': instance.borderStyle,
      'borderColor': instance.borderColor,
      'borderWidth': instance.borderWidth,
      'borderRadius': instance.borderRadius,
    };
