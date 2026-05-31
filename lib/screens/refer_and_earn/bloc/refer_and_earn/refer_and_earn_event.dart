part of 'refer_and_earn_bloc.dart';

abstract class ReferAndEarnEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchReferInfo extends ReferAndEarnEvent {}
