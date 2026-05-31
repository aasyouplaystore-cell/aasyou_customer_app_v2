part of 'apply_referral_bloc.dart';

sealed class ApplyReferralEvent extends Equatable {
  const ApplyReferralEvent();
}

/// Apply (or explicitly skip with [code] = null/empty) a referral code.
final class ApplyReferralRequest extends ApplyReferralEvent {
  final String? code;

  const ApplyReferralRequest({this.code});

  @override
  List<Object?> get props => [code];
}
