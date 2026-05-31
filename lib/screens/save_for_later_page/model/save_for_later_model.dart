import 'package:aasyou/config/helper.dart';

class SaveForLaterModel {
  final bool? success;
  final String? message;
  final SaveForLaterData? data;

  SaveForLaterModel({
    this.success,
    this.message,
    this.data,
  });

  factory SaveForLaterModel.fromJson(Map<String, dynamic> json) {
    return SaveForLaterModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? SaveForLaterData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class SaveForLaterData {
  final int? id;
  final String? uuid;
  final int? userId;
  final int? itemsCount;
  final int? totalQuantity;
  final List<SavedItem> items;
  final String? createdAt;
  final String? updatedAt;

  SaveForLaterData({
    this.id,
    this.uuid,
    this.userId,
    this.itemsCount,
    this.totalQuantity,
    List<SavedItem>? items,
    this.createdAt,
    this.updatedAt,
  }) : items = items ?? const [];

  factory SaveForLaterData.fromJson(Map<String, dynamic> json) {
    return SaveForLaterData(
      id: parseInt(json['id']),
      uuid: parseString(json['uuid']),
      userId: parseInt(json['user_id']),
      itemsCount: parseInt(json['items_count']),
      totalQuantity: parseInt(json['total_quantity']),
      items: _parseSavedItems(json['items']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'user_id': userId,
    'items_count': itemsCount,
    'total_quantity': totalQuantity,
    'items': items.map((e) => e.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  static List<SavedItem> _parseSavedItems(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(SavedItem.fromJson)
        .toList();
  }
}

class SavedItem {
  final int? id;
  final int? cartId;
  final int? productId;
  final int? productVariantId;
  final int? storeId;
  final int? quantity;
  final bool? saveForLater;
  final SavedProduct? product;
  final SavedProductVariant? variant;
  final Store? store;
  final String? createdAt;
  final String? updatedAt;

  SavedItem({
    this.id,
    this.cartId,
    this.productId,
    this.productVariantId,
    this.storeId,
    this.quantity,
    this.saveForLater,
    this.product,
    this.variant,
    this.store,
    this.createdAt,
    this.updatedAt,
  });

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: parseInt(json['id']),
      cartId: parseInt(json['cart_id']),
      productId: parseInt(json['product_id']),
      productVariantId: parseInt(json['product_variant_id']),
      storeId: parseInt(json['store_id']),
      quantity: parseInt(json['quantity']),
      saveForLater: parseBool(json['save_for_later']),
      product: json['product'] != null ? SavedProduct.fromJson(json['product']) : null,
      variant: json['variant'] != null ? SavedProductVariant.fromJson(json['variant']) : null,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cart_id': cartId,
    'product_id': productId,
    'product_variant_id': productVariantId,
    'store_id': storeId,
    'quantity': quantity,
    'save_for_later': saveForLater,
    if (product != null) 'product': product!.toJson(),
    if (variant != null) 'variant': variant!.toJson(),
    if (store != null) 'store': store!.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class SavedProduct {
  final int? id;
  final String? name;
  final String? slug;
  final int? minimumOrderQuantity;
  final int? quantityStepSize;
  final int? totalAllowedQuantity;
  final String? image;
  final String? estimatedDeliveryTime;
  final String? imageFit;
  final StoreStatus? storeStatus;
  final double? ratings;
  final int? ratingCount;

  SavedProduct({
    this.id,
    this.name,
    this.slug,
    this.minimumOrderQuantity,
    this.quantityStepSize,
    this.totalAllowedQuantity,
    this.image,
    this.estimatedDeliveryTime,
    this.imageFit,
    this.storeStatus,
    this.ratings,
    this.ratingCount,
  });

  factory SavedProduct.fromJson(Map<String, dynamic> json) {
    return SavedProduct(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      slug: parseString(json['slug']),
      minimumOrderQuantity: parseInt(json['minimum_order_quantity']),
      quantityStepSize: parseInt(json['quantity_step_size']),
      totalAllowedQuantity: parseInt(json['total_allowed_quantity']),
      image: parseString(json['image']),
      estimatedDeliveryTime: parseString(json['estimated_delivery_time']),
      imageFit: parseString(json['image_fit']),
      storeStatus: json['store_status'] != null
          ? StoreStatus.fromJson(json['store_status'])
          : null,
      ratings: parseDouble(json['ratings'].toString()),
      ratingCount: parseInt(json['rating_count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'minimum_order_quantity': minimumOrderQuantity,
    'quantity_step_size': quantityStepSize,
    'total_allowed_quantity': totalAllowedQuantity,
    'image': image,
    'estimated_delivery_time': estimatedDeliveryTime,
    'image_fit': imageFit,
    if (storeStatus != null) 'store_status': storeStatus!.toJson(),
    'ratings': ratings,
    'rating_count': ratingCount,
  };
}

class SavedProductVariant {
  final int? id;
  final String? title;
  final String? slug;
  final String? image;
  final int? price;
  final int? specialPrice;
  final int? stock;
  final String? sku;

  SavedProductVariant({
    this.id,
    this.title,
    this.slug,
    this.image,
    this.price,
    this.specialPrice,
    this.stock,
    this.sku,
  });

  factory SavedProductVariant.fromJson(Map<String, dynamic> json) {
    return SavedProductVariant(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      image: parseString(json['image']),
      price: parseInt(json['price']),
      specialPrice: parseInt(json['special_price']),
      stock: parseInt(json['stock']),
      sku: parseString(json['sku']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'image': image,
    'price': price,
    'special_price': specialPrice,
    'stock': stock,
    'sku': sku,
  };
}

class Store {
  final int? id;
  final String? name;
  final String? slug;
  final int? totalProducts;
  final StoreStatus? status;

  Store({
    this.id,
    this.name,
    this.slug,
    this.totalProducts,
    this.status,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      slug: parseString(json['slug']),
      totalProducts: parseInt(json['total_products']),
      status: json['status'] != null ? StoreStatus.fromJson(json['status']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'total_products': totalProducts,
    if (status != null) 'status': status!.toJson(),
  };
}

class StoreStatus {
  final bool? isOpen;
  final String? status;

  StoreStatus({
    this.isOpen,
    this.status,
  });

  factory StoreStatus.fromJson(Map<String, dynamic> json) {
    return StoreStatus(
      isOpen: parseBool(json['is_open']),
      status: parseString(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'is_open': isOpen,
    'status': status,
  };
}