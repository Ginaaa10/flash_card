// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FlashcardModel _$FlashcardModelFromJson(Map<String, dynamic> json) {
  return _FlashcardModel.fromJson(json);
}

/// @nodoc
mixin _$FlashcardModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<StrokeModel> get frontStrokes => throw _privateConstructorUsedError;
  List<StrokeModel> get backStrokes => throw _privateConstructorUsedError;
  String? get frontRecognizedText => throw _privateConstructorUsedError;
  String? get backRecognizedText => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  DateTime? get lastReviewedAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  String? get groupName => throw _privateConstructorUsedError;
  String? get frontBackgroundImage => throw _privateConstructorUsedError;
  String? get backBackgroundImage => throw _privateConstructorUsedError;
  String get borderStyle => throw _privateConstructorUsedError;
  int get borderColor => throw _privateConstructorUsedError;
  double get borderWidth => throw _privateConstructorUsedError;
  double get borderRadius => throw _privateConstructorUsedError;

  /// Serializes this FlashcardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardModelCopyWith<FlashcardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardModelCopyWith<$Res> {
  factory $FlashcardModelCopyWith(
          FlashcardModel value, $Res Function(FlashcardModel) then) =
      _$FlashcardModelCopyWithImpl<$Res, FlashcardModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      List<StrokeModel> frontStrokes,
      List<StrokeModel> backStrokes,
      String? frontRecognizedText,
      String? backRecognizedText,
      DateTime createdAt,
      DateTime updatedAt,
      List<String> tags,
      int reviewCount,
      DateTime? lastReviewedAt,
      bool isFavorite,
      String? groupName,
      String? frontBackgroundImage,
      String? backBackgroundImage,
      String borderStyle,
      int borderColor,
      double borderWidth,
      double borderRadius});
}

/// @nodoc
class _$FlashcardModelCopyWithImpl<$Res, $Val extends FlashcardModel>
    implements $FlashcardModelCopyWith<$Res> {
  _$FlashcardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? frontStrokes = null,
    Object? backStrokes = null,
    Object? frontRecognizedText = freezed,
    Object? backRecognizedText = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? tags = null,
    Object? reviewCount = null,
    Object? lastReviewedAt = freezed,
    Object? isFavorite = null,
    Object? groupName = freezed,
    Object? frontBackgroundImage = freezed,
    Object? backBackgroundImage = freezed,
    Object? borderStyle = null,
    Object? borderColor = null,
    Object? borderWidth = null,
    Object? borderRadius = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      frontStrokes: null == frontStrokes
          ? _value.frontStrokes
          : frontStrokes // ignore: cast_nullable_to_non_nullable
              as List<StrokeModel>,
      backStrokes: null == backStrokes
          ? _value.backStrokes
          : backStrokes // ignore: cast_nullable_to_non_nullable
              as List<StrokeModel>,
      frontRecognizedText: freezed == frontRecognizedText
          ? _value.frontRecognizedText
          : frontRecognizedText // ignore: cast_nullable_to_non_nullable
              as String?,
      backRecognizedText: freezed == backRecognizedText
          ? _value.backRecognizedText
          : backRecognizedText // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      groupName: freezed == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String?,
      frontBackgroundImage: freezed == frontBackgroundImage
          ? _value.frontBackgroundImage
          : frontBackgroundImage // ignore: cast_nullable_to_non_nullable
              as String?,
      backBackgroundImage: freezed == backBackgroundImage
          ? _value.backBackgroundImage
          : backBackgroundImage // ignore: cast_nullable_to_non_nullable
              as String?,
      borderStyle: null == borderStyle
          ? _value.borderStyle
          : borderStyle // ignore: cast_nullable_to_non_nullable
              as String,
      borderColor: null == borderColor
          ? _value.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as int,
      borderWidth: null == borderWidth
          ? _value.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      borderRadius: null == borderRadius
          ? _value.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FlashcardModelImplCopyWith<$Res>
    implements $FlashcardModelCopyWith<$Res> {
  factory _$$FlashcardModelImplCopyWith(_$FlashcardModelImpl value,
          $Res Function(_$FlashcardModelImpl) then) =
      __$$FlashcardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      List<StrokeModel> frontStrokes,
      List<StrokeModel> backStrokes,
      String? frontRecognizedText,
      String? backRecognizedText,
      DateTime createdAt,
      DateTime updatedAt,
      List<String> tags,
      int reviewCount,
      DateTime? lastReviewedAt,
      bool isFavorite,
      String? groupName,
      String? frontBackgroundImage,
      String? backBackgroundImage,
      String borderStyle,
      int borderColor,
      double borderWidth,
      double borderRadius});
}

