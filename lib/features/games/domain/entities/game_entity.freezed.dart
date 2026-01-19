// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Game _$GameFromJson(Map<String, dynamic> json) {
  return _Game.fromJson(json);
}

/// @nodoc
mixin _$Game {
  /// Unique identifier (app name, slug, or appid)
  String get id => throw _privateConstructorUsedError;

  /// Display title
  String get title => throw _privateConstructorUsedError;

  /// Source launcher
  GameSource get source => throw _privateConstructorUsedError;

  /// Full path to installation directory
  String get installPath => throw _privateConstructorUsedError;

  /// Size in bytes (0 if not yet calculated)
  int get sizeBytes => throw _privateConstructorUsedError;

  /// Path to game icon (optional)
  String? get iconPath => throw _privateConstructorUsedError;

  /// Custom launch options (optional)
  String? get launchOptions => throw _privateConstructorUsedError;

  /// Proton version for compatibility (optional)
  String? get protonVersion => throw _privateConstructorUsedError;

  /// Storage location (internal or SD card)
  StorageLocation get storageLocation => throw _privateConstructorUsedError;

  /// Whether this game is selected for batch operations
  bool get isSelected => throw _privateConstructorUsedError;

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCopyWith<Game> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) then) =
      _$GameCopyWithImpl<$Res, Game>;
  @useResult
  $Res call({
    String id,
    String title,
    GameSource source,
    String installPath,
    int sizeBytes,
    String? iconPath,
    String? launchOptions,
    String? protonVersion,
    StorageLocation storageLocation,
    bool isSelected,
  });
}

/// @nodoc
class _$GameCopyWithImpl<$Res, $Val extends Game>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? source = null,
    Object? installPath = null,
    Object? sizeBytes = null,
    Object? iconPath = freezed,
    Object? launchOptions = freezed,
    Object? protonVersion = freezed,
    Object? storageLocation = null,
    Object? isSelected = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as GameSource,
            installPath: null == installPath
                ? _value.installPath
                : installPath // ignore: cast_nullable_to_non_nullable
                      as String,
            sizeBytes: null == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            iconPath: freezed == iconPath
                ? _value.iconPath
                : iconPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            launchOptions: freezed == launchOptions
                ? _value.launchOptions
                : launchOptions // ignore: cast_nullable_to_non_nullable
                      as String?,
            protonVersion: freezed == protonVersion
                ? _value.protonVersion
                : protonVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            storageLocation: null == storageLocation
                ? _value.storageLocation
                : storageLocation // ignore: cast_nullable_to_non_nullable
                      as StorageLocation,
            isSelected: null == isSelected
                ? _value.isSelected
                : isSelected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameImplCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$$GameImplCopyWith(
    _$GameImpl value,
    $Res Function(_$GameImpl) then,
  ) = __$$GameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    GameSource source,
    String installPath,
    int sizeBytes,
    String? iconPath,
    String? launchOptions,
    String? protonVersion,
    StorageLocation storageLocation,
    bool isSelected,
  });
}

/// @nodoc
class __$$GameImplCopyWithImpl<$Res>
    extends _$GameCopyWithImpl<$Res, _$GameImpl>
    implements _$$GameImplCopyWith<$Res> {
  __$$GameImplCopyWithImpl(_$GameImpl _value, $Res Function(_$GameImpl) _then)
    : super(_value, _then);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? source = null,
    Object? installPath = null,
    Object? sizeBytes = null,
    Object? iconPath = freezed,
    Object? launchOptions = freezed,
    Object? protonVersion = freezed,
    Object? storageLocation = null,
    Object? isSelected = null,
  }) {
    return _then(
      _$GameImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as GameSource,
        installPath: null == installPath
            ? _value.installPath
            : installPath // ignore: cast_nullable_to_non_nullable
                  as String,
        sizeBytes: null == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        iconPath: freezed == iconPath
            ? _value.iconPath
            : iconPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        launchOptions: freezed == launchOptions
            ? _value.launchOptions
            : launchOptions // ignore: cast_nullable_to_non_nullable
                  as String?,
        protonVersion: freezed == protonVersion
            ? _value.protonVersion
            : protonVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        storageLocation: null == storageLocation
            ? _value.storageLocation
            : storageLocation // ignore: cast_nullable_to_non_nullable
                  as StorageLocation,
        isSelected: null == isSelected
            ? _value.isSelected
            : isSelected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameImpl implements _Game {
  const _$GameImpl({
    required this.id,
    required this.title,
    required this.source,
    required this.installPath,
    required this.sizeBytes,
    this.iconPath,
    this.launchOptions,
    this.protonVersion,
    this.storageLocation = StorageLocation.internal,
    this.isSelected = false,
  });

  factory _$GameImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameImplFromJson(json);

  /// Unique identifier (app name, slug, or appid)
  @override
  final String id;

  /// Display title
  @override
  final String title;

  /// Source launcher
  @override
  final GameSource source;

  /// Full path to installation directory
  @override
  final String installPath;

  /// Size in bytes (0 if not yet calculated)
  @override
  final int sizeBytes;

  /// Path to game icon (optional)
  @override
  final String? iconPath;

  /// Custom launch options (optional)
  @override
  final String? launchOptions;

  /// Proton version for compatibility (optional)
  @override
  final String? protonVersion;

  /// Storage location (internal or SD card)
  @override
  @JsonKey()
  final StorageLocation storageLocation;

  /// Whether this game is selected for batch operations
  @override
  @JsonKey()
  final bool isSelected;

  @override
  String toString() {
    return 'Game(id: $id, title: $title, source: $source, installPath: $installPath, sizeBytes: $sizeBytes, iconPath: $iconPath, launchOptions: $launchOptions, protonVersion: $protonVersion, storageLocation: $storageLocation, isSelected: $isSelected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.installPath, installPath) ||
                other.installPath == installPath) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(other.launchOptions, launchOptions) ||
                other.launchOptions == launchOptions) &&
            (identical(other.protonVersion, protonVersion) ||
                other.protonVersion == protonVersion) &&
            (identical(other.storageLocation, storageLocation) ||
                other.storageLocation == storageLocation) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    source,
    installPath,
    sizeBytes,
    iconPath,
    launchOptions,
    protonVersion,
    storageLocation,
    isSelected,
  );

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      __$$GameImplCopyWithImpl<_$GameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameImplToJson(this);
  }
}

abstract class _Game implements Game {
  const factory _Game({
    required final String id,
    required final String title,
    required final GameSource source,
    required final String installPath,
    required final int sizeBytes,
    final String? iconPath,
    final String? launchOptions,
    final String? protonVersion,
    final StorageLocation storageLocation,
    final bool isSelected,
  }) = _$GameImpl;

  factory _Game.fromJson(Map<String, dynamic> json) = _$GameImpl.fromJson;

  /// Unique identifier (app name, slug, or appid)
  @override
  String get id;

  /// Display title
  @override
  String get title;

  /// Source launcher
  @override
  GameSource get source;

  /// Full path to installation directory
  @override
  String get installPath;

  /// Size in bytes (0 if not yet calculated)
  @override
  int get sizeBytes;

  /// Path to game icon (optional)
  @override
  String? get iconPath;

  /// Custom launch options (optional)
  @override
  String? get launchOptions;

  /// Proton version for compatibility (optional)
  @override
  String? get protonVersion;

  /// Storage location (internal or SD card)
  @override
  StorageLocation get storageLocation;

  /// Whether this game is selected for batch operations
  @override
  bool get isSelected;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
