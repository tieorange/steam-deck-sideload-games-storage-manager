// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RefreshProgressState {
  String get currentPhase => throw _privateConstructorUsedError;
  double get progressPercent => throw _privateConstructorUsedError;
  String get funPhrase => throw _privateConstructorUsedError;
  Duration? get estimatedTimeRemaining => throw _privateConstructorUsedError;

  /// Create a copy of RefreshProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefreshProgressStateCopyWith<RefreshProgressState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefreshProgressStateCopyWith<$Res> {
  factory $RefreshProgressStateCopyWith(
    RefreshProgressState value,
    $Res Function(RefreshProgressState) then,
  ) = _$RefreshProgressStateCopyWithImpl<$Res, RefreshProgressState>;
  @useResult
  $Res call({
    String currentPhase,
    double progressPercent,
    String funPhrase,
    Duration? estimatedTimeRemaining,
  });
}

/// @nodoc
class _$RefreshProgressStateCopyWithImpl<
  $Res,
  $Val extends RefreshProgressState
>
    implements $RefreshProgressStateCopyWith<$Res> {
  _$RefreshProgressStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RefreshProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPhase = null,
    Object? progressPercent = null,
    Object? funPhrase = null,
    Object? estimatedTimeRemaining = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentPhase: null == currentPhase
                ? _value.currentPhase
                : currentPhase // ignore: cast_nullable_to_non_nullable
                      as String,
            progressPercent: null == progressPercent
                ? _value.progressPercent
                : progressPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            funPhrase: null == funPhrase
                ? _value.funPhrase
                : funPhrase // ignore: cast_nullable_to_non_nullable
                      as String,
            estimatedTimeRemaining: freezed == estimatedTimeRemaining
                ? _value.estimatedTimeRemaining
                : estimatedTimeRemaining // ignore: cast_nullable_to_non_nullable
                      as Duration?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RefreshProgressStateImplCopyWith<$Res>
    implements $RefreshProgressStateCopyWith<$Res> {
  factory _$$RefreshProgressStateImplCopyWith(
    _$RefreshProgressStateImpl value,
    $Res Function(_$RefreshProgressStateImpl) then,
  ) = __$$RefreshProgressStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String currentPhase,
    double progressPercent,
    String funPhrase,
    Duration? estimatedTimeRemaining,
  });
}

/// @nodoc
class __$$RefreshProgressStateImplCopyWithImpl<$Res>
    extends _$RefreshProgressStateCopyWithImpl<$Res, _$RefreshProgressStateImpl>
    implements _$$RefreshProgressStateImplCopyWith<$Res> {
  __$$RefreshProgressStateImplCopyWithImpl(
    _$RefreshProgressStateImpl _value,
    $Res Function(_$RefreshProgressStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RefreshProgressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPhase = null,
    Object? progressPercent = null,
    Object? funPhrase = null,
    Object? estimatedTimeRemaining = freezed,
  }) {
    return _then(
      _$RefreshProgressStateImpl(
        currentPhase: null == currentPhase
            ? _value.currentPhase
            : currentPhase // ignore: cast_nullable_to_non_nullable
                  as String,
        progressPercent: null == progressPercent
            ? _value.progressPercent
            : progressPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        funPhrase: null == funPhrase
            ? _value.funPhrase
            : funPhrase // ignore: cast_nullable_to_non_nullable
                  as String,
        estimatedTimeRemaining: freezed == estimatedTimeRemaining
            ? _value.estimatedTimeRemaining
            : estimatedTimeRemaining // ignore: cast_nullable_to_non_nullable
                  as Duration?,
      ),
    );
  }
}

/// @nodoc

class _$RefreshProgressStateImpl implements _RefreshProgressState {
  const _$RefreshProgressStateImpl({
    required this.currentPhase,
    required this.progressPercent,
    required this.funPhrase,
    this.estimatedTimeRemaining,
  });

  @override
  final String currentPhase;
  @override
  final double progressPercent;
  @override
  final String funPhrase;
  @override
  final Duration? estimatedTimeRemaining;

  @override
  String toString() {
    return 'RefreshProgressState(currentPhase: $currentPhase, progressPercent: $progressPercent, funPhrase: $funPhrase, estimatedTimeRemaining: $estimatedTimeRemaining)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshProgressStateImpl &&
            (identical(other.currentPhase, currentPhase) ||
                other.currentPhase == currentPhase) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.funPhrase, funPhrase) ||
                other.funPhrase == funPhrase) &&
            (identical(other.estimatedTimeRemaining, estimatedTimeRemaining) ||
                other.estimatedTimeRemaining == estimatedTimeRemaining));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentPhase,
    progressPercent,
    funPhrase,
    estimatedTimeRemaining,
  );

  /// Create a copy of RefreshProgressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshProgressStateImplCopyWith<_$RefreshProgressStateImpl>
  get copyWith =>
      __$$RefreshProgressStateImplCopyWithImpl<_$RefreshProgressStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RefreshProgressState implements RefreshProgressState {
  const factory _RefreshProgressState({
    required final String currentPhase,
    required final double progressPercent,
    required final String funPhrase,
    final Duration? estimatedTimeRemaining,
  }) = _$RefreshProgressStateImpl;

  @override
  String get currentPhase;
  @override
  double get progressPercent;
  @override
  String get funPhrase;
  @override
  Duration? get estimatedTimeRemaining;

  /// Create a copy of RefreshProgressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefreshProgressStateImplCopyWith<_$RefreshProgressStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
