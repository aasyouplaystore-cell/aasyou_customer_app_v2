import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/my_orders/model/re_order_error_model.dart';
import '../../model/order_detail_model.dart';
import '../../repo/order_repo.dart';

part 're_order_event.dart';
part 're_order_state.dart';

class ReOrderBloc extends Bloc<ReOrderEvent, ReOrderState> {
  ReOrderBloc() : super(ReOrderInitial()) {
    on<ReOrderRequest>(_onReOrderRequest);
  }

  final OrderRepository repository = OrderRepository();

  Future<void> _onReOrderRequest(ReOrderRequest event, Emitter<ReOrderState> emit) async {
    emit(ReOrderInProgress());
    try{
      final orderDetailData = await repository.reOrderRequest(
        orderId: event.orderId,
      );
      if(orderDetailData['success'] == true) {
        emit(ReOrderedSuccess());
      } else {
        if(orderDetailData['success'] == false) {
          final failedItemsFromApi = (orderDetailData['data']['items'] as List?)
              ?.where((item) => item['success'] == false)
              .map((item) => FailedOrderItem.fromJson(item))
              .toList() ?? [];

          // Match with product names
          final List<String> userFriendlyErrors = [];

          for (var failed in failedItemsFromApi) {
            final orderItem = event.orderItems.firstWhereOrNull(
                  (item) => item.id == failed.orderItemId,
            );

            final productName = orderItem?.title ??
                orderItem?.product?.name ??
                "Unknown Product";

            userFriendlyErrors.add("$productName - ${failed.message}");
          }
          emit(ReOrderedFailed(
            errorList: userFriendlyErrors,
          ));
        }
        // emit(ReOrderedFailed(error: [orderDetailData['message'].toString()]));
      }
    }catch (e) {
      emit(ReOrderedFailed(errorList: [e.toString()]));
    }
  }

}
