// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Settings _$SettingsFromJson(Map<String, dynamic> json) {
  return _Settings.fromJson(json);
}

/// @nodoc
mixin _$Settings {
  /// Theme mode
  ThemeMode get themeMode => throw _privateConstructorUsedError;

  /// Custom Heroic config path (optional override)
  String? get heroicConfigPath => throw _privateConstructorUsedError;

  /// Custom Lutris DB path (optional override)
  String? get lutrisDbPath => throw _privateConstructorUsedError;

  /// Custom Steam path (optional override)
  String? get steamPath => throw _privateConstructorUsedError;

  /// Custom OGI library path (optional override)
  String? get ogiLibraryPath => throw _privateConstructorUsedError;

  /// Whether to show confirmation before uninstall
  bool get confirmBeforeUninstall => throw _privateConstructorUsedError;

  /// Whether to sort by size descending by default
  bool get sortBySizeDescending => throw _privateConstructorUsedError;

  /// Serializes this Settings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsCopyWith<Settings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsCopyWith<$Res> {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) then) =
      _$SettingsCopyWithImpl<$Res, Settings>;
  @useResult
  $Res call({
    ThemeMode themeMode,
    String? heroicConfigPath,
    String? lutrisDbPath,
    String? steamPath,
    String? ogiLibraryPath,
    bool confirmBeforeUninstall,
    bool sortBySizeDescending,
  });
}

/// @nodoc
class _$SettingsCopyWithImpl<$Res, $Val extends Settings>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? heroicConfigPath = freezed,
    Object? lutrisDbPath = freezed,
    Object? steamPath = freezed,
    Object? ogiLibraryPath = freezed,
    Object? confirmBeforeUninstall = null,
    Object? sortBySizeDescending = null,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as ThemeMode,
            heroicConfigPath: freezed == heroicConfigPath
                ? _value.heroicConfigPath
                : heroicConfigPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            lutrisDbPath: freezed == lutrisDbPath
                ? _value.lutrisDbPath
                : lutrisDbPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            steamPath: freezed == steamPath
                ? _value.steamPath
                : steamPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            ogiLibraryPath: freezed == ogiLibraryPath
                ? _value.ogiLibraryPath
                : ogiLibraryPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            confirmBeforeUninstall: null == confirmBeforeUninstall
                ? _value.confirmBeforeUninstall
                : confirmBeforeUninstall // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortBySizeDescending: null == sortBySizeDescending
                ? _value.sortBySizeDescending
                : sortBySizeDescending // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettingsImplCopyWith<$Res>
    implements $SettingsCopyWith<$Res> {
  factory _$$SettingsImplCopyWith(
    _$SettingsImpl value,
    $Res Function(_$SettingsImpl) then,
  ) = __$$SettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ThemeMode themeMode,
    String? heroicConfigPath,
    String? lutrisDbPath,
    String? steamPath,
    String? ogiLibraryPath,
    bool confirmBeforeUninstall,
    bool sortBySizeDescending,
  });
}

/// @nodoc
class __$$SettingsImplCopyWithImpl<$Res>
    extends _$SettingsCopyWithImpl<$Res, _$SettingsImpl>
    implements _$$SettingsImplCopyWith<$Res> {
  __$$SettingsImplCopyWithImpl(
    _$SettingsImpl _value,
    $Res Function(_$SettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? heroicConfigPath = freezed,
    Object? lutrisDbPath = freezed,
    Object? steamPath = freezed,
    Object? ogiLibraryPath = freezed,
    Object? confirmBeforeUninstall = null,
    Object? sortBySizeDescending = null,
  }) {
    return _then(
      _$SettingsImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as ThemeMode,
        heroicConfigPath: freezed == heroicConfigPath
            ? _value.heroicConfigPath
            : heroicConfigPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        lutrisDbPath: freezed == lutrisDbPath
            ? _value.lutrisDbPath
            : lutrisDbPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        steamPath: freezed == steamPath
            ? _value.steamPath
            : steamPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        ogiLibraryPath: freezed == ogiLibraryPath
            ? _value.ogiLibraryPath
            : ogiLibraryPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        confirmBeforeUninstall: null == confirmBeforeUninstall
            ? _value.confirmBeforeUninstall
            : confirmBeforeUninstall // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortBySizeDescending: null == sortBySizeDescending
            ? _value.sortBySizeDescending
            : sortBySizeDescending // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsImpl implements _Settings {
  const _$SettingsImpl({
    this.themeMode = ThemeMode.dark,
    this.heroicConfigPath,
    this.lutrisDbPath,
    this.steamPath,
    this.ogiLibraryPath,
    this.confirmBeforeUninstall = true,
    this.sortBySizeDescending = true,
  });

  factory _$SettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsImplFromJson(json);

  /// Theme mode
  @override
  @JsonKey()
  final ThemeMode themeMode;

  /// Custom Heroic config path (optional override)
  @override
  final String? heroicConfigPath;

  /// Custom Lutris DB path (optional override)
  @override
  final String? lutrisDbPath;

  /// Custom Steam path (optional override)
  @override
  final String? steamPath;

  /// Custom OGI library path (optional override)
  @override
  final String? ogiLibraryPath;

  /// Whether to show confirmation before uninstall
  @override
  @JsonKey()
  final bool confirmBeforeUninstall;

  /// Whether to sort by size descending by default
  @override
  @JsonKey()
  final bool sortBySizeDescending;

  @override
  String toString() {
    return 'Settings(themeMode: $themeMode, heroicConfigPath: $heroicConfigPath, lutrisDbPath: $lutrisDbPath, steamPath: $steamPath, ogiLibraryPath: $ogiLibraryPath, confirmBeforeUninstall: $confirmBeforeUninstall, sortBySizeDescending: $sortBySizeDescending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.heroicConfigPath, heroicConfigPath) ||
                other.heroicConfigPath == heroicConfigPath) &&
            (identical(other.lutrisDbPath, lutrisDbPath) ||
                other.lutrisDbPath == lutrisDbPath) &&
            (identical(other.steamPath, steamPath) ||
                other.steamPath == steamPath) &&
            (identical(other.ogiLibraryPath, ogiLibraryPath) ||
                other.ogiLibraryPath == ogiLibraryPath) &&
            (identical(other.confirmBeforeUninstall, confirmBeforeUninstall) ||
                other.confirmBeforeUninstall == confirmBeforeUninstall) &&
            (identical(other.sortBySizeDescending, sortBySizeDescending) ||
                other.sortBySizeDescending == sortBySizeDescending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    themeMode,
    heroicConfigPath,
    lutrisDbPath,
    steamPath,
    ogiLibraryPath,
    confirmBeforeUninstall,
    sortBySizeDescending,
  );

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsImplCopyWith<_$SettingsImpl> get copyWith =>
      __$$SettingsImplCopyWithImpl<_$SettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsImplToJson(this);
  }
}

abstract class _Settings implements Settings {
  const factory _Settings({
    final ThemeMode themeMode,
    final String? heroicConfigPath,
    final String? lutrisDbPath,
    final String? steamPath,
    final String? ogiLibraryPath,
    final bool confirmBeforeUninstall,
    final bool sortBySizeDescending,
  }) = _$SettingsImpl;

  factory _Settings.fromJson(Map<String, dynamic> json) =
      _$SettingsImpl.fromJson;

  /// Theme mode
  @override
  ThemeMode get themeMode;

  /// Custom Heroic config path (optional override)
  @override
  String? get heroicConfigPath;

  /// Custom Lutris DB path (optional override)
  @override
  String? get lutrisDbPath;

  /// Custom Steam path (optional override)
  @override
  String? get steamPath;

  /// Custom OGI library path (optional override)
  @override
  String? get ogiLibraryPath;

  /// Whether to show confirmation before uninstall
  @override
  bool get confirmBeforeUninstall;

  /// Whether to sort by size descending by default
  @override
  bool get sortBySizeDescending;

  /// Create a copy of Settings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsImplCopyWith<_$SettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
