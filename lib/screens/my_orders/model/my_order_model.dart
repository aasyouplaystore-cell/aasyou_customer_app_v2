
import 'package:aasyou/config/helper.dart';

class MyOrdersModel {
  final bool? success;
  final String? message;
  final MyOrdersPageData? data;

  MyOrdersModel({
    this.success,
    this.message,
    this.data,
  });

  factory MyOrdersModel.fromJson(Map<String, dynamic> json) {
    return MyOrdersModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? MyOrdersPageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class MyOrdersPageData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final List<MyOrderData> orders;

  MyOrdersPageData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.orders = const [],
  });

  factory MyOrdersPageData.fromJson(Map<String, dynamic> json) {
    return MyOrdersPageData(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      orders: _parseOrders(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'data': orders.map((e) => e.toJson()).toList(),
  };

  static List<MyOrderData> _parseOrders(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(MyOrderData.fromJson)
        .toList();
  }
}

class MyOrderData {
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
  final int? deliveryBoyId;
  final String? deliveryBoyName;
  final int? deliveryBoyPhone;
  final String? deliveryBoyProfile;
  final bool? isDeliveryFeedbackGiven;
  final List<DeliveryBoyFeedback> deliveryFeedback;
  final String? walletBalance;
  final dynamic promoCode;
  final String? promoDiscount;
  final dynamic giftCard;
  final String? giftCardDiscount;
  final String? deliveryCharge;
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
  final List<SellerFeedback> sellerFeedbacks;
  final List<OrderItem> items;
  final String? createdAt;
  final String? updatedAt;

  MyOrderData({
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
    this.sellerFeedbacks = const [],
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory MyOrderData.fromJson(Map<String, dynamic> json) {
    return MyOrderData(
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
      deliveryBoyId: parseInt(json['delivery_boy_id']),
      deliveryBoyName: parseString(json['delivery_boy_name']),
      deliveryBoyPhone: parseInt(json['delivery_boy_phone']),
      deliveryBoyProfile: parseString(json['delivery_boy_profile']),
      isDeliveryFeedbackGiven: parseBool(json['is_delivery_feedback_given']),
      deliveryFeedback: _parseDeliveryFeedbacks(json['delivery_feedback']),
      walletBalance: parseString(json['wallet_balance']),
      promoCode: json['promo_code'],
      promoDiscount: parseString(json['promo_discount']),
      giftCard: json['gift_card'],
      giftCardDiscount: parseString(json['gift_card_discount']),
      deliveryCharge: parseString(json['delivery_charge']),
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
      sellerFeedbacks: _parseSellerFeedbacks(json['seller_feedbacks']),
      items: _parseOrderItems(json['items']),
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
    'seller_feedbacks': sellerFeedbacks.map((e) => e.toJson()).toList(),
    'items': items.map((e) => e.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  static List<DeliveryBoyFeedback> _parseDeliveryFeedbacks(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(DeliveryBoyFeedback.fromJson)
        .toList();
  }

  static List<SellerFeedback> _parseSellerFeedbacks(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(SellerFeedback.fromJson)
        .toList();
  }

  static List<OrderItem> _parseOrderItems(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromJson)
        .toList();
  }
}

class DeliveryBoyFeedback {
  final int? id;
  final String? title;
  final String? slug;
  final String? description;
  final int? rating;
  final String? createdAt;

  DeliveryBoyFeedback({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.rating,
    this.createdAt,
  });

  factory DeliveryBoyFeedback.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyFeedback(
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
  final SellerFeedbackDetail? feedback;

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
          ? SellerFeedbackDetail.fromJson(json['feedback'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'seller_id': sellerId,
    'is_feedback_given': isFeedbackGiven,
    if (feedback != null) 'feedback': feedback!.toJson(),
  };
}

class SellerFeedbackDetail {
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

  SellerFeedbackDetail({
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

  factory SellerFeedbackDetail.fromJson(Map<String, dynamic> json) {
    return SellerFeedbackDetail(
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

class OrderItem {
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
  final int? quantity;
  final String? price;
  final String? subtotal;
  final String? status;
  final dynamic otp;
  final int? otpVerified;
  final bool? isUserReviewGiven;
  final UserReview? userReview;
  final Product? product;
  final Variant? variant;
  final Store? store;
  final String? createdAt;
  final String? updatedAt;

  OrderItem({
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
    this.quantity,
    this.price,
    this.subtotal,
    this.status,
    this.otp,
    this.otpVerified,
    this.isUserReviewGiven,
    this.userReview,
    this.product,
    this.variant,
    this.store,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
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
      quantity: parseInt(json['quantity']),
      price: parseString(json['price']),
      subtotal: parseString(json['subtotal']),
      status: parseString(json['status']),
      otp: json['otp'],
      otpVerified: parseInt(json['otp_verified']),
      isUserReviewGiven: parseBool(json['is_user_review_given']),
      userReview: json['user_review'] != null
          ? UserReview.fromJson(json['user_review'])
          : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      variant: json['variant'] != null ? Variant.fromJson(json['variant']) : null,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
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
    'quantity': quantity,
    'price': price,
    'subtotal': subtotal,
    'status': status,
    'otp': otp,
    'otp_verified': otpVerified,
    'is_user_review_given': isUserReviewGiven,
    if (userReview != null) 'user_review': userReview!.toJson(),
    if (product != null) 'product': product!.toJson(),
    if (variant != null) 'variant': variant!.toJson(),
    if (store != null) 'store': store!.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
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

class Product {
  final int? id;
  final String? name;
  final String? slug;
  final String? image;
  final int? requiresOtp;

  Product({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.requiresOtp,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      slug: parseString(json['slug']),
      image: parseString(json['image']),
      requiresOtp: parseInt(json['requires_otp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'image': image,
    'requires_otp': requiresOtp,
  };
}

class Variant {
  final int? id;
  final String? title;
  final String? slug;
  final String? image;

  Variant({
    this.id,
    this.title,
    this.slug,
    this.image,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
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