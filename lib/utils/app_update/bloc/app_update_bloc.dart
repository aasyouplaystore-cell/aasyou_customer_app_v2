import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/app_version_repository.dart';
import 'app_update_event.dart';
import 'app_update_state.dart';
import '../model/update_config.dart';

class AppUpdateBloc extends Bloc<AppUpdateEvent, AppUpdateState> {
  final AppVersionRepository _repository;

  AppUpdateBloc({
    AppVersionRepository? repository,
  })  : _repository = repository ?? AppVersionRepository(),
        super(AppUpdateInitial()) {
    on<CheckAppUpdate>(_onCheckAppUpdate);
  }

  Future<void> _onCheckAppUpdate(
      CheckAppUpdate event, Emitter<AppUpdateState> emit) async {
    emit(AppUpdateLoading());
    try {
      final config = await _repository.fetchUpdateConfig();
      log('[AppUpdateBloc] config status: ${config.status}');

      if (config.status == UpdateStatus.upToDate) {
        emit(AppUpdateConfigLoaded(
          config: config,
          isForced: false,
          isUpdateAvailable: false,
        ));
      } else {
        emit(AppUpdateConfigLoaded(
          config: config,
          isForced: config.status == UpdateStatus.forceUpdate,
          isUpdateAvailable: true,
        ));
      }
    } catch (e) {
      log('[AppUpdateBloc] Error: $e');
      emit(AppUpdateFailed(error: e.toString()));
    }
  }
}