import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/near_by_store_model.dart';
import '../../repo/near_by_store_repo.dart';

part 'find_stores_event.dart';
part 'find_stores_state.dart';

class FindStoresBloc extends Bloc<FindStoresEvent, FindStoresState> {
  FindStoresBloc() : super(FindStoresInitial()) {
    on<FindStoresRequest>(_onFindStoresRequest);
  }

  final NearByStoreRepo repository = NearByStoreRepo();

  Future<void> _onFindStoresRequest(FindStoresRequest event, Emitter<FindStoresState> emit) async {
    emit(FindStoresLoading());
    try{
      final response = await repository.findStoresReq(
        neLat: event.neLat,
        neLng: event.neLng,
        swLat: event.swLat,
        swLng: event.swLng,
        userLat: event.userLat,
        userLng: event.userLng,
      );

      List<StoreData> items = List<StoreData>.from(response['data']['stores'].map((data) => StoreData.fromJson(data)));

      if(response['data']  != null) {
        emit(FindStoresLoaded(storeList: items));
      } else {
        emit(FindStoresFailed(error: response['message'].toString()));
      }

    } catch(e) {
      emit(FindStoresFailed(error: e.toString()));
    }
  }
}
