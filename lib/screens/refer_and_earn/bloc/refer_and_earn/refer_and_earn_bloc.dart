import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/refer_and_earn/model/refer_and_earn_model.dart';

import '../../repo/refer_and_earn_repo.dart';
part 'refer_and_earn_event.dart';
part 'refer_and_earn_state.dart';

class ReferAndEarnBloc extends Bloc<ReferAndEarnEvent, ReferAndEarnState> {
  ReferAndEarnBloc() : super(ReferAndEarnInitial()) {
    on<FetchReferInfo>(_onFetchReferInfo);
  }

  final ReferAndEarnRepository _referAndEarnRepository = ReferAndEarnRepository();

  Future<void> _onFetchReferInfo(FetchReferInfo event, Emitter<ReferAndEarnState> emit) async {
    emit(ReferAndEarnLoading());
    try{
      final response = await _referAndEarnRepository.fetchReferAndEarn();

      if(response.success == true) {
        emit(
            ReferAndEarnLoaded(
            referAndEarnData: response.data!,
          )
        );
      } else if(response.success == false) {
        emit(ReferAndEarnFailed(error: response.message ?? 'Something went wrong'));
      }

    } catch (e) {
      emit(ReferAndEarnFailed(error: e.toString()));
    }
  }

}
