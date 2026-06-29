import 'package:freezed_annotation/freezed_annotation.dart';

part 'point_model.freezed.dart';
part 'point_model.g.dart';

@freezed
class PointModel with _$PointModel {
  const factory PointModel({
    required double x,
    required double y,
    required double time,
    @Default(0.0) double pressure,
  }) = _PointModel;

  factory PointModel.fromJson(Map<String, dynamic> json) => _$PointModelFromJson(json);
}