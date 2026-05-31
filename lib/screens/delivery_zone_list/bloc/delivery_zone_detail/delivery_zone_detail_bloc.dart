import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/delivery_zone_list/model/delivery_zone_detail_model.dart';
import '../../repo/delivery_zone_repo.dart';

part 'delivery_zone_detail_event.dart';
part 'delivery_zone_detail_state.dart';

class DeliveryZoneDetailBloc extends Bloc<DeliveryZoneDetailEvent, DeliveryZoneDetailState> {
  DeliveryZoneDetailBloc() : super(DeliveryZoneDetailInitial()) {
    on<FetchDeliveryZoneDetail>(_onFetchDeliveryZoneDetail);
  }

  final DeliveryZoneRepository repository = DeliveryZoneRepository();


  Future<void> _onFetchDeliveryZoneDetail (FetchDeliveryZoneDetail event, Emitter<DeliveryZoneDetailState> emit) async {
    emit(DeliveryZoneDetailLoading());
    try{
      final response = await repository.fetchDeliveryZoneDetail(deliveryZoneId: event.zoneId);

      if(response.first.success == true && response.first.data != null) {
        emit(DeliveryZoneDetailLoaded(deliveryZoneDetail: response.first.data!));
      } else {
        emit(DeliveryZoneDetailFailed(error: response.first.message ?? 'Failed to fetch zone detail'));
      }
    }catch(e) {
      emit(DeliveryZoneDetailFailed(error: e.toString()));
    }
  }
}
