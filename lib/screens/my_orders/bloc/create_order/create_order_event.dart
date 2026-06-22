part of 'create_order_bloc.dart';

abstract class CreateOrderEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CreateOrderRequest extends CreateOrderEvent {
  final String paymentType;
  final String? promoCode;
  final String? giftCard;
  final int addressId;
  final bool? rushDelivery;
  final bool? useWallet;
  final String? orderNote;
  final Map<String, dynamic>? paymentDetails;
  final Map<int, List<CartItemAttachment>>? attachments;
  // Self-pickup: 'delivery' (default) or 'self_pickup'. Threaded into the
  // create-order POST body so the backend's OrderService::createOrderFromCart
  // can branch on fulfillment mode.
  final String? deliveryMode;

  CreateOrderRequest({
    required this.paymentType,
    this.promoCode,
    this.giftCard,
    required this.addressId,
    this.rushDelivery,
    this.useWallet,
    this.orderNote,
    this.paymentDetails,
    this.attachments,
    this.deliveryMode,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    paymentType,
    promoCode,
    giftCard,
    addressId,
    rushDelivery,
    useWallet,
    orderNote,
    paymentDetails,
    attachments,
    deliveryMode,
  ];
}
