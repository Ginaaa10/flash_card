import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'point_model.dart';

part 'stroke_model.freezed.dart';
part 'stroke_model.g.dart';

@freezed
class StrokeModel with _$StrokeModel {
  const factory StrokeModel({
    required String id,
    required List<PointModel> points,
    @JsonKey(fromJson: StrokeModel._colorFromJson, toJson: StrokeModel._colorToJson)
    required Color color,
    required double width,
    required DateTime timestamp,
  }) = _StrokeModel;

  factory StrokeModel.fromJson(Map<String, dynamic> json) => _$StrokeModelFromJson(json);

  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color color) => color.value;
}