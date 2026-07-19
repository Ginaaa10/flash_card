// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stroke_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StrokeModelImpl _$$StrokeModelImplFromJson(Map<String, dynamic> json) =>
    _$StrokeModelImpl(
      id: json['id'] as String,
      points: (json['points'] as List<dynamic>)
          .map((e) => PointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      color: StrokeModel._colorFromJson((json['color'] as num).toInt()),
      width: (json['width'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$StrokeModelImplToJson(_$StrokeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'points': instance.points,
      'color': StrokeModel._colorToJson(instance.color),
      'width': instance.width,
      'timestamp': instance.timestamp.toIso8601String(),
    };
