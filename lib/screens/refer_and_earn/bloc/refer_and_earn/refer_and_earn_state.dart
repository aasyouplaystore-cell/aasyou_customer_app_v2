part of 'refer_and_earn_bloc.dart';

abstract class ReferAndEarnState extends Equatable {
  const ReferAndEarnState();

  @override
  List<Object> get props => [];
}

class ReferAndEarnInitial extends ReferAndEarnState {}

class ReferAndEarnLoading extends ReferAndEarnState {}

class ReferAndEarnLoaded extends ReferAndEarnState {
  final ReferAndEarnData referAndEarnData;

  const ReferAndEarnLoaded({required this.referAndEarnData});

  @override
  List<Object> get props => [referAndEarnData];
}

class ReferAndEarnFailed extends ReferAndEarnState {
  final String error;

  const ReferAndEarnFailed({required this.error});

  @override
  List<Object> get props => [error];
}
