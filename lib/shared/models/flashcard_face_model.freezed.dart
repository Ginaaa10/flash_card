// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_face_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FlashcardFace _$FlashcardFaceFromJson(Map<String, dynamic> json) {
  return _FlashcardFace.fromJson(json);
}

/// @nodoc
mixin _$FlashcardFace {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<StrokeModel> get strokes => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  String? get recognizedText => throw _privateConstructorUsedError;
  String? get backgroundImage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FlashcardFaceCopyWith<FlashcardFace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardFaceCopyWith<$Res> {
  factory $FlashcardFaceCopyWith(
          FlashcardFace value, $Res Function(FlashcardFace) then) =
      _$FlashcardFaceCopyWithImpl<$Res, FlashcardFace>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<StrokeModel> strokes,
      String? text,
      String? recognizedText,
      String? backgroundImage});
}

/// @nodoc
class _$FlashcardFaceCopyWithImpl<$Res, $Val extends FlashcardFace>
    implements $FlashcardFaceCopyWith<$Res> {
  _$FlashcardFaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? strokes = null,
    Object? text = freezed,
    Object? recognizedText = freezed,
    Object? backgroundImage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      strokes: null == strokes
          ? _value.strokes
          : strokes // ignore: cast_nullable_to_non_nullable
              as List<StrokeModel>,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      recognizedText: freezed == recognizedText
          ? _value.recognizedText
          : recognizedText // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundImage: freezed == backgroundImage
          ? _value.backgroundImage
          : backgroundImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FlashcardFaceImplCopyWith<$Res>
    implements $FlashcardFaceCopyWith<$Res> {
  factory _$$FlashcardFaceImplCopyWith(
          _$FlashcardFaceImpl value, $Res Function(_$FlashcardFaceImpl) then) =
      __$$FlashcardFaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<StrokeModel> strokes,
      String? text,
      String? recognizedText,
      String? backgroundImage});
}

/// @nodoc
class __$$FlashcardFaceImplCopyWithImpl<$Res>
    extends _$FlashcardFaceCopyWithImpl<$Res, _$FlashcardFaceImpl>
    implements _$$FlashcardFaceImplCopyWith<$Res> {
  __$$FlashcardFaceImplCopyWithImpl(
      _$FlashcardFaceImpl _value, $Res Function(_$FlashcardFaceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? strokes = null,
    Object? text = freezed,
    Object? recognizedText = freezed,
    Object? backgroundImage = freezed,
  }) {
    return _then(_$FlashcardFaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      strokes: null == strokes
          ? _value._strokes
          : strokes // ignore: cast_nullable_to_non_nullable
              as List<StrokeModel>,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      recognizedText: freezed == recognizedText
          ? _value.recognizedText
          : recognizedText // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundImage: freezed == backgroundImage
          ? _value.backgroundImage
          : backgroundImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardFaceImpl implements _FlashcardFace {
  const _$FlashcardFaceImpl(
      {required this.id,
      required this.name,
      final List<StrokeModel> strokes = const [],
      this.text,
      this.recognizedText,
      this.backgroundImage})
      : _strokes = strokes;

  factory _$FlashcardFaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardFaceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<StrokeModel> _strokes;
  @override
  @JsonKey()
  List<StrokeModel> get strokes {
    if (_strokes is EqualUnmodifiableListView) return _strokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strokes);
  }

  @override
  final String? text;
  @override
  final String? recognizedText;
  @override
  final String? backgroundImage;

  @override
  String toString() {
    return 'FlashcardFace(id: $id, name: $name, strokes: $strokes, text: $text, recognizedText: $recognizedText, backgroundImage: $backgroundImage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardFaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._strokes, _strokes) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.recognizedText, recognizedText) ||
                other.recognizedText == recognizedText) &&
            (identical(other.backgroundImage, backgroundImage) ||
                other.backgroundImage == backgroundImage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_strokes),
      text,
      recognizedText,
      backgroundImage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardFaceImplCopyWith<_$FlashcardFaceImpl> get copyWith =>
      __$$FlashcardFaceImplCopyWithImpl<_$FlashcardFaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardFaceImplToJson(
      this,
    );
  }
}

abstract class _FlashcardFace implements FlashcardFace {
  const factory _FlashcardFace(
      {required final String id,
      required final String name,
      final List<StrokeModel> strokes,
      final String? text,
      final String? recognizedText,
      final String? backgroundImage}) = _$FlashcardFaceImpl;

  factory _FlashcardFace.fromJson(Map<String, dynamic> json) =
      _$FlashcardFaceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<StrokeModel> get strokes;
  @override
  String? get text;
  @override
  String? get recognizedText;
  @override
  String? get backgroundImage;
  @override
  @JsonKey(ignore: true)
  _$$FlashcardFaceImplCopyWith<_$FlashcardFaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