/// @nodoc
class __$$FlashcardModelImplCopyWithImpl<$Res>
    extends _$FlashcardModelCopyWithImpl<$Res, _$FlashcardModelImpl>
    implements _$$FlashcardModelImplCopyWith<$Res> {
  __$$FlashcardModelImplCopyWithImpl(
      _$FlashcardModelImpl _value, $Res Function(_$FlashcardModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? frontStrokes = null,
    Object? backStrokes = null,
    Object? frontRecognizedText = freezed,
    Object? backRecognizedText = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? tags = null,
    Object? reviewCount = null,
    Object? lastReviewedAt = freezed,
    Object? isFavorite = null,
    Object? groupName = freezed,
    Object? frontBackgroundImage = freezed,
    Object? backBackgroundImage = freezed,
    Object? borderStyle = null,
    Object? borderColor = null,
    Object? borderWidth = null,
    Object? borderRadius = null,
  }) {
    return _then(_$FlashcardModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      frontStrokes: null == frontStrokes
          ? _value._frontStrokes
          : frontStrokes // ignore: cast_nullable_to_non_nullable
              as List<StrokeModel>,
      backStrokes: null == backStrokes
          ? _value._backStrokes
          : backStrokes // ignore: cast_nullable_to_non_nullable
              as List<StrokeModel>,
      frontRecognizedText: freezed == frontRecognizedText
          ? _value.frontRecognizedText
          : frontRecognizedText // ignore: cast_nullable_to_non_nullable
              as String?,
      backRecognizedText: freezed == backRecognizedText
          ? _value.backRecognizedText
          : backRecognizedText // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      groupName: freezed == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String?,
      frontBackgroundImage: freezed == frontBackgroundImage
          ? _value.frontBackgroundImage
          : frontBackgroundImage // ignore: cast_nullable_to_non_nullable
              as String?,
      backBackgroundImage: freezed == backBackgroundImage
          ? _value.backBackgroundImage
          : backBackgroundImage // ignore: cast_nullable_to_non_nullable
              as String?,
      borderStyle: null == borderStyle
          ? _value.borderStyle
          : borderStyle // ignore: cast_nullable_to_non_nullable
              as String,
      borderColor: null == borderColor
          ? _value.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as int,
      borderWidth: null == borderWidth
          ? _value.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      borderRadius: null == borderRadius
          ? _value.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardModelImpl implements _FlashcardModel {
  const _$FlashcardModelImpl(
      {required this.id,
      required this.title,
      required final List<StrokeModel> frontStrokes,
      required final List<StrokeModel> backStrokes,
      this.frontRecognizedText,
      this.backRecognizedText,
      required this.createdAt,
      required this.updatedAt,
      final List<String> tags = const [],
      this.reviewCount = 0,
      this.lastReviewedAt,
      this.isFavorite = false,
      this.groupName,
      this.frontBackgroundImage,
      this.backBackgroundImage,
      this.borderStyle = 'solid',
      this.borderColor = 0xFF6366F1,
      this.borderWidth = 2.0,
      this.borderRadius = 16.0})
      : _frontStrokes = frontStrokes,
        _backStrokes = backStrokes,
        _tags = tags;

  factory _$FlashcardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  final List<StrokeModel> _frontStrokes;
  @override
  List<StrokeModel> get frontStrokes {
    if (_frontStrokes is EqualUnmodifiableListView) return _frontStrokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_frontStrokes);
  }

  final List<StrokeModel> _backStrokes;
  @override
  List<StrokeModel> get backStrokes {
    if (_backStrokes is EqualUnmodifiableListView) return _backStrokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_backStrokes);
  }

  @override
  final String? frontRecognizedText;
  @override
  final String? backRecognizedText;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final int reviewCount;
  @override
  final DateTime? lastReviewedAt;

  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final String? groupName;
  @override
  final String? frontBackgroundImage;
  @override
  final String? backBackgroundImage;
  @override
  final String borderStyle;
  @override
  final int borderColor;
  @override
  final double borderWidth;
  @override
  final double borderRadius;

  @override
  String toString() {
    return 'FlashcardModel(id: $id, title: $title, frontStrokes: $frontStrokes, backStrokes: $backStrokes, frontRecognizedText: $frontRecognizedText, backRecognizedText: $backRecognizedText, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, reviewCount: $reviewCount, lastReviewedAt: $lastReviewedAt, isFavorite: $isFavorite, groupName: $groupName, frontBackgroundImage: $frontBackgroundImage, backBackgroundImage: $backBackgroundImage, borderStyle: $borderStyle, borderColor: $borderColor, borderWidth: $borderWidth, borderRadius: $borderRadius)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality()
                .equals(other._frontStrokes, _frontStrokes) &&
            const DeepCollectionEquality()
                .equals(other._backStrokes, _backStrokes) &&
            (identical(other.frontRecognizedText, frontRecognizedText) ||
                other.frontRecognizedText == frontRecognizedText) &&
            (identical(other.backRecognizedText, backRecognizedText) ||
                other.backRecognizedText == backRecognizedText) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updateAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.lastReviewedAt, lastReviewedAt) ||
                other.lastReviewedAt == lastReviewedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.frontBackgroundImage, frontBackgroundImage) ||
                other.frontBackgroundImage == frontBackgroundImage) &&
            (identical(other.backBackgroundImage, backBackgroundImage) ||
                other.backBackgroundImage == backBackgroundImage) &&
            (identical(other.borderStyle, borderStyle) ||
                other.borderStyle == borderStyle) &&
            (identical(other.borderColor, borderColor) ||
                other.borderColor == borderColor) &&
            (identical(other.borderWidth, borderWidth) ||
                other.borderWidth == borderWidth) &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      const DeepCollectionEquality().hash(_frontStrokes),
      const DeepCollectionEquality().hash(_backStrokes),
      frontRecognizedText,
      backRecognizedText,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_tags),
      reviewCount,
      lastReviewedAt,
      isFavorite,
      groupName,
      frontBackgroundImage,
      backBackgroundImage,
      borderStyle,
      borderColor,
      borderWidth,
      borderRadius);

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardModelImplCopyWith<_$FlashcardModelImpl> get copyWith =>
      __$$FlashcardModelImplCopyWithImpl<_$FlashcardModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardModelImplToJson(
      this,
    );
  }
}

