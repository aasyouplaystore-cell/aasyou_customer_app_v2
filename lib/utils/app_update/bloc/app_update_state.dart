import 'package:equatable/equatable.dart';
import '../model/update_config.dart';

abstract class AppUpdateState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial — nothing fetched yet
class AppUpdateInitial extends AppUpdateState {}

/// API call in progress
class AppUpdateLoading extends AppUpdateState {}

/// API responded — config ready for splash to act on
class AppUpdateConfigLoaded extends AppUpdateState {
  final UpdateConfig config;
  final bool isForced;
  final bool isUpdateAvailable;

  AppUpdateConfigLoaded({
    required this.config,
    required this.isForced,
    required this.isUpdateAvailable,
  });

  @override
  List<Object?> get props => [config, isForced, isUpdateAvailable];
}

/// API fetch failed — gate resolves, user proceeds normally
class AppUpdateFailed extends AppUpdateState {
  final String error;

  AppUpdateFailed({required this.error});

  @override
  List<Object?> get props => [error];
}