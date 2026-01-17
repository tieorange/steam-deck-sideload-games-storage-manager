// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'storage_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StorageInfo _$StorageInfoFromJson(Map<String, dynamic> json) {
  return _StorageInfo.fromJson(json);
}

/// @nodoc
mixin _$StorageInfo {
  /// Path to the storage location
  String get path => throw _privateConstructorUsedError;

  /// Used space in bytes
  int get usedBytes => throw _privateConstructorUsedError;

  /// Total space in bytes
  int get totalBytes => throw _privateConstructorUsedError;

  /// Label (e.g., "Internal SSD", "SD Card")
  String? get label => throw _privateConstructorUsedError;

  /// Serializes this StorageInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StorageInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StorageInfoCopyWith<StorageInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StorageInfoCopyWith<$Res> {
  factory $StorageInfoCopyWith(
    StorageInfo value,
    $Res Function(StorageInfo) then,
  ) = _$StorageInfoCopyWithImpl<$Res, StorageInfo>;
  @useResult
  $Res call({String path, int usedBytes, int totalBytes, String? label});
}

/// @nodoc
class _$StorageInfoCopyWithImpl<$Res, $Val extends StorageInfo>
    implements $StorageInfoCopyWith<$Res> {
  _$StorageInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StorageInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? usedBytes = null,
    Object? totalBytes = null,
    Object? label = freezed,
  }) {
    return _then(
      _value.copyWith(
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            usedBytes: null == usedBytes
                ? _value.usedBytes
                : usedBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalBytes: null == totalBytes
                ? _value.totalBytes
                : totalBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StorageInfoImplCopyWith<$Res>
    implements $StorageInfoCopyWith<$Res> {
  factory _$$StorageInfoImplCopyWith(
    _$StorageInfoImpl value,
    $Res Function(_$StorageInfoImpl) then,
  ) = __$$StorageInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String path, int usedBytes, int totalBytes, String? label});
}

/// @nodoc
class __$$StorageInfoImplCopyWithImpl<$Res>
    extends _$StorageInfoCopyWithImpl<$Res, _$StorageInfoImpl>
    implements _$$StorageInfoImplCopyWith<$Res> {
  __$$StorageInfoImplCopyWithImpl(
    _$StorageInfoImpl _value,
    $Res Function(_$StorageInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StorageInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? usedBytes = null,
    Object? totalBytes = null,
    Object? label = freezed,
  }) {
    return _then(
      _$StorageInfoImpl(
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        usedBytes: null == usedBytes
            ? _value.usedBytes
            : usedBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalBytes: null == totalBytes
            ? _value.totalBytes
            : totalBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StorageInfoImpl implements _StorageInfo {
  const _$StorageInfoImpl({
    required this.path,
    required this.usedBytes,
    required this.totalBytes,
    this.label,
  });

  factory _$StorageInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$StorageInfoImplFromJson(json);

  /// Path to the storage location
  @override
  final String path;

  /// Used space in bytes
  @override
  final int usedBytes;

  /// Total space in bytes
  @override
  final int totalBytes;

  /// Label (e.g., "Internal SSD", "SD Card")
  @override
  final String? label;

  @override
  String toString() {
    return 'StorageInfo(path: $path, usedBytes: $usedBytes, totalBytes: $totalBytes, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageInfoImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.usedBytes, usedBytes) ||
                other.usedBytes == usedBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, path, usedBytes, totalBytes, label);

  /// Create a copy of StorageInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageInfoImplCopyWith<_$StorageInfoImpl> get copyWith =>
      __$$StorageInfoImplCopyWithImpl<_$StorageInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StorageInfoImplToJson(this);
  }
}

abstract class _StorageInfo implements StorageInfo {
  const factory _StorageInfo({
    required final String path,
    required final int usedBytes,
    required final int totalBytes,
    final String? label,
  }) = _$StorageInfoImpl;

  factory _StorageInfo.fromJson(Map<String, dynamic> json) =
      _$StorageInfoImpl.fromJson;

  /// Path to the storage location
  @override
  String get path;

  /// Used space in bytes
  @override
  int get usedBytes;

  /// Total space in bytes
  @override
  int get totalBytes;

  /// Label (e.g., "Internal SSD", "SD Card")
  @override
  String? get label;

  /// Create a copy of StorageInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StorageInfoImplCopyWith<_$StorageInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
