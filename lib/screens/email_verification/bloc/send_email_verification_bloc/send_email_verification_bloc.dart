import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/email_verification/repo/email_verification_repo.dart';

import 'send_email_verification_event.dart';
import 'send_email_verification_state.dart';

class SendEmailVerificationBloc
    extends Bloc<SendEmailVerificationEvent, SendEmailVerificationState> {
  final EmailVerificationRepository _repository;

  SendEmailVerificationBloc({EmailVerificationRepository? repository})
      : _repository = repository ?? EmailVerificationRepository(),
        super(SendEmailVerificationInitial()) {
    on<RequestSendEmailVerification>(_onRequest);
    on<ResetSendEmailVerification>(_onReset);
  }

  Future<void> _onRequest(
    RequestSendEmailVerification event,
    Emitter<SendEmailVerificationState> emit,
  ) async {
    emit(SendEmailVerificationLoading());
    try {
      final response =
          await _repository.sendVerificationEmail(email: event.email);
      emit(SendEmailVerificationSuccess(
        message: response.message ?? 'Verification email sent',
      ));
    } catch (e) {
      emit(SendEmailVerificationError(error: e.toString()));
    }
  }

  void _onReset(
    ResetSendEmailVerification event,
    Emitter<SendEmailVerificationState> emit,
  ) {
    emit(SendEmailVerificationInitial());
  }
}
