import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_size_manager/core/services/update_service.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  final UpdateService _updateService;

  UpdateCubit(this._updateService) : super(const UpdateState.initial());

  Future<void> checkForUpdates() async {
    emit(const UpdateState.checking());
    try {
      final info = await _updateService.checkForUpdates();
      if (info.hasUpdate) {
        emit(UpdateState.available(info));
      } else {
        emit(const UpdateState.initial());
      }
    } catch (e) {
      emit(UpdateState.error(e.toString()));
    }
  }

  Future<void> downloadUpdate(String url) async {
    emit(const UpdateState.downloading(0));
    try {
      final file = await _updateService.downloadUpdate(url, (progress) {
        emit(UpdateState.downloading(progress));
      });
      emit(UpdateState.readyToInstall(file));

      // Auto-install or wait?
      // Plan said: "Watch it download, close, and reopen".
      // Usually we might want to ask confirmation "Ready to restart?".
      // But for "readyToInstall", the UI can show "Restart to Update" button.
    } catch (e) {
      emit(UpdateState.error(e.toString()));
    }
  }

  Future<void> applyUpdate(File zipFile) async {
    try {
      await _updateService.applyUpdate(
        zipFile,
        onProgress: (message, progress) {
          emit(UpdateState.installing(message, progress));
        },
      );
    } catch (e) {
      emit(UpdateState.error(e.toString()));
    }
  }
}
