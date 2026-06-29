// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointModelImpl _$$PointModelImplFromJson(Map<String, dynamic> json) =>
    _$PointModelImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      time: (json['time'] as num).toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$PointModelImplToJson(_$PointModelImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'time': instance.time,
      'pressure': instance.pressure,
    };
