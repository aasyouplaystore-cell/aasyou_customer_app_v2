import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/auth/repo/auth_repo.dart';

part 'apply_referral_event.dart';
part 'apply_referral_state.dart';

class ApplyReferralBloc
    extends Bloc<ApplyReferralEvent, ApplyReferralState> {
  final AuthRepository _repository = AuthRepository();

  ApplyReferralBloc() : super(ApplyReferralInitial()) {
    on<ApplyReferralRequest>(_onApplyReferral);
  }

  Future<void> _onApplyReferral(
      ApplyReferralRequest event, Emitter<ApplyReferralState> emit) async {
    emit(ApplyReferralLoading());
    try {
      final response = await _repository.applyReferral(code: event.code);
      final String message = response['message']?.toString() ?? '';
      log('Apply referral success: $message');
      emit(ApplyReferralSuccess(message: message));
    } catch (e) {
      emit(ApplyReferralFailed(message: e.toString()));
    }
  }
}
