import 'package:equatable/equatable.dart';
import '../../../../config/payment_config.dart';
import '../../../address_list_page/model/get_address_list_model.dart';
import '../../widgets/delivery_type_widget.dart';

/// Fulfillment mode for the cart: home delivery vs in-store self-pickup.
/// Declared here (state layer) so both cart_ui_event.dart and cart_ui_bloc.dart
/// can import a single canonical definition. May be relocated to a dedicated
/// widget/model file in a follow-up patch once FulfillmentModeWidget lands.
enum FulfillmentMode { delivery, selfPickup }

class CartUIState extends Equatable {
  final AddressListData? selectedAddress;
  final DeliveryType selectedDeliveryType;
  final FulfillmentMode selectedFulfillmentMode;
  final bool useWallet;
  final bool isCartLoading;
  final bool isWalletLoading;
  final bool isWholePageProgress;
  final double totalAmount;

  final String? selectedPaymentMethod;
  final PaymentMethodType? selectedPaymentMethodType;

  const CartUIState({
    this.selectedAddress,
    this.selectedPaymentMethod,
    this.selectedPaymentMethodType,
    this.selectedDeliveryType = DeliveryType.regular,
    this.selectedFulfillmentMode = FulfillmentMode.delivery,
    this.useWallet = false,
    this.isCartLoading = false,
    this.isWalletLoading = false,
    this.isWholePageProgress = false,
    this.totalAmount = 0.0,
  });

  CartUIState copyWith({
    AddressListData? selectedAddress,
    DeliveryType? selectedDeliveryType,
    FulfillmentMode? selectedFulfillmentMode,
    bool? useWallet,
    bool? isCartLoading,
    bool? isWalletLoading,
    bool? isWholePageProgress,
    double? totalAmount,
    String? selectedPaymentMethod,
    PaymentMethodType? selectedPaymentMethodType,
  }) {
    return CartUIState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedDeliveryType:
      selectedDeliveryType ?? this.selectedDeliveryType,
      selectedFulfillmentMode:
      selectedFulfillmentMode ?? this.selectedFulfillmentMode,
      useWallet: useWallet ?? this.useWallet,
      isCartLoading: isCartLoading ?? this.isCartLoading,
      isWalletLoading: isWalletLoading ?? this.isWalletLoading,
      isWholePageProgress:
      isWholePageProgress ?? this.isWholePageProgress,
      totalAmount: totalAmount ?? this.totalAmount,
      selectedPaymentMethod:
      selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedPaymentMethodType:
      selectedPaymentMethodType ?? this.selectedPaymentMethodType,
    );
  }

  @override
  List<Object?> get props => [
    selectedAddress,
    selectedDeliveryType,
    selectedFulfillmentMode,
    useWallet,
    isCartLoading,
    isWalletLoading,
    isWholePageProgress,
    totalAmount,
    selectedPaymentMethod,
    selectedPaymentMethodType,
  ];
}
