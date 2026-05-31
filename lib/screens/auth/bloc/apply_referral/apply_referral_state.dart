part of 'apply_referral_bloc.dart';

sealed class ApplyReferralState extends Equatable {
  const ApplyReferralState();

  @override
  List<Object> get props => [];
}

final class ApplyReferralInitial extends ApplyReferralState {}

final class ApplyReferralLoading extends ApplyReferralState {}

final class ApplyReferralSuccess extends ApplyReferralState {
  final String message;

  const ApplyReferralSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

final class ApplyReferralFailed extends ApplyReferralState {
  final String message;

  const ApplyReferralFailed({required this.message});

  @override
  List<Object> get props => [message];
}
