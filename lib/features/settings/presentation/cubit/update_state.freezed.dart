// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UpdateState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function(UpdateInfo info) available,
    required TResult Function(double progress) downloading,
    required TResult Function(File zipFile) readyToInstall,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function(UpdateInfo info)? available,
    TResult? Function(double progress)? downloading,
    TResult? Function(File zipFile)? readyToInstall,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function(UpdateInfo info)? available,
    TResult Function(double progress)? downloading,
    TResult Function(File zipFile)? readyToInstall,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UpdateInitial value) initial,
    required TResult Function(UpdateChecking value) checking,
    required TResult Function(UpdateAvailable value) available,
    required TResult Function(UpdateDownloading value) downloading,
    required TResult Function(UpdateReadyToInstall value) readyToInstall,
    required TResult Function(UpdateError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UpdateInitial value)? initial,
    TResult? Function(UpdateChecking value)? checking,
    TResult? Function(UpdateAvailable value)? available,
    TResult? Function(UpdateDownloading value)? downloading,
    TResult? Function(UpdateReadyToInstall value)? readyToInstall,
    TResult? Function(UpdateError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UpdateInitial value)? initial,
    TResult Function(UpdateChecking value)? checking,
    TResult Function(UpdateAvailable value)? available,
    TResult Function(UpdateDownloading value)? downloading,
    TResult Function(UpdateReadyToInstall value)? readyToInstall,
    TResult Function(UpdateError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateStateCopyWith<$Res> {
  factory $UpdateStateCopyWith(
    UpdateState value,
    $Res Function(UpdateState) then,
  ) = _$UpdateStateCopyWithImpl<$Res, UpdateState>;
}

/// @nodoc
class _$UpdateStateCopyWithImpl<$Res, $Val extends UpdateState>
    implements $UpdateStateCopyWith<$Res> {
  _$UpdateStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$UpdateInitialImplCopyWith<$Res> {
  factory _$$UpdateInitialImplCopyWith(
    _$UpdateInitialImpl value,
    $Res Function(_$UpdateInitialImpl) then,
  ) = __$$UpdateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UpdateInitialImplCopyWithImpl<$Res>
    extends _$UpdateStateCopyWithImpl<$Res, _$UpdateInitialImpl>
    implements _$$UpdateInitialImplCopyWith<$Res> {
  __$$UpdateInitialImplCopyWithImpl(
    _$UpdateInitialImpl _value,
    $Res Function(_$UpdateInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UpdateInitialImpl implements UpdateInitial {
  const _$UpdateInitialImpl();

  @override
  String toString() {
    return 'UpdateState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UpdateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function(UpdateInfo info) available,
    required TResult Function(double progress) downloading,
    required TResult Function(File zipFile) readyToInstall,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function(UpdateInfo info)? available,
    TResult? Function(double progress)? downloading,
    TResult? Function(File zipFile)? readyToInstall,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function(UpdateInfo info)? available,
    TResult Function(double progress)? downloading,
    TResult Function(File zipFile)? readyToInstall,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UpdateInitial value) initial,
    required TResult Function(UpdateChecking value) checking,
    required TResult Function(UpdateAvailable value) available,
    required TResult Function(UpdateDownloading value) downloading,
    required TResult Function(UpdateReadyToInstall value) readyToInstall,
    required TResult Function(UpdateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UpdateInitial value)? initial,
    TResult? Function(UpdateChecking value)? checking,
    TResult? Function(UpdateAvailable value)? available,
    TResult? Function(UpdateDownloading value)? downloading,
    TResult? Function(UpdateReadyToInstall value)? readyToInstall,
    TResult? Function(UpdateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UpdateInitial value)? initial,
    TResult Function(UpdateChecking value)? checking,
    TResult Function(UpdateAvailable value)? available,
    TResult Function(UpdateDownloading value)? downloading,
    TResult Function(UpdateReadyToInstall value)? readyToInstall,
    TResult Function(UpdateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class UpdateInitial implements UpdateState {
  const factory UpdateInitial() = _$UpdateInitialImpl;
}

/// @nodoc
abstract class _$$UpdateCheckingImplCopyWith<$Res> {
  factory _$$UpdateCheckingImplCopyWith(
    _$UpdateCheckingImpl value,
    $Res Function(_$UpdateCheckingImpl) then,
  ) = __$$UpdateCheckingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UpdateCheckingImplCopyWithImpl<$Res>
    extends _$UpdateStateCopyWithImpl<$Res, _$UpdateCheckingImpl>
    implements _$$UpdateCheckingImplCopyWith<$Res> {
  __$$UpdateCheckingImplCopyWithImpl(
    _$UpdateCheckingImpl _value,
    $Res Function(_$UpdateCheckingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UpdateCheckingImpl implements UpdateChecking {
  const _$UpdateCheckingImpl();

  @override
  String toString() {
    return 'UpdateState.checking()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UpdateCheckingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function(UpdateInfo info) available,
    required TResult Function(double progress) downloading,
    required TResult Function(File zipFile) readyToInstall,
    required TResult Function(String message) error,
  }) {
    return checking();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function(UpdateInfo info)? available,
    TResult? Function(double progress)? downloading,
    TResult? Function(File zipFile)? readyToInstall,
    TResult? Function(String message)? error,
  }) {
    return checking?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function(UpdateInfo info)? available,
    TResult Function(double progress)? downloading,
    TResult Function(File zipFile)? readyToInstall,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (checking != null) {
      return checking();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UpdateInitial value) initial,
    required TResult Function(UpdateChecking value) checking,
    required TResult Function(UpdateAvailable value) available,
    required TResult Function(UpdateDownloading value) downloading,
    required TResult Function(UpdateReadyToInstall value) readyToInstall,
    required TResult Function(UpdateError value) error,
  }) {
    return checking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UpdateInitial value)? initial,
    TResult? Function(UpdateChecking value)? checking,
    TResult? Function(UpdateAvailable value)? available,
    TResult? Function(UpdateDownloading value)? downloading,
    TResult? Function(UpdateReadyToInstall value)? readyToInstall,
    TResult? Function(UpdateError value)? error,
  }) {
    return checking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UpdateInitial value)? initial,
    TResult Function(UpdateChecking value)? checking,
    TResult Function(UpdateAvailable value)? available,
    TResult Function(UpdateDownloading value)? downloading,
    TResult Function(UpdateReadyToInstall value)? readyToInstall,
    TResult Function(UpdateError value)? error,
    required TResult orElse(),
  }) {
    if (checking != null) {
      return checking(this);
    }
    return orElse();
  }
}

abstract class UpdateChecking implements UpdateState {
  const factory UpdateChecking() = _$UpdateCheckingImpl;
}

/// @nodoc
abstract class _$$UpdateAvailableImplCopyWith<$Res> {
  factory _$$UpdateAvailableImplCopyWith(
    _$UpdateAvailableImpl value,
    $Res Function(_$UpdateAvailableImpl) then,
  ) = __$$UpdateAvailableImplCopyWithImpl<$Res>;
  @useResult
  $Res call({UpdateInfo info});
}

/// @nodoc
class __$$UpdateAvailableImplCopyWithImpl<$Res>
    extends _$UpdateStateCopyWithImpl<$Res, _$UpdateAvailableImpl>
    implements _$$UpdateAvailableImplCopyWith<$Res> {
  __$$UpdateAvailableImplCopyWithImpl(
    _$UpdateAvailableImpl _value,
    $Res Function(_$UpdateAvailableImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? info = null}) {
    return _then(
      _$UpdateAvailableImpl(
        null == info
            ? _value.info
            : info // ignore: cast_nullable_to_non_nullable
                  as UpdateInfo,
      ),
    );
  }
}

/// @nodoc

class _$UpdateAvailableImpl implements UpdateAvailable {
  const _$UpdateAvailableImpl(this.info);

  @override
  final UpdateInfo info;

  @override
  String toString() {
    return 'UpdateState.available(info: $info)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateAvailableImpl &&
            (identical(other.info, info) || other.info == info));
  }

  @override
  int get hashCode => Object.hash(runtimeType, info);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateAvailableImplCopyWith<_$UpdateAvailableImpl> get copyWith =>
      __$$UpdateAvailableImplCopyWithImpl<_$UpdateAvailableImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function(UpdateInfo info) available,
    required TResult Function(double progress) downloading,
    required TResult Function(File zipFile) readyToInstall,
    required TResult Function(String message) error,
  }) {
    return available(info);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function(UpdateInfo info)? available,
    TResult? Function(double progress)? downloading,
    TResult? Function(File zipFile)? readyToInstall,
    TResult? Function(String message)? error,
  }) {
    return available?.call(info);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function(UpdateInfo info)? available,
    TResult Function(double progress)? downloading,
    TResult Function(File zipFile)? readyToInstall,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (available != null) {
      return available(info);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UpdateInitial value) initial,
    required TResult Function(UpdateChecking value) checking,
    required TResult Function(UpdateAvailable value) available,
    required TResult Function(UpdateDownloading value) downloading,
    required TResult Function(UpdateReadyToInstall value) readyToInstall,
    required TResult Function(UpdateError value) error,
  }) {
    return available(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UpdateInitial value)? initial,
    TResult? Function(UpdateChecking value)? checking,
    TResult? Function(UpdateAvailable value)? available,
    TResult? Function(UpdateDownloading value)? downloading,
    TResult? Function(UpdateReadyToInstall value)? readyToInstall,
    TResult? Function(UpdateError value)? error,
  }) {
    return available?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UpdateInitial value)? initial,
    TResult Function(UpdateChecking value)? checking,
    TResult Function(UpdateAvailable value)? available,
    TResult Function(UpdateDownloading value)? downloading,
    TResult Function(UpdateReadyToInstall value)? readyToInstall,
    TResult Function(UpdateError value)? error,
    required TResult orElse(),
  }) {
    if (available != null) {
      return available(this);
    }
    return orElse();
  }
}

abstract class UpdateAvailable implements UpdateState {
  const factory UpdateAvailable(final UpdateInfo info) = _$UpdateAvailableImpl;

  UpdateInfo get info;

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateAvailableImplCopyWith<_$UpdateAvailableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateDownloadingImplCopyWith<$Res> {
  factory _$$UpdateDownloadingImplCopyWith(
    _$UpdateDownloadingImpl value,
    $Res Function(_$UpdateDownloadingImpl) then,
  ) = __$$UpdateDownloadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double progress});
}

/// @nodoc
class __$$UpdateDownloadingImplCopyWithImpl<$Res>
    extends _$UpdateStateCopyWithImpl<$Res, _$UpdateDownloadingImpl>
    implements _$$UpdateDownloadingImplCopyWith<$Res> {
  __$$UpdateDownloadingImplCopyWithImpl(
    _$UpdateDownloadingImpl _value,
    $Res Function(_$UpdateDownloadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? progress = null}) {
    return _then(
      _$UpdateDownloadingImpl(
        null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$UpdateDownloadingImpl implements UpdateDownloading {
  const _$UpdateDownloadingImpl(this.progress);

  @override
  final double progress;

  @override
  String toString() {
    return 'UpdateState.downloading(progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateDownloadingImpl &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, progress);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateDownloadingImplCopyWith<_$UpdateDownloadingImpl> get copyWith =>
      __$$UpdateDownloadingImplCopyWithImpl<_$UpdateDownloadingImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function(UpdateInfo info) available,
    required TResult Function(double progress) downloading,
    required TResult Function(File zipFile) readyToInstall,
    required TResult Function(String message) error,
  }) {
    return downloading(progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function(UpdateInfo info)? available,
    TResult? Function(double progress)? downloading,
    TResult? Function(File zipFile)? readyToInstall,
    TResult? Function(String message)? error,
  }) {
    return downloading?.call(progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function(UpdateInfo info)? available,
    TResult Function(double progress)? downloading,
    TResult Function(File zipFile)? readyToInstall,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (downloading != null) {
      return downloading(progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UpdateInitial value) initial,
    required TResult Function(UpdateChecking value) checking,
    required TResult Function(UpdateAvailable value) available,
    required TResult Function(UpdateDownloading value) downloading,
    required TResult Function(UpdateReadyToInstall value) readyToInstall,
    required TResult Function(UpdateError value) error,
  }) {
    return downloading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UpdateInitial value)? initial,
    TResult? Function(UpdateChecking value)? checking,
    TResult? Function(UpdateAvailable value)? available,
    TResult? Function(UpdateDownloading value)? downloading,
    TResult? Function(UpdateReadyToInstall value)? readyToInstall,
    TResult? Function(UpdateError value)? error,
  }) {
    return downloading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UpdateInitial value)? initial,
    TResult Function(UpdateChecking value)? checking,
    TResult Function(UpdateAvailable value)? available,
    TResult Function(UpdateDownloading value)? downloading,
    TResult Function(UpdateReadyToInstall value)? readyToInstall,
    TResult Function(UpdateError value)? error,
    required TResult orElse(),
  }) {
    if (downloading != null) {
      return downloading(this);
    }
    return orElse();
  }
}

