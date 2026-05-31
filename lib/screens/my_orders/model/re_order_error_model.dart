class FailedOrderItem {
  final int orderItemId;
  final String message;

  FailedOrderItem({
    required this.orderItemId,
    required this.message,
  });

  factory FailedOrderItem.fromJson(Map<String, dynamic> json) {
    return FailedOrderItem(
      orderItemId: json['order_item_id'] ?? 0,
      message: json['message'] ?? 'Unknown error',
    );
  }
}