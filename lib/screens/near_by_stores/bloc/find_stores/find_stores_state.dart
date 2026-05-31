part of 'find_stores_bloc.dart';

abstract class FindStoresState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FindStoresInitial extends FindStoresState {}

class FindStoresLoading extends FindStoresState {}

class FindStoresLoaded extends FindStoresState {
  final List<StoreData> storeList;

  FindStoresLoaded({required this.storeList});

  @override
  // TODO: implement props
  List<Object?> get props => [storeList];
}

class FindStoresFailed extends FindStoresState {
  final String error;

  FindStoresFailed({required  this.error});

  @override
  // TODO: implement props
  List<Object?> get props => [error];
}