abstract class UpdateDownloading implements UpdateState {
  const factory UpdateDownloading(final double progress) =
      _$UpdateDownloadingImpl;

  double get progress;

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateDownloadingImplCopyWith<_$UpdateDownloadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateReadyToInstallImplCopyWith<$Res> {
  factory _$$UpdateReadyToInstallImplCopyWith(
    _$UpdateReadyToInstallImpl value,
    $Res Function(_$UpdateReadyToInstallImpl) then,
  ) = __$$UpdateReadyToInstallImplCopyWithImpl<$Res>;
  @useResult
  $Res call({File zipFile});
}

/// @nodoc
class __$$UpdateReadyToInstallImplCopyWithImpl<$Res>
    extends _$UpdateStateCopyWithImpl<$Res, _$UpdateReadyToInstallImpl>
    implements _$$UpdateReadyToInstallImplCopyWith<$Res> {
  __$$UpdateReadyToInstallImplCopyWithImpl(
    _$UpdateReadyToInstallImpl _value,
    $Res Function(_$UpdateReadyToInstallImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? zipFile = freezed}) {
    return _then(
      _$UpdateReadyToInstallImpl(
        freezed == zipFile
            ? _value.zipFile
            : zipFile // ignore: cast_nullable_to_non_nullable
                  as File,
      ),
    );
  }
}

/// @nodoc

class _$UpdateReadyToInstallImpl implements UpdateReadyToInstall {
  const _$UpdateReadyToInstallImpl(this.zipFile);

