import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/delivery_zone_model.dart';
import '../../repo/delivery_zone_repo.dart';

part 'delivery_zone_event.dart';
part 'delivery_zone_state.dart';

class DeliveryZoneBloc extends Bloc<DeliveryZoneEvent, DeliveryZoneState> {
  DeliveryZoneBloc() : super(DeliveryZoneInitial()) {
    on<FetchDeliveryZones>(_onFetchDeliveryZones);
    on<LoadMoreDeliveryZones>(_onLoadMoreDeliveryZones);
  }

  int currentPage = 1;
  int perPage = 15;
  bool _hasReachedMax = false;
  bool isLoadingMore = false;
  final DeliveryZoneRepository repository = DeliveryZoneRepository();

  Future<void> _onFetchDeliveryZones(
      FetchDeliveryZones event, Emitter<DeliveryZoneState> emit) async {
    emit(DeliveryZoneLoading());
    try {
      currentPage = event.page;
      perPage = event.perPage;
      _hasReachedMax = false;
      isLoadingMore = false;

      final response = await repository.fetchDeliveryZone(
        page: currentPage,
        perPage: perPage,
        searchQuery: event.searchQuery,
      );

      final deliveryZoneData = List<DeliveryZoneData>.from(response['data']
              ['data']
          .map((data) => DeliveryZoneData.fromJson(data)));

      final currentPageNum =
          int.tryParse(response['data']['current_page'].toString()) ?? 1;
      final lastPageNum =
          int.tryParse(response['data']['last_page'].toString()) ?? 1;

      _hasReachedMax =
          currentPageNum >= lastPageNum || deliveryZoneData.length < perPage;

      if (response['success'] == true) {
        emit(DeliveryZoneLoaded(
          deliveryZoneData: deliveryZoneData,
          hasReachedMax: _hasReachedMax,
        ));
      } else {
        emit(DeliveryZoneFailed(error: response['message']));
      }
    } catch (e) {
      emit(DeliveryZoneFailed(error: e.toString()));
    }
  }

  Future<void> _onLoadMoreDeliveryZones(
      LoadMoreDeliveryZones event, Emitter<DeliveryZoneState> emit) async {
    if (isLoadingMore || _hasReachedMax) return;

    final currentState = state;
    if (currentState is DeliveryZoneLoaded) {
      isLoadingMore = true;
      try {
        currentPage += 1;

        final response = await repository.fetchDeliveryZone(
          page: currentPage,
          perPage: event.perPage,
          searchQuery: event.searchQuery,
        );

        final newDeliveryZoneData = List<DeliveryZoneData>.from(response['data']
                ['data']
            .map((data) => DeliveryZoneData.fromJson(data)));

        final currentPageNum =
            int.tryParse(response['data']['current_page'].toString()) ??
                currentPage;
        final lastPageNum =
            int.tryParse(response['data']['last_page'].toString()) ?? 1;

        _hasReachedMax = currentPageNum >= lastPageNum ||
            newDeliveryZoneData.length < event.perPage;

        final updatedDeliveryZoneData =
            List<DeliveryZoneData>.from(currentState.deliveryZoneData);

        // Add only unique zones
        for (final newZone in newDeliveryZoneData) {
          if (!updatedDeliveryZoneData
              .any((existing) => existing.id == newZone.id)) {
            updatedDeliveryZoneData.add(newZone);
          }
        }

        if (response['success'] == true) {
          emit(DeliveryZoneLoaded(
            deliveryZoneData: updatedDeliveryZoneData,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          currentPage -= 1;
          emit(DeliveryZoneFailed(error: response['message']));
        }
      } catch (e) {
        currentPage -= 1;
      } finally {
        isLoadingMore = false;
      }
    }
  }
}
