import 'package:hive_flutter/hive_flutter.dart';

part 'cart_addon.g.dart';

/// A single addon item snapshot attached to a [UserCart] row.
@HiveType(typeId: 12)
class CartAddon {
  @HiveField(0)
  final int addonGroupId;

  @HiveField(1)
  final int addonItemId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final double price;

  const CartAddon({
    required this.addonGroupId,
    required this.addonItemId,
    required this.title,
    required this.price,
  });

  factory CartAddon.fromJson(Map<String, dynamic> json) {
    return CartAddon(
      addonGroupId: (json['addon_group_id'] as num?)?.toInt() ?? 0,
      addonItemId: (json['addon_item_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'addon_group_id': addonGroupId,
        'addon_item_id': addonItemId,
        'title': title,
        'price': price,
      };

  /// Remote-payload shape accepted by the add-to-cart endpoint.
  Map<String, int> toPayloadJson() => {
        'addon_group_id': addonGroupId,
        'addon_item_id': addonItemId,
      };

  CartAddon copyWith({
    int? addonGroupId,
    int? addonItemId,
    String? title,
    double? price,
  }) {
    return CartAddon(
      addonGroupId: addonGroupId ?? this.addonGroupId,
      addonItemId: addonItemId ?? this.addonItemId,
      title: title ?? this.title,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartAddon &&
        other.addonGroupId == addonGroupId &&
        other.addonItemId == addonItemId;
  }

  @override
  int get hashCode => Object.hash(addonGroupId, addonItemId);
}
