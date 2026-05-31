import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/api_routes.dart';
import '../../config/helper.dart';
import '../../config/settings_data_instance.dart';
import '../../model/settings_model/settings_model.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<FetchSettingsData>(_onFetchSettingsData);
  }

  Future<void> _onFetchSettingsData(FetchSettingsData event, Emitter<SettingsState> emit) async {
    try{
      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.settingsApi, {}, context: event.context);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final settingsResponse = SettingsResponse.fromJson(response.data);
        SettingsData().setSettingsData(settingsResponse.data);
        emit(SettingsLoaded(settingsResponse: settingsResponse));
      } else if(response.data['maintenance']){
        emit(MaintenanceModeEnabled(maintenanceModeMessage: response.data['message']));
      }
    }catch(e, stackTrace){
      log(' Stack Trace Settings Data ${stackTrace.toString()}');
      emit(SettingsFailure(error: e.toString()));
    }
  }
}
