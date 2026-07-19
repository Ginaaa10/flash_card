// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stroke_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StrokeModel _$StrokeModelFromJson(Map<String, dynamic> json) {
  return _StrokeModel.fromJson(json);
}

/// @nodoc
mixin _$StrokeModel {
  String get id => throw _privateConstructorUsedError;
  List<PointModel> get points => throw _privateConstructorUsedError;
  @JsonKey(
      fromJson: StrokeModel._colorFromJson, toJson: StrokeModel._colorToJson)
  Color get color => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StrokeModelCopyWith<StrokeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrokeModelCopyWith<$Res> {
  factory $StrokeModelCopyWith(
          StrokeModel value, $Res Function(StrokeModel) then) =
      _$StrokeModelCopyWithImpl<$Res, StrokeModel>;
  @useResult
  $Res call(
      {String id,
      List<PointModel> points,
      @JsonKey(
          fromJson: StrokeModel._colorFromJson,
          toJson: StrokeModel._colorToJson)
      Color color,
      double width,
      DateTime timestamp});
}

/// @nodoc
class _$StrokeModelCopyWithImpl<$Res, $Val extends StrokeModel>
    implements $StrokeModelCopyWith<$Res> {
  _$StrokeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? points = null,
    Object? color = null,
    Object? width = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as List<PointModel>,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StrokeModelImplCopyWith<$Res>
    implements $StrokeModelCopyWith<$Res> {
  factory _$$StrokeModelImplCopyWith(
          _$StrokeModelImpl value, $Res Function(_$StrokeModelImpl) then) =
      __$$StrokeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<PointModel> points,
      @JsonKey(
          fromJson: StrokeModel._colorFromJson,
          toJson: StrokeModel._colorToJson)
      Color color,
      double width,
      DateTime timestamp});
}

/// @nodoc
class __$$StrokeModelImplCopyWithImpl<$Res>
    extends _$StrokeModelCopyWithImpl<$Res, _$StrokeModelImpl>
    implements _$$StrokeModelImplCopyWith<$Res> {
  __$$StrokeModelImplCopyWithImpl(
      _$StrokeModelImpl _value, $Res Function(_$StrokeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? points = null,
    Object? color = null,
    Object? width = null,
    Object? timestamp = null,
  }) {
    return _then(_$StrokeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value._points
          : points // ignore: cast_nullable_to_non_nullable
              as List<PointModel>,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StrokeModelImpl implements _StrokeModel {
  const _$StrokeModelImpl(
      {required this.id,
      required final List<PointModel> points,
      @JsonKey(
          fromJson: StrokeModel._colorFromJson,
          toJson: StrokeModel._colorToJson)
      required this.color,
      required this.width,
      required this.timestamp})
      : _points = points;

  factory _$StrokeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrokeModelImplFromJson(json);

  @override
  final String id;
  final List<PointModel> _points;
  @override
  List<PointModel> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  @JsonKey(
      fromJson: StrokeModel._colorFromJson, toJson: StrokeModel._colorToJson)
  final Color color;
  @override
  final double width;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'StrokeModel(id: $id, points: $points, color: $color, width: $width, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrokeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._points, _points) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id,
      const DeepCollectionEquality().hash(_points), color, width, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StrokeModelImplCopyWith<_$StrokeModelImpl> get copyWith =>
      __$$StrokeModelImplCopyWithImpl<_$StrokeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrokeModelImplToJson(
      this,
    );
  }
}

abstract class _StrokeModel implements StrokeModel {
  const factory _StrokeModel(
      {required final String id,
      required final List<PointModel> points,
      @JsonKey(
          fromJson: StrokeModel._colorFromJson,
          toJson: StrokeModel._colorToJson)
      required final Color color,
      required final double width,
      required final DateTime timestamp}) = _$StrokeModelImpl;

  factory _StrokeModel.fromJson(Map<String, dynamic> json) =
      _$StrokeModelImpl.fromJson;

  @override
  String get id;
  @override
  List<PointModel> get points;
  @override
  @JsonKey(
      fromJson: StrokeModel._colorFromJson, toJson: StrokeModel._colorToJson)
  Color get color;
  @override
  double get width;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$StrokeModelImplCopyWith<_$StrokeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
