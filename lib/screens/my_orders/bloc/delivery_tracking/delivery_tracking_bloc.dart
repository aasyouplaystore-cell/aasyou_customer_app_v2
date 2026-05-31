import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/delivery_tracking_model.dart';
import '../../repo/order_repo.dart';

part 'delivery_tracking_event.dart';
part 'delivery_tracking_state.dart';

class DeliveryTrackingBloc
    extends Bloc<DeliveryTrackingEvent, DeliveryTrackingState> {
  DeliveryTrackingBloc() : super(DeliveryTrackingInitial()) {
    on<FetchDeliveryTracking>(_onFetchDeliveryTracking);
  }

  final OrderRepository repository = OrderRepository();

  Future<void> _onFetchDeliveryTracking(
    FetchDeliveryTracking event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    emit(DeliveryTrackingLoading());
    try {
      final tracking =
          await repository.getDeliveryTracking(orderSlug: event.orderSlug);
      log('Ordder Delivered 1 ${tracking == null}');
      log('Ordder Delivered 1 ${tracking!.success}');
      log('Ordder Delivered 2 ${tracking.data?.order?.slug}');
      log('Ordder Delivered 3 ${tracking.data?.route?.routeDetails.first.address}');
      final isDeliveredMessage =
          tracking.message?.toLowerCase().contains('delivered') ?? false;

      if (tracking.success == true ||
          (tracking.data?.order != null && isDeliveredMessage)) {
        emit(DeliveryTrackingLoaded(
          tracking: tracking,
          deliveryBoyInfo: tracking.data?.deliveryBoys ?? [],
          route: tracking.data?.route ?? TrackingRoute(),
          order: tracking.data?.order ?? TrackedOrder(),
          message: tracking.message ?? '',
        ));
      } else {
        emit(DeliveryTrackingFailed(
          error: tracking.message ?? 'Failed to load delivery tracking',
        ));
      }
    } catch (e) {
      emit(DeliveryTrackingFailed(error: e.toString()));
    }
  }
}
