import 'package:aasyou/config/helper.dart';

class OrderDetailModel {
  final bool? success;
  final String? message;
  final OrderDetailData? data;

  OrderDetailModel({
    this.success,
    this.message,
    this.data,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? OrderDetailData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class OrderDetailData {
  final int? id;
  final String? uuid;
  final String? slug;
  final int? userId;
  final String? email;
  final String? currencyCode;
  final String? currencyRate;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? status;
  final String? invoice;
  final String? fulfillmentType;
  final int? estimatedDeliveryTime;
  final dynamic deliveryTimeSlotId;
  final dynamic deliveryBoyId;
  final String? deliveryBoyName;
  final int? deliveryBoyPhone;
  final String? deliveryBoyProfile;
  final bool? isDeliveryFeedbackGiven;
  final List<DeliveryFeedback> deliveryFeedback;
  final String? walletBalance;
  final dynamic promoCode;
  final String? promoDiscount;
  final dynamic giftCard;
  final String? giftCardDiscount;
  final String? deliveryCharge;
  final String? handlingCharges;
  final String? perStoreDropOffFee;
  final String? subtotal;
  final String? totalPayable;
  final String? finalTotal;
  final String? shippingName;
  final String? shippingAddress1;
  final dynamic shippingAddress2;
  final String? shippingLandmark;
  final String? shippingZip;
  final String? shippingPhone;
  final String? shippingAddressType;
  final String? shippingLatitude;
  final String? shippingLongitude;
  final String? shippingCity;
  final String? shippingState;
  final String? shippingCountry;
  final String? shippingCountryCode;
  final String? orderNote;
  final List<OrderItems> items;
  final List<SellerFeedback> sellerFeedbacks;
  final String? createdAt;
  final String? updatedAt;

  OrderDetailData({
    this.id,
    this.uuid,
    this.slug,
    this.userId,
    this.email,
    this.currencyCode,
    this.currencyRate,
    this.paymentMethod,
    this.paymentStatus,
    this.status,
    this.invoice,
    this.fulfillmentType,
    this.estimatedDeliveryTime,
    this.deliveryTimeSlotId,
    this.deliveryBoyId,
    this.deliveryBoyName,
    this.deliveryBoyPhone,
    this.deliveryBoyProfile,
    this.isDeliveryFeedbackGiven,
    this.deliveryFeedback = const [],
    this.walletBalance,
    this.promoCode,
    this.promoDiscount,
    this.giftCard,
    this.giftCardDiscount,
    this.deliveryCharge,
    this.handlingCharges,
    this.perStoreDropOffFee,
    this.subtotal,
    this.totalPayable,
    this.finalTotal,
    this.shippingName,
    this.shippingAddress1,
    this.shippingAddress2,
    this.shippingLandmark,
    this.shippingZip,
    this.shippingPhone,
    this.shippingAddressType,
    this.shippingLatitude,
    this.shippingLongitude,
    this.shippingCity,
    this.shippingState,
    this.shippingCountry,
    this.shippingCountryCode,
    this.orderNote,
    this.items = const [],
    this.sellerFeedbacks = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory OrderDetailData.fromJson(Map<String, dynamic> json) {
    return OrderDetailData(
      id: parseInt(json['id']),
      uuid: parseString(json['uuid']),
      slug: parseString(json['slug']),
      userId: parseInt(json['user_id']),
      email: parseString(json['email']),
      currencyCode: parseString(json['currency_code']),
      currencyRate: parseString(json['currency_rate']),
      paymentMethod: parseString(json['payment_method']),
      paymentStatus: parseString(json['payment_status']),
      status: parseString(json['status']),
      invoice: parseString(json['invoice']),
      fulfillmentType: parseString(json['fulfillment_type']),
      estimatedDeliveryTime: parseInt(json['estimated_delivery_time']),
      deliveryTimeSlotId: json['delivery_time_slot_id'],
      deliveryBoyId: json['delivery_boy_id'],
      deliveryBoyName: parseString(json['delivery_boy_name']),
      deliveryBoyPhone: parseInt(json['delivery_boy_phone']),
      deliveryBoyProfile: parseString(json['delivery_boy_profile']),
      isDeliveryFeedbackGiven: parseBool(json['is_delivery_feedback_given']),
      deliveryFeedback: _parseDeliveryFeedback(json['delivery_feedback']),
      walletBalance: parseString(json['wallet_balance']),
      promoCode: json['promo_code'],
      promoDiscount: parseString(json['promo_discount']),
      giftCard: json['gift_card'],
      giftCardDiscount: parseString(json['gift_card_discount']),
      deliveryCharge: parseString(json['delivery_charge']),
      handlingCharges: parseString(json['handling_charges']),
      perStoreDropOffFee: parseString(json['per_store_drop_off_fee']),
      subtotal: parseString(json['subtotal']),
      totalPayable: parseString(json['total_payable']),
      finalTotal: parseString(json['final_total']),
      shippingName: parseString(json['shipping_name']),
      shippingAddress1: parseString(json['shipping_address_1']),
      shippingAddress2: json['shipping_address_2'],
      shippingLandmark: parseString(json['shipping_landmark']),
      shippingZip: parseString(json['shipping_zip']),
      shippingPhone: parseString(json['shipping_phone']),
      shippingAddressType: parseString(json['shipping_address_type']),
      shippingLatitude: parseString(json['shipping_latitude']),
      shippingLongitude: parseString(json['shipping_longitude']),
      shippingCity: parseString(json['shipping_city']),
      shippingState: parseString(json['shipping_state']),
      shippingCountry: parseString(json['shipping_country']),
      shippingCountryCode: parseString(json['shipping_country_code']),
      orderNote: parseString(json['order_note']),
      items: _parseOrderItems(json['items']),
      sellerFeedbacks: _parseSellerFeedbacks(json['seller_feedbacks']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'slug': slug,
    'user_id': userId,
    'email': email,
    'currency_code': currencyCode,
    'currency_rate': currencyRate,
    'payment_method': paymentMethod,
    'payment_status': paymentStatus,
    'status': status,
    'invoice': invoice,
    'fulfillment_type': fulfillmentType,
    'estimated_delivery_time': estimatedDeliveryTime,
    'delivery_time_slot_id': deliveryTimeSlotId,
    'delivery_boy_id': deliveryBoyId,
    'delivery_boy_name': deliveryBoyName,
    'delivery_boy_phone': deliveryBoyPhone,
    'delivery_boy_profile': deliveryBoyProfile,
    'is_delivery_feedback_given': isDeliveryFeedbackGiven,
    'delivery_feedback': deliveryFeedback.map((e) => e.toJson()).toList(),
    'wallet_balance': walletBalance,
    'promo_code': promoCode,
    'promo_discount': promoDiscount,
    'gift_card': giftCard,
    'gift_card_discount': giftCardDiscount,
    'delivery_charge': deliveryCharge,
    'handling_charges': handlingCharges,
    'per_store_drop_off_fee': perStoreDropOffFee,
    'subtotal': subtotal,
    'total_payable': totalPayable,
    'final_total': finalTotal,
    'shipping_name': shippingName,
    'shipping_address_1': shippingAddress1,
    'shipping_address_2': shippingAddress2,
    'shipping_landmark': shippingLandmark,
    'shipping_zip': shippingZip,
    'shipping_phone': shippingPhone,
    'shipping_address_type': shippingAddressType,
    'shipping_latitude': shippingLatitude,
    'shipping_longitude': shippingLongitude,
    'shipping_city': shippingCity,
    'shipping_state': shippingState,
    'shipping_country': shippingCountry,
    'shipping_country_code': shippingCountryCode,
    'order_note': orderNote,
    'items': items.map((e) => e.toJson()).toList(),
    'seller_feedbacks': sellerFeedbacks.map((e) => e.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  static List<DeliveryFeedback> _parseDeliveryFeedback(dynamic value) {
    if (value == null) return const [];

    // Handle both single object and list cases from API
    if (value is Map<String, dynamic>) {
      return [DeliveryFeedback.fromJson(value)];
    }
    if (value is Iterable) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(DeliveryFeedback.fromJson)
          .toList();
    }
    return const [];
  }

  static List<OrderItems> _parseOrderItems(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(OrderItems.fromJson)
        .toList();
  }

  static List<SellerFeedback> _parseSellerFeedbacks(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(SellerFeedback.fromJson)
        .toList();
  }
}

class DeliveryFeedback {
  final int? id;
  final String? title;
  final String? slug;
  final String? description;
  final int? rating;
  final String? createdAt;

  DeliveryFeedback({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.rating,
    this.createdAt,
  });

  factory DeliveryFeedback.fromJson(Map<String, dynamic> json) {
    return DeliveryFeedback(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      description: parseString(json['description']),
      rating: parseInt(json['rating']),
      createdAt: parseString(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'description': description,
    'rating': rating,
    'created_at': createdAt,
  };
}

class SellerFeedback {
  final int? sellerId;
  final bool? isFeedbackGiven;
  final SellerFeedbackData? feedback;

  SellerFeedback({
    this.sellerId,
    this.isFeedbackGiven,
    this.feedback,
  });

  factory SellerFeedback.fromJson(Map<String, dynamic> json) {
    return SellerFeedback(
      sellerId: parseInt(json['seller_id']),
      isFeedbackGiven: parseBool(json['is_feedback_given']),
      feedback: json['feedback'] != null && json['feedback'] is Map<String, dynamic>
          ? SellerFeedbackData.fromJson(json['feedback'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'seller_id': sellerId,
    'is_feedback_given': isFeedbackGiven,
    if (feedback != null) 'feedback': feedback!.toJson(),
  };
}

class SellerFeedbackData {
  final int? id;
  final int? userId;
  final int? sellerId;
  final int? orderId;
  final int? orderItemId;
  final int? storeId;
  final int? rating;
  final String? title;
  final String? slug;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  SellerFeedbackData({
    this.id,
    this.userId,
    this.sellerId,
    this.orderId,
    this.orderItemId,
    this.storeId,
    this.rating,
    this.title,
    this.slug,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory SellerFeedbackData.fromJson(Map<String, dynamic> json) {
    return SellerFeedbackData(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      sellerId: parseInt(json['seller_id']),
      orderId: parseInt(json['order_id']),
      orderItemId: parseInt(json['order_item_id']),
      storeId: parseInt(json['store_id']),
      rating: parseInt(json['rating']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      description: parseString(json['description']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'seller_id': sellerId,
    'order_id': orderId,
    'order_item_id': orderItemId,
    'store_id': storeId,
    'rating': rating,
    'title': title,
    'slug': slug,
    'description': description,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class OrderItems {
  final int? id;
  final int? orderId;
  final int? productId;
  final int? productVariantId;
  final int? storeId;
  final int? sellerId;
  final String? title;
  final String? variantTitle;
  final String? giftCardDiscount;
  final String? adminCommissionAmount;
  final String? sellerCommissionAmount;
  final String? commissionSettled;
  final String? discountedPrice;
  final String? promoDiscount;
  final String? discount;
  final String? taxAmount;
  final String? taxPercent;
  final String? sku;
  final bool? returnEligible;
  final String? returnDeadline;
  final int? quantity;
  final String? price;
  final String? subtotal;
  final String? status;
  // 2026-06-16 — populated server-side when the seller rejects this line.
  // Surfaced on the order detail screen so the customer sees WHY it was
  // rejected instead of a bare "Rejected" status pill.
  final String? rejectionReason;
  final String? rejectedAt;
  final dynamic otp;
  final int? otpVerified;
  final bool? isUserReviewGiven;
  final UserReview? userReview;
  final OrderDetailProduct? product;
  final OrderDetailVariant? variant;
  final Store? store;
  final List<ItemReturn> returns;
  final List<String> attachments;

  /// Addons selected on this order item.
  final List<OrderItemAddon> addons;

  /// Server-computed addon subtotal for this order item (unit addon.
  final double? addonsTotal;

  final String? createdAt;
  final String? updatedAt;

  OrderItems({
    this.id,
    this.orderId,
    this.productId,
    this.productVariantId,
    this.storeId,
    this.sellerId,
    this.title,
    this.variantTitle,
    this.giftCardDiscount,
    this.adminCommissionAmount,
    this.sellerCommissionAmount,
    this.commissionSettled,
    this.discountedPrice,
    this.promoDiscount,
    this.discount,
    this.taxAmount,
    this.taxPercent,
    this.sku,
    this.returnEligible,
    this.returnDeadline,
    this.quantity,
    this.price,
    this.subtotal,
    this.status,
    this.rejectionReason,
    this.rejectedAt,
    this.otp,
    this.otpVerified,
    this.isUserReviewGiven,
    this.userReview,
    this.product,
    this.variant,
    this.store,
    this.returns = const [],
    this.attachments = const [],
    this.addons = const [],
    this.addonsTotal,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItems.fromJson(Map<String, dynamic> json) {
    return OrderItems(
      id: parseInt(json['id']),
      orderId: parseInt(json['order_id']),
      productId: parseInt(json['product_id']),
      productVariantId: parseInt(json['product_variant_id']),
      storeId: parseInt(json['store_id']),
      sellerId: parseInt(json['seller_id']),
      title: parseString(json['title']),
      variantTitle: parseString(json['variant_title']),
      giftCardDiscount: parseString(json['gift_card_discount']),
      adminCommissionAmount: parseString(json['admin_commission_amount']),
      sellerCommissionAmount: parseString(json['seller_commission_amount']),
      commissionSettled: parseString(json['commission_settled']),
      discountedPrice: parseString(json['discounted_price']),
      promoDiscount: parseString(json['promo_discount']),
      discount: parseString(json['discount']),
      taxAmount: parseString(json['tax_amount']),
      taxPercent: parseString(json['tax_percent']),
      sku: parseString(json['sku']),
      returnEligible: parseBool(json['return_eligible']),
      returnDeadline: parseString(json['return_deadline']),
      quantity: parseInt(json['quantity']),
      price: parseString(json['price']),
      subtotal: parseString(json['subtotal']),
      status: parseString(json['status']),
      rejectionReason: parseString(json['rejection_reason']),
      rejectedAt: parseString(json['rejected_at']),
      otp: json['otp'],
      otpVerified: parseInt(json['otp_verified']),
      isUserReviewGiven: parseBool(json['is_user_review_given']),
      userReview: json['user_review'] != null
          ? UserReview.fromJson(json['user_review'])
          : null,
      product: json['product'] != null ? OrderDetailProduct.fromJson(json['product']) : null,
      variant: json['variant'] != null ? OrderDetailVariant.fromJson(json['variant']) : null,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      returns: _parseReturns(json['returns']),
      attachments: _parseAttachments(json['attachments']),
      addons: _parseAddons(json['addons']),
      addonsTotal: parseDouble(json['addons_total']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'product_id': productId,
    'product_variant_id': productVariantId,
    'store_id': storeId,
    'seller_id': sellerId,
    'title': title,
    'variant_title': variantTitle,
    'gift_card_discount': giftCardDiscount,
    'admin_commission_amount': adminCommissionAmount,
    'seller_commission_amount': sellerCommissionAmount,
    'commission_settled': commissionSettled,
    'discounted_price': discountedPrice,
    'promo_discount': promoDiscount,
    'discount': discount,
    'tax_amount': taxAmount,
    'tax_percent': taxPercent,
    'sku': sku,
    'return_eligible': returnEligible,
    'return_deadline': returnDeadline,
    'quantity': quantity,
    'price': price,
    'subtotal': subtotal,
    'status': status,
    'rejection_reason': rejectionReason,
    'rejected_at': rejectedAt,
    'otp': otp,
    'otp_verified': otpVerified,
    'is_user_review_given': isUserReviewGiven,
    if (userReview != null) 'user_review': userReview!.toJson(),
    if (product != null) 'product': product!.toJson(),
    if (variant != null) 'variant': variant!.toJson(),
    if (store != null) 'store': store!.toJson(),
    'returns': returns.map((e) => e.toJson()).toList(),
    'attachments': attachments,
    'addons': addons.map((e) => e.toJson()).toList(),
    'addons_total': addonsTotal,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  static List<ItemReturn> _parseReturns(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ItemReturn.fromJson)
        .toList();
  }

  static List<String> _parseAttachments(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  static List<OrderItemAddon> _parseAddons(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(OrderItemAddon.fromJson)
        .toList();
  }
}

class ItemReturn {
  final int? id;
  final int? orderItemId;
  final int? orderId;
  final int? userId;
  final int? sellerId;
  final int? storeId;
  final dynamic deliveryBoyId;
  final String? reason;
  final String? sellerComment;
  final List<String> images;
  final int? refundAmount;
  final String? pickupStatus;
  final String? returnStatus;
  final String? sellerApprovedAt;
  final String? pickedUpAt;
  final String? receivedAt;
  final String? refundProcessedAt;
  final String? createdAt;
  final String? updatedAt;

  ItemReturn({
    this.id,
    this.orderItemId,
    this.orderId,
    this.userId,
    this.sellerId,
    this.storeId,
    this.deliveryBoyId,
    this.reason,
    this.sellerComment,
    this.images = const [],
    this.refundAmount,
    this.pickupStatus,
    this.returnStatus,
    this.sellerApprovedAt,
    this.pickedUpAt,
    this.receivedAt,
    this.refundProcessedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemReturn.fromJson(Map<String, dynamic> json) {
    return ItemReturn(
      id: parseInt(json['id']),
      orderItemId: parseInt(json['order_item_id']),
      orderId: parseInt(json['order_id']),
      userId: parseInt(json['user_id']),
      sellerId: parseInt(json['seller_id']),
      storeId: parseInt(json['store_id']),
      deliveryBoyId: json['delivery_boy_id'],
      reason: parseString(json['reason']),
      sellerComment: parseString(json['seller_comment']),
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? const [],
      refundAmount: parseInt(json['refund_amount']),
      pickupStatus: parseString(json['pickup_status']),
      returnStatus: parseString(json['return_status']),
      sellerApprovedAt: parseString(json['seller_approved_at']),
      pickedUpAt: parseString(json['picked_up_at']),
      receivedAt: parseString(json['received_at']),
      refundProcessedAt: parseString(json['refund_processed_at']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_item_id': orderItemId,
    'order_id': orderId,
    'user_id': userId,
    'seller_id': sellerId,
    'store_id': storeId,
    'delivery_boy_id': deliveryBoyId,
    'reason': reason,
    'seller_comment': sellerComment,
    'images': images,
    'refund_amount': refundAmount,
    'pickup_status': pickupStatus,
    'return_status': returnStatus,
    'seller_approved_at': sellerApprovedAt,
    'picked_up_at': pickedUpAt,
    'received_at': receivedAt,
    'refund_processed_at': refundProcessedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

// ────────────────────────────────────────────────

class OrderDetailProduct {
  final int? id;
  final String? name;
  final String? slug;
  final bool? isReturnable;
  final int? returnableDays;
  final bool? isCancelable;
  final String? cancelableTill;
  final String? image;
  final int? requiresOtp;

  OrderDetailProduct({
    this.id,
    this.name,
    this.slug,
    this.isReturnable,
    this.returnableDays,
    this.isCancelable,
    this.cancelableTill,
    this.image,
    this.requiresOtp,
  });

  factory OrderDetailProduct.fromJson(Map<String, dynamic> json) {
    return OrderDetailProduct(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      slug: parseString(json['slug']),
      isReturnable: parseBool(json['is_returnable']),
      returnableDays: parseInt(json['returnable_days']),
      isCancelable: parseBool(json['is_cancelable']),
      cancelableTill: parseString(json['cancelable_till']),
      image: parseString(json['image']),
      requiresOtp: parseInt(json['requires_otp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'is_returnable': isReturnable,
    'returnable_days': returnableDays,
    'is_cancelable': isCancelable,
    'cancelable_till': cancelableTill,
    'image': image,
    'requires_otp': requiresOtp,
  };
}

class OrderDetailVariant {
  final int? id;
  final String? title;
  final String? slug;
  final String? image;

  OrderDetailVariant({
    this.id,
    this.title,
    this.slug,
    this.image,
  });

  factory OrderDetailVariant.fromJson(Map<String, dynamic> json) {
    return OrderDetailVariant(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      image: parseString(json['image']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'image': image,
  };
}

class Store {
  final int? id;
  final String? name;
  final String? slug;

  Store({
    this.id,
    this.name,
    this.slug,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      slug: parseString(json['slug']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
  };
}

class UserReview {
  final int? id;
  final int? productId;
  final int? rating;
  final String? title;
  final String? slug;
  final String? comment;
  final List<String> reviewImages;
  final User? user;
  final String? createdAt;

  UserReview({
    this.id,
    this.productId,
    this.rating,
    this.title,
    this.slug,
    this.comment,
    this.reviewImages = const [],
    this.user,
    this.createdAt,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      rating: parseInt(json['rating']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      comment: parseString(json['comment']),
      reviewImages: (json['review_images'] as List<dynamic>?)?.cast<String>() ?? const [],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: parseString(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'rating': rating,
    'title': title,
    'slug': slug,
    'comment': comment,
    'review_images': reviewImages,
    if (user != null) 'user': user!.toJson(),
    'created_at': createdAt,
  };
}

class User {
  final int? id;
  final String? name;

  User({
    this.id,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: parseInt(json['id']),
      name: parseString(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

/// A single selected addon attached to an [OrderItems] row.
class OrderItemAddon {
  final int? id;
  final String? uuid;
  final int? addonGroupId;
  final int? addonItemId;
  final double? price;
  final OrderItemAddonGroup? group;
  final OrderItemAddonItem? item;

  OrderItemAddon({
    this.id,
    this.uuid,
    this.addonGroupId,
    this.addonItemId,
    this.price,
    this.group,
    this.item,
  });

  factory OrderItemAddon.fromJson(Map<String, dynamic> json) {
    return OrderItemAddon(
      id: parseInt(json['id']),
      uuid: parseString(json['uuid']),
      addonGroupId: parseInt(json['addon_group_id']),
      addonItemId: parseInt(json['addon_item_id']),
      price: parseDouble(json['price']),
      group: json['group'] != null && json['group'] is Map<String, dynamic>
          ? OrderItemAddonGroup.fromJson(json['group'] as Map<String, dynamic>)
          : null,
      item: json['item'] != null && json['item'] is Map<String, dynamic>
          ? OrderItemAddonItem.fromJson(json['item'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'addon_group_id': addonGroupId,
        'addon_item_id': addonItemId,
        'price': price,
        if (group != null) 'group': group!.toJson(),
        if (item != null) 'item': item!.toJson(),
      };
}

class OrderItemAddonGroup {
  final int? id;
  final String? title;
  final String? selectionType;
  final bool? isRequired;

  OrderItemAddonGroup({
    this.id,
    this.title,
    this.selectionType,
    this.isRequired,
  });

  factory OrderItemAddonGroup.fromJson(Map<String, dynamic> json) {
    return OrderItemAddonGroup(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      selectionType: parseString(json['selection_type']),
      isRequired: parseBool(json['is_required']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'selection_type': selectionType,
        'is_required': isRequired,
      };
}

class OrderItemAddonItem {
  final int? id;
  final String? title;
  final String? indicator;

  OrderItemAddonItem({
    this.id,
    this.title,
    this.indicator,
  });

  factory OrderItemAddonItem.fromJson(Map<String, dynamic> json) {
    return OrderItemAddonItem(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      indicator: parseString(json['indicator']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'indicator': indicator,
      };
}