import 'package:equatable/equatable.dart';

abstract class WebSettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Fired on app start to load the home-section visibility toggles.
class WebSettingsRequested extends WebSettingsEvent {}
