import 'package:equatable/equatable.dart';

abstract class SendEmailVerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Asks the backend to send a verification link to [email].
class RequestSendEmailVerification extends SendEmailVerificationEvent {
  final String email;

  RequestSendEmailVerification({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Returns the bloc to `Initial` so the UI can show the primary "Send".
class ResetSendEmailVerification extends SendEmailVerificationEvent {}