abstract class _FlashcardModel implements FlashcardModel {
  const factory _FlashcardModel(
      {required final String id,
      required final String title,
      required final List<StrokeModel> frontStrokes,
      required final List<StrokeModel> backStrokes,
      final String? frontRecognizedText,
      final String? backRecognizedText,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final List<String> tags,
      final int reviewCount,
      final DateTime? lastReviewedAt,
      final bool isFavorite,
      final String? groupName,
      final String? frontBackgroundImage,
      final String? backBackgroundImage,
      final String borderStyle,
      final int borderColor,
      final double borderWidth,
      final double borderRadius}) = _$FlashcardModelImpl;

  factory _FlashcardModel.fromJson(Map<String, dynamic> json) =
      _$FlashcardModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  List<StrokeModel> get frontStrokes;
  @override
  List<StrokeModel> get backStrokes;
  @override
  String? get frontRecognizedText;
  @override
  String? get backRecognizedText;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  List<String> get tags;
  @override
  int get reviewCount;
  @override
  DateTime? get lastReviewedAt;
  @override
  bool get isFavorite;
  @override
  String? get groupName;
  @override
  String? get frontBackgroundImage;
  @override
  String? get backBackgroundImage;
  @override
  String get borderStyle;
  @override
  int get borderColor;
  @override
  double get borderWidth;
  @override
  double get borderRadius;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardModelImplCopyWith<_$FlashcardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
