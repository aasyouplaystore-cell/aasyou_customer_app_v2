part of 'device_sync_bloc.dart';

abstract class DeviceSyncState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class DeviceSyncInitial extends DeviceSyncState {}

class DeviceSyncLoading extends DeviceSyncState {}

class DeviceSyncSuccess extends DeviceSyncState {}

class DeviceSyncFailure extends DeviceSyncState {
  final String error;
  DeviceSyncFailure({required this.error});
  @override
  // TODO: implement props
  List<Object?> get props => [error];
}
