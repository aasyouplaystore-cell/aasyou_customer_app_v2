import 'package:equatable/equatable.dart';

abstract class SendEmailVerificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendEmailVerificationInitial extends SendEmailVerificationState {}

class SendEmailVerificationLoading extends SendEmailVerificationState {}

class SendEmailVerificationSuccess extends SendEmailVerificationState {
  final String message;

  SendEmailVerificationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SendEmailVerificationError extends SendEmailVerificationState {
  final String error;

  SendEmailVerificationError({required this.error});

  @override
  List<Object?> get props => [error];
}
