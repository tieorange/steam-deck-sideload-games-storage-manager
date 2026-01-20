import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:game_size_manager/core/services/update_service.dart';

part 'update_state.freezed.dart';

@freezed
class UpdateState with _$UpdateState {
  const factory UpdateState.initial() = UpdateInitial;
  const factory UpdateState.checking() = UpdateChecking;
  const factory UpdateState.available(UpdateInfo info) = UpdateAvailable;
  const factory UpdateState.downloading(double progress) = UpdateDownloading;
  const factory UpdateState.installing(String message, double progress) = UpdateInstalling;
  const factory UpdateState.readyToInstall(File zipFile) = UpdateReadyToInstall;
  const factory UpdateState.error(String message) = UpdateError;
}
