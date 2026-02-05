// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'games_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GamesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(RefreshProgressState? progress) loading,
    required TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(RefreshProgressState? progress)? loading,
    TResult? Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(RefreshProgressState? progress)? loading,
    TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GamesInitial value) initial,
    required TResult Function(GamesLoading value) loading,
    required TResult Function(GamesLoaded value) loaded,
    required TResult Function(GamesError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GamesInitial value)? initial,
    TResult? Function(GamesLoading value)? loading,
    TResult? Function(GamesLoaded value)? loaded,
    TResult? Function(GamesError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GamesInitial value)? initial,
    TResult Function(GamesLoading value)? loading,
    TResult Function(GamesLoaded value)? loaded,
    TResult Function(GamesError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamesStateCopyWith<$Res> {
  factory $GamesStateCopyWith(
    GamesState value,
    $Res Function(GamesState) then,
  ) = _$GamesStateCopyWithImpl<$Res, GamesState>;
}

/// @nodoc
class _$GamesStateCopyWithImpl<$Res, $Val extends GamesState>
    implements $GamesStateCopyWith<$Res> {
  _$GamesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GamesInitialImplCopyWith<$Res> {
  factory _$$GamesInitialImplCopyWith(
    _$GamesInitialImpl value,
    $Res Function(_$GamesInitialImpl) then,
  ) = __$$GamesInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GamesInitialImplCopyWithImpl<$Res>
    extends _$GamesStateCopyWithImpl<$Res, _$GamesInitialImpl>
    implements _$$GamesInitialImplCopyWith<$Res> {
  __$$GamesInitialImplCopyWithImpl(
    _$GamesInitialImpl _value,
    $Res Function(_$GamesInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GamesInitialImpl extends GamesInitial {
  const _$GamesInitialImpl() : super._();

  @override
  String toString() {
    return 'GamesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GamesInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(RefreshProgressState? progress) loading,
    required TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(RefreshProgressState? progress)? loading,
    TResult? Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(RefreshProgressState? progress)? loading,
    TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
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
    required TResult Function(GamesInitial value) initial,
    required TResult Function(GamesLoading value) loading,
    required TResult Function(GamesLoaded value) loaded,
    required TResult Function(GamesError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GamesInitial value)? initial,
    TResult? Function(GamesLoading value)? loading,
    TResult? Function(GamesLoaded value)? loaded,
    TResult? Function(GamesError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GamesInitial value)? initial,
    TResult Function(GamesLoading value)? loading,
    TResult Function(GamesLoaded value)? loaded,
    TResult Function(GamesError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class GamesInitial extends GamesState {
  const factory GamesInitial() = _$GamesInitialImpl;
  const GamesInitial._() : super._();
}

/// @nodoc
abstract class _$$GamesLoadingImplCopyWith<$Res> {
  factory _$$GamesLoadingImplCopyWith(
    _$GamesLoadingImpl value,
    $Res Function(_$GamesLoadingImpl) then,
  ) = __$$GamesLoadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RefreshProgressState? progress});

  $RefreshProgressStateCopyWith<$Res>? get progress;
}

/// @nodoc
class __$$GamesLoadingImplCopyWithImpl<$Res>
    extends _$GamesStateCopyWithImpl<$Res, _$GamesLoadingImpl>
    implements _$$GamesLoadingImplCopyWith<$Res> {
  __$$GamesLoadingImplCopyWithImpl(
    _$GamesLoadingImpl _value,
    $Res Function(_$GamesLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? progress = freezed}) {
    return _then(
      _$GamesLoadingImpl(
        progress: freezed == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as RefreshProgressState?,
      ),
    );
  }

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RefreshProgressStateCopyWith<$Res>? get progress {
    if (_value.progress == null) {
      return null;
    }

    return $RefreshProgressStateCopyWith<$Res>(_value.progress!, (value) {
      return _then(_value.copyWith(progress: value));
    });
  }
}

/// @nodoc

class _$GamesLoadingImpl extends GamesLoading {
  const _$GamesLoadingImpl({this.progress = null}) : super._();

  @override
  @JsonKey()
  final RefreshProgressState? progress;

  @override
  String toString() {
    return 'GamesState.loading(progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamesLoadingImpl &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, progress);

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamesLoadingImplCopyWith<_$GamesLoadingImpl> get copyWith =>
      __$$GamesLoadingImplCopyWithImpl<_$GamesLoadingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(RefreshProgressState? progress) loading,
    required TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loading(progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(RefreshProgressState? progress)? loading,
    TResult? Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call(progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(RefreshProgressState? progress)? loading,
    TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GamesInitial value) initial,
    required TResult Function(GamesLoading value) loading,
    required TResult Function(GamesLoaded value) loaded,
    required TResult Function(GamesError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GamesInitial value)? initial,
    TResult? Function(GamesLoading value)? loading,
    TResult? Function(GamesLoaded value)? loaded,
    TResult? Function(GamesError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GamesInitial value)? initial,
    TResult Function(GamesLoading value)? loading,
    TResult Function(GamesLoaded value)? loaded,
    TResult Function(GamesError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class GamesLoading extends GamesState {
  const factory GamesLoading({final RefreshProgressState? progress}) =
      _$GamesLoadingImpl;
  const GamesLoading._() : super._();

  RefreshProgressState? get progress;

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamesLoadingImplCopyWith<_$GamesLoadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GamesLoadedImplCopyWith<$Res> {
  factory _$$GamesLoadedImplCopyWith(
    _$GamesLoadedImpl value,
    $Res Function(_$GamesLoadedImpl) then,
  ) = __$$GamesLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<Game> games,
    GameSource? filterSource,
    bool sortDescending,
    String? searchQuery,
    RefreshProgressState? refreshProgress,
    SortOption sortOption,
    GameTag? filterTag,
    DateTime? lastRefresh,
  });

  $RefreshProgressStateCopyWith<$Res>? get refreshProgress;
}

/// @nodoc
class __$$GamesLoadedImplCopyWithImpl<$Res>
    extends _$GamesStateCopyWithImpl<$Res, _$GamesLoadedImpl>
    implements _$$GamesLoadedImplCopyWith<$Res> {
  __$$GamesLoadedImplCopyWithImpl(
    _$GamesLoadedImpl _value,
    $Res Function(_$GamesLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? games = null,
    Object? filterSource = freezed,
    Object? sortDescending = null,
    Object? searchQuery = freezed,
    Object? refreshProgress = freezed,
    Object? sortOption = null,
    Object? filterTag = freezed,
    Object? lastRefresh = freezed,
  }) {
    return _then(
      _$GamesLoadedImpl(
        games: null == games
            ? _value._games
            : games // ignore: cast_nullable_to_non_nullable
                  as List<Game>,
        filterSource: freezed == filterSource
            ? _value.filterSource
            : filterSource // ignore: cast_nullable_to_non_nullable
                  as GameSource?,
        sortDescending: null == sortDescending
            ? _value.sortDescending
            : sortDescending // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchQuery: freezed == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String?,
        refreshProgress: freezed == refreshProgress
            ? _value.refreshProgress
            : refreshProgress // ignore: cast_nullable_to_non_nullable
                  as RefreshProgressState?,
        sortOption: null == sortOption
            ? _value.sortOption
            : sortOption // ignore: cast_nullable_to_non_nullable
                  as SortOption,
        filterTag: freezed == filterTag
            ? _value.filterTag
            : filterTag // ignore: cast_nullable_to_non_nullable
                  as GameTag?,
        lastRefresh: freezed == lastRefresh
            ? _value.lastRefresh
            : lastRefresh // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RefreshProgressStateCopyWith<$Res>? get refreshProgress {
    if (_value.refreshProgress == null) {
      return null;
    }

    return $RefreshProgressStateCopyWith<$Res>(_value.refreshProgress!, (
      value,
    ) {
      return _then(_value.copyWith(refreshProgress: value));
    });
  }
}

/// @nodoc

class _$GamesLoadedImpl extends GamesLoaded {
  const _$GamesLoadedImpl({
    required final List<Game> games,
    this.filterSource = null,
    this.sortDescending = true,
    this.searchQuery = null,
    this.refreshProgress = null,
    this.sortOption = SortOption.size,
    this.filterTag = null,
    this.lastRefresh = null,
  }) : _games = games,
       super._();

  final List<Game> _games;
  @override
  List<Game> get games {
    if (_games is EqualUnmodifiableListView) return _games;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_games);
  }

  @override
  @JsonKey()
  final GameSource? filterSource;
  @override
  @JsonKey()
  final bool sortDescending;
  @override
  @JsonKey()
  final String? searchQuery;
  @override
  @JsonKey()
  final RefreshProgressState? refreshProgress;
  @override
  @JsonKey()
  final SortOption sortOption;
  @override
  @JsonKey()
  final GameTag? filterTag;
  @override
  @JsonKey()
  final DateTime? lastRefresh;

  @override
  String toString() {
    return 'GamesState.loaded(games: $games, filterSource: $filterSource, sortDescending: $sortDescending, searchQuery: $searchQuery, refreshProgress: $refreshProgress, sortOption: $sortOption, filterTag: $filterTag, lastRefresh: $lastRefresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamesLoadedImpl &&
            const DeepCollectionEquality().equals(other._games, _games) &&
            (identical(other.filterSource, filterSource) ||
                other.filterSource == filterSource) &&
            (identical(other.sortDescending, sortDescending) ||
                other.sortDescending == sortDescending) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.refreshProgress, refreshProgress) ||
                other.refreshProgress == refreshProgress) &&
            (identical(other.sortOption, sortOption) ||
                other.sortOption == sortOption) &&
            (identical(other.filterTag, filterTag) ||
                other.filterTag == filterTag) &&
            (identical(other.lastRefresh, lastRefresh) ||
                other.lastRefresh == lastRefresh));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_games),
    filterSource,
    sortDescending,
    searchQuery,
    refreshProgress,
    sortOption,
    filterTag,
    lastRefresh,
  );

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamesLoadedImplCopyWith<_$GamesLoadedImpl> get copyWith =>
      __$$GamesLoadedImplCopyWithImpl<_$GamesLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(RefreshProgressState? progress) loading,
    required TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(
      games,
      filterSource,
      sortDescending,
      searchQuery,
      refreshProgress,
      sortOption,
      filterTag,
      lastRefresh,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(RefreshProgressState? progress)? loading,
    TResult? Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(
      games,
      filterSource,
      sortDescending,
      searchQuery,
      refreshProgress,
      sortOption,
      filterTag,
      lastRefresh,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(RefreshProgressState? progress)? loading,
    TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(
        games,
        filterSource,
        sortDescending,
        searchQuery,
        refreshProgress,
        sortOption,
        filterTag,
        lastRefresh,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GamesInitial value) initial,
    required TResult Function(GamesLoading value) loading,
    required TResult Function(GamesLoaded value) loaded,
    required TResult Function(GamesError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GamesInitial value)? initial,
    TResult? Function(GamesLoading value)? loading,
    TResult? Function(GamesLoaded value)? loaded,
    TResult? Function(GamesError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GamesInitial value)? initial,
    TResult Function(GamesLoading value)? loading,
    TResult Function(GamesLoaded value)? loaded,
    TResult Function(GamesError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class GamesLoaded extends GamesState {
  const factory GamesLoaded({
    required final List<Game> games,
    final GameSource? filterSource,
    final bool sortDescending,
    final String? searchQuery,
    final RefreshProgressState? refreshProgress,
    final SortOption sortOption,
    final GameTag? filterTag,
    final DateTime? lastRefresh,
  }) = _$GamesLoadedImpl;
  const GamesLoaded._() : super._();

  List<Game> get games;
  GameSource? get filterSource;
  bool get sortDescending;
  String? get searchQuery;
  RefreshProgressState? get refreshProgress;
  SortOption get sortOption;
  GameTag? get filterTag;
  DateTime? get lastRefresh;

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamesLoadedImplCopyWith<_$GamesLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GamesErrorImplCopyWith<$Res> {
  factory _$$GamesErrorImplCopyWith(
    _$GamesErrorImpl value,
    $Res Function(_$GamesErrorImpl) then,
  ) = __$$GamesErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$GamesErrorImplCopyWithImpl<$Res>
    extends _$GamesStateCopyWithImpl<$Res, _$GamesErrorImpl>
    implements _$$GamesErrorImplCopyWith<$Res> {
  __$$GamesErrorImplCopyWithImpl(
    _$GamesErrorImpl _value,
    $Res Function(_$GamesErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$GamesErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GamesErrorImpl extends GamesError {
  const _$GamesErrorImpl(this.message) : super._();

  @override
  final String message;

  @override
  String toString() {
    return 'GamesState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamesErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamesErrorImplCopyWith<_$GamesErrorImpl> get copyWith =>
      __$$GamesErrorImplCopyWithImpl<_$GamesErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(RefreshProgressState? progress) loading,
    required TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(RefreshProgressState? progress)? loading,
    TResult? Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(RefreshProgressState? progress)? loading,
    TResult Function(
      List<Game> games,
      GameSource? filterSource,
      bool sortDescending,
      String? searchQuery,
      RefreshProgressState? refreshProgress,
      SortOption sortOption,
      GameTag? filterTag,
      DateTime? lastRefresh,
    )?
    loaded,
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
    required TResult Function(GamesInitial value) initial,
    required TResult Function(GamesLoading value) loading,
    required TResult Function(GamesLoaded value) loaded,
    required TResult Function(GamesError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GamesInitial value)? initial,
    TResult? Function(GamesLoading value)? loading,
    TResult? Function(GamesLoaded value)? loaded,
    TResult? Function(GamesError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GamesInitial value)? initial,
    TResult Function(GamesLoading value)? loading,
    TResult Function(GamesLoaded value)? loaded,
    TResult Function(GamesError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class GamesError extends GamesState {
  const factory GamesError(final String message) = _$GamesErrorImpl;
  const GamesError._() : super._();

  String get message;

  /// Create a copy of GamesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamesErrorImplCopyWith<_$GamesErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
