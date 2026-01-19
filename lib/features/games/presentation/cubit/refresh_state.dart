import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_state.freezed.dart';

@freezed
class RefreshProgressState with _$RefreshProgressState {
  const factory RefreshProgressState({
    required String currentPhase,
    required double progressPercent,
    required String funPhrase,
    Duration? estimatedTimeRemaining,
  }) = _RefreshProgressState;
}
