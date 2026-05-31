import 'package:hive_flutter/hive_flutter.dart';
import 'cart_addon.dart';
import 'cart_sync_action.dart';
part 'user_cart.g.dart';

@HiveType(typeId: 10)
class UserCart extends HiveObject {
  /// 🔑 Identity
  @HiveField(0)
  final String productId;

  /// 🧩 Variant (VERY IMPORTANT).
  @HiveField(1)
  final String variantId;

  @HiveField(2)
  final String variantName;

  /// 🏪 Vendor / Store
  @HiveField(3)
  final String vendorId;

  /// 🧾 UI
  @HiveField(4)
  final String name;

  @HiveField(5)
  final String image;

  /// 💰 Pricing (variant based — addon subtotal is NOT baked in here.
  @HiveField(6)
  double price;

  @HiveField(7)
  double originalPrice;

  /// 📦 Quantity
  @HiveField(8)
  int quantity;

  @HiveField(9)
  int minQty;

  @HiveField(10)
  final int maxQty;

  /// 🚦 Status
  @HiveField(11)
  final bool isOutOfStock;

  /// 🔄 Sync helpers
  @HiveField(12)
  final bool isSynced;

  @HiveField(13)
  DateTime updatedAt;

  @HiveField(14)
  int? serverCartItemId;

  /// 🔄 Sync
  @HiveField(15)
  CartSyncAction syncAction;

  /// 🧂 Selected addons (snapshotted at add-time).
  @HiveField(16)
  final List<CartAddon> addons;

  UserCart({
    required this.productId,
    required this.variantId,
    required this.variantName,
    required this.vendorId,
    required this.name,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.minQty,
    required this.maxQty,
    required this.isOutOfStock,
    required this.isSynced,
    required this.updatedAt,
    this.serverCartItemId,
    required this.syncAction,
    this.addons = const [],
  });

  /// 🧠 UNIQUE KEY = productId + variantId (+ stable sorted addon item.
  String get cartKey {
    if (addons.isEmpty) return '${productId}_$variantId';
    final sortedIds = addons.map((a) => a.addonItemId).toList()..sort();
    return '${productId}_${variantId}_${sortedIds.join('-')}';
  }

  /// Sum of all selected addon unit prices (per 1 quantity).
  double get addonsTotal {
    if (addons.isEmpty) return 0.0;
    double total = 0.0;
    for (final a in addons) {
      total += a.price;
    }
    return total;
  }

  UserCart copyWith({
    int? quantity,
    bool? isSynced,
    bool? isOutOfStock,
    Object? serverCartItemId = _undefined,
    CartSyncAction? syncAction,
    List<CartAddon>? addons,
  }) {
    return UserCart(
      productId: productId,
      variantId: variantId,
      variantName: variantName,
      vendorId: vendorId,
      name: name,
      image: image,
      price: price,
      originalPrice: originalPrice,
      quantity: quantity ?? this.quantity,
      minQty: minQty,
      maxQty: maxQty,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: DateTime.now(),
      serverCartItemId: serverCartItemId == _undefined
          ? this.serverCartItemId
          : serverCartItemId as int?,
      syncAction: syncAction ?? this.syncAction,
      addons: addons ?? this.addons,
    );
  }

  /// 🧮 Computed (DO NOT STORE) — variant price + addon subtotal.
  double get totalPrice => (price + addonsTotal) * quantity;
}

const Object _undefined = Object();
