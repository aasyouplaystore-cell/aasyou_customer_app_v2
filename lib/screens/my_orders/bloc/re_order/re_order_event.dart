part of 're_order_bloc.dart';

abstract class ReOrderEvent extends Equatable {}

class ReOrderRequest extends ReOrderEvent {
  final int orderId;
  final List<OrderItems> orderItems;

  ReOrderRequest({
    required this.orderId,
    required this.orderItems
  });
  @override
  // TODO: implement props
  List<Object?> get props => [orderId, orderItems];
}