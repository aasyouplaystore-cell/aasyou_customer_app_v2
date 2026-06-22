import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/settings/web_settings/bloc/web_settings_event.dart';
import 'package:aasyou/screens/settings/web_settings/bloc/web_settings_state.dart';
import 'package:aasyou/screens/settings/web_settings/repo/web_settings_repo.dart';

class WebSettingsBloc extends Bloc<WebSettingsEvent, WebSettingsState> {
  WebSettingsBloc() : super(WebSettingsInitial()) {
    on<WebSettingsRequested>(_onRequested);
  }

  final WebSettingsRepository repository = WebSettingsRepository();

  Future<void> _onRequested(
    WebSettingsRequested event,
    Emitter<WebSettingsState> emit,
  ) async {
    emit(WebSettingsLoading());
    try {
      final settings = await repository.fetchWebSettings();
      emit(WebSettingsLoaded(data: settings));
    } catch (e) {
      emit(WebSettingsFailed(error: e.toString()));
    }
  }
}