  @override
  final File zipFile;

  @override
  String toString() {
    return 'UpdateState.readyToInstall(zipFile: $zipFile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateReadyToInstallImpl &&
            const DeepCollectionEquality().equals(other.zipFile, zipFile));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(zipFile));

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateReadyToInstallImplCopyWith<_$UpdateReadyToInstallImpl>
  get copyWith =>
      __$$UpdateReadyToInstallImplCopyWithImpl<_$UpdateReadyToInstallImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function(UpdateInfo info) available,
    required TResult Function(double progress) downloading,
    required TResult Function(File zipFile) readyToInstall,
    required TResult Function(String message) error,
  }) {
    return readyToInstall(zipFile);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function(UpdateInfo info)? available,
    TResult? Function(double progress)? downloading,
    TResult? Function(File zipFile)? readyToInstall,
    TResult? Function(String message)? error,
  }) {
    return readyToInstall?.call(zipFile);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function(UpdateInfo info)? available,
    TResult Function(double progress)? downloading,
    TResult Function(File zipFile)? readyToInstall,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (readyToInstall != null) {
      return readyToInstall(zipFile);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UpdateInitial value) initial,
    required TResult Function(UpdateChecking value) checking,
    required TResult Function(UpdateAvailable value) available,
    required TResult Function(UpdateDownloading value) downloading,
    required TResult Function(UpdateReadyToInstall value) readyToInstall,
    required TResult Function(UpdateError value) error,
  }) {
    return readyToInstall(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UpdateInitial value)? initial,
    TResult? Function(UpdateChecking value)? checking,
    TResult? Function(UpdateAvailable value)? available,
    TResult? Function(UpdateDownloading value)? downloading,
    TResult? Function(UpdateReadyToInstall value)? readyToInstall,
    TResult? Function(UpdateError value)? error,
  }) {
    return readyToInstall?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UpdateInitial value)? initial,
    TResult Function(UpdateChecking value)? checking,
    TResult Function(UpdateAvailable value)? available,
    TResult Function(UpdateDownloading value)? downloading,
    TResult Function(UpdateReadyToInstall value)? readyToInstall,
    TResult Function(UpdateError value)? error,
    required TResult orElse(),
  }) {
    if (readyToInstall != null) {
      return readyToInstall(this);
    }
    return orElse();
  }
}

abstract class UpdateReadyToInstall implements UpdateState {
  const factory UpdateReadyToInstall(final File zipFile) =
      _$UpdateReadyToInstallImpl;

  File get zipFile;

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateReadyToInstallImplCopyWith<_$UpdateReadyToInstallImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateErrorImplCopyWith<$Res> {
  factory _$$UpdateErrorImplCopyWith(
    _$UpdateErrorImpl value,
    $Res Function(_$UpdateErrorImpl) then,
  ) = __$$UpdateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UpdateErrorImplCopyWithImpl<$Res>
    extends _$UpdateStateCopyWithImpl<$Res, _$UpdateErrorImpl>
    implements _$$UpdateErrorImplCopyWith<$Res> {
  __$$UpdateErrorImplCopyWithImpl(
    _$UpdateErrorImpl _value,
    $Res Function(_$UpdateErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$UpdateErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UpdateErrorImpl implements UpdateError {
  const _$UpdateErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'UpdateState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateErrorImplCopyWith<_$UpdateErrorImpl> get copyWith =>
      __$$UpdateErrorImplCopyWithImpl<_$UpdateErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checking,
    required TResult Function(UpdateInfo info) available,
    required TResult Function(double progress) downloading,
    required TResult Function(File zipFile) readyToInstall,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checking,
    TResult? Function(UpdateInfo info)? available,
    TResult? Function(double progress)? downloading,
    TResult? Function(File zipFile)? readyToInstall,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checking,
    TResult Function(UpdateInfo info)? available,
    TResult Function(double progress)? downloading,
    TResult Function(File zipFile)? readyToInstall,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UpdateInitial value) initial,
    required TResult Function(UpdateChecking value) checking,
    required TResult Function(UpdateAvailable value) available,
    required TResult Function(UpdateDownloading value) downloading,
    required TResult Function(UpdateReadyToInstall value) readyToInstall,
    required TResult Function(UpdateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UpdateInitial value)? initial,
    TResult? Function(UpdateChecking value)? checking,
    TResult? Function(UpdateAvailable value)? available,
    TResult? Function(UpdateDownloading value)? downloading,
    TResult? Function(UpdateReadyToInstall value)? readyToInstall,
    TResult? Function(UpdateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UpdateInitial value)? initial,
    TResult Function(UpdateChecking value)? checking,
    TResult Function(UpdateAvailable value)? available,
    TResult Function(UpdateDownloading value)? downloading,
    TResult Function(UpdateReadyToInstall value)? readyToInstall,
    TResult Function(UpdateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class UpdateError implements UpdateState {
  const factory UpdateError(final String message) = _$UpdateErrorImpl;

  String get message;

  /// Create a copy of UpdateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateErrorImplCopyWith<_$UpdateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
