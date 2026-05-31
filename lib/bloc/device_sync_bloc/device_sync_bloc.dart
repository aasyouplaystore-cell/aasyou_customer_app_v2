import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/config/api_routes.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/notification_service.dart';

part 'device_sync_event.dart';
part 'device_sync_state.dart';

class DeviceSyncBloc extends Bloc<DeviceSyncEvent, DeviceSyncState> {
  DeviceSyncBloc() : super(DeviceSyncInitial()) {
    on<SyncDevice>(_onSyncDevice);
  }

  Future<void> _onSyncDevice(SyncDevice event, Emitter<DeviceSyncState> emit) async {
    emit(DeviceSyncLoading());
    try {
      final previousFcm = Global.userData?.fcm ?? '';
      final newFcm = await getFCMToken() ?? '';
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.syncDeviceApi,
        {
          'fcm_token': newFcm,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'previous_token': previousFcm,
          'role_type': event.roleType,
        },
      );
      if (response.statusCode == 200 && response.data['success']) {
        final currentUser = Global.userData;
        if (currentUser != null && newFcm.isNotEmpty) {
          await Global.setUserData(currentUser.copyWith(fcm: newFcm));
        }
        emit(DeviceSyncSuccess());
      } else {
        emit(DeviceSyncFailure(error: response.data['message']));
      }
    } catch (e) {
      emit(DeviceSyncFailure(error: e.toString()));
    }
  }
}
