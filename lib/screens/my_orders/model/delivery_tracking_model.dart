import 'package:aasyou/config/helper.dart';

class DeliveryBoyTrackingModel {
  final bool? success;
  final String? message;
  final DeliveryBoyTrackingData? data;

  DeliveryBoyTrackingModel({
    this.success,
    this.message,
    this.data,
  });

  factory DeliveryBoyTrackingModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    DeliveryBoyTrackingData? parsedData;

    if (rawData is Map<String, dynamic>) {
      parsedData = DeliveryBoyTrackingData.fromJson(rawData);
    } else if (rawData is List && rawData.isNotEmpty && rawData.first is Map<String, dynamic>) {
      // rare case: wrapped in list with one item
      parsedData = DeliveryBoyTrackingData.fromJson(rawData.first as Map<String, dynamic>);
    } else {
      // empty list, null, or unexpected → no data
      parsedData = null;
    }

    return DeliveryBoyTrackingModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}
//


class DeliveryBoyTrackingData {
  final List<DeliveryBoyInfo> deliveryBoys;   // ← always List (never null)
  final TrackingRoute? route;
  final TrackedOrder? order;

  DeliveryBoyTrackingData({
    this.deliveryBoys = const [],
    this.route,
    this.order,
  });

  factory DeliveryBoyTrackingData.fromJson(Map<String, dynamic> json) {
    final boyField = json['delivery_boy'];

    List<DeliveryBoyInfo> boys = [];

    if (boyField != null) {
      // Case 1: single object (most common)
      if (boyField is Map<String, dynamic>) {
        final info = DeliveryBoyInfo.fromJson(boyField);
        // Only keep if it looks meaningful
        if (info.success == true && info.data != null) {
          boys = [info];
        }
      }
      // Case 2: already a list (rare / future-proof)
      else if (boyField is List) {
        boys = boyField
            .whereType<Map<String, dynamic>>()
            .map(DeliveryBoyInfo.fromJson)
            .where((info) => info.success == true && info.data != null)
            .toList();
      }
      // ignore other unexpected types → stays empty
    }

    return DeliveryBoyTrackingData(
      deliveryBoys: boys,
      route: json['route'] != null ? TrackingRoute.fromJson(json['route']) : null,
      order: json['order'] != null ? TrackedOrder.fromJson(json['order']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'delivery_boy': deliveryBoys.map((e) => e.toJson()).toList(),
    if (route != null) 'route': route!.toJson(),
    if (order != null) 'order': order!.toJson(),
  };
}


class DeliveryBoyInfo {
  final bool? success;
  final String? message;
  final DeliveryBoyData? data;

  DeliveryBoyInfo({
    this.success,
    this.message,
    this.data,
  });

  factory DeliveryBoyInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyInfo(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? DeliveryBoyData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class DeliveryBoyData {
  final int? id;
  final int? deliveryBoyId;
  final DeliveryBoyProfile? deliveryBoy;
  final double? latitude;
  final double? longitude;
  final int? recordedAt;
  final String? createdAt;
  final String? updatedAt;

  DeliveryBoyData({
    this.id,
    this.deliveryBoyId,
    this.deliveryBoy,
    this.latitude,
    this.longitude,
    this.recordedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryBoyData.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyData(
      id: parseInt(json['id']),
      deliveryBoyId: parseInt(json['delivery_boy_id']),
      deliveryBoy: json['delivery_boy'] != null
          ? DeliveryBoyProfile.fromJson(json['delivery_boy'])
          : null,
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      recordedAt: parseInt(json['recorded_at']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'delivery_boy_id': deliveryBoyId,
    if (deliveryBoy != null) 'delivery_boy': deliveryBoy!.toJson(),
    'latitude': latitude,
    'longitude': longitude,
    'recorded_at': recordedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class DeliveryBoyProfile {
  final int? id;
  final int? userId;
  final int? deliveryZoneId;
  final String? status;
  final String? fullName;
  final String? address;
  final List<String> driverLicense;
  final String? driverLicenseNumber;
  final String? vehicleType;
  final List<String> vehicleRegistration;
  final String? verificationStatus;
  final String? verificationRemark;
  final String? createdAt;

  DeliveryBoyProfile({
    this.id,
    this.userId,
    this.deliveryZoneId,
    this.status,
    this.fullName,
    this.address,
    this.driverLicense = const [],
    this.driverLicenseNumber,
    this.vehicleType,
    this.vehicleRegistration = const [],
    this.verificationStatus,
    this.verificationRemark,
    this.createdAt,
  });

  factory DeliveryBoyProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyProfile(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      deliveryZoneId: parseInt(json['delivery_zone_id']),
      status: parseString(json['status']),
      fullName: parseString(json['full_name']),
      address: parseString(json['address']),
      driverLicense: (json['driver_license'] as List<dynamic>?)?.cast<String>() ?? const [],
      driverLicenseNumber: parseString(json['driver_license_number']),
      vehicleType: parseString(json['vehicle_type']),
      vehicleRegistration: (json['vehicle_registration'] as List<dynamic>?)?.cast<String>() ?? const [],
      verificationStatus: parseString(json['verification_status']),
      verificationRemark: parseString(json['verification_remark']),
      createdAt: parseString(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'delivery_zone_id': deliveryZoneId,
    'status': status,
    'full_name': fullName,
    'address': address,
    'driver_license': driverLicense,
    'driver_license_number': driverLicenseNumber,
    'vehicle_type': vehicleType,
    'vehicle_registration': vehicleRegistration,
    'verification_status': verificationStatus,
    'verification_remark': verificationRemark,
    'created_at': createdAt,
  };
}

class TrackingRoute {
  final double? totalDistance;
  final List<int> route;
  final List<RouteDetail> routeDetails;

  TrackingRoute({
    this.totalDistance,
    this.route = const [],
    this.routeDetails = const [],
  });

  factory TrackingRoute.fromJson(Map<String, dynamic> json) {
    return TrackingRoute(
      totalDistance: parseDouble(json['total_distance']),
      route: (json['route'] as List<dynamic>?)?.cast<int>() ?? const [],
      routeDetails: _parseRouteDetails(json['route_details']),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_distance': totalDistance,
    'route': route,
    'route_details': routeDetails.map((e) => e.toJson()).toList(),
  };

  static List<RouteDetail> _parseRouteDetails(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(RouteDetail.fromJson)
        .toList();
  }
}

class RouteDetail {
  final int? storeId;
  final String? storeName;
  final double? distanceFromCustomer;
  final String? address;
  final String? city;
  final String? landmark;
  final String? state;
  final String? zipcode;
  final String? country;
  final String? countryCode;
  final double? latitude;
  final double? longitude;
  final dynamic distanceFromPrevious;
  final bool? isCollected;

  RouteDetail({
    this.storeId,
    this.storeName,
    this.distanceFromCustomer,
    this.address,
    this.city,
    this.landmark,
    this.state,
    this.zipcode,
    this.country,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.distanceFromPrevious,
    this.isCollected
  });

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    return RouteDetail(
      storeId: parseInt(json['store_id']),
      storeName: parseString(json['store_name']),
      distanceFromCustomer: parseDouble(json['distance_from_customer']),
      address: parseString(json['address']),
      city: parseString(json['city']),
      landmark: parseString(json['landmark']),
      state: parseString(json['state']),
      zipcode: parseString(json['zipcode']),
      country: parseString(json['country']),
      countryCode: parseString(json['country_code']),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      distanceFromPrevious: json['distance_from_previous'],
      isCollected: parseBool(json['is_collected'] ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
    'store_id': storeId,
    'store_name': storeName,
    'distance_from_customer': distanceFromCustomer,
    'address': address,
    'city': city,
    'landmark': landmark,
    'state': state,
    'zipcode': zipcode,
    'country': country,
    'country_code': countryCode,
    'latitude': latitude,
    'longitude': longitude,
    'distance_from_previous': distanceFromPrevious,
  };
}

class TrackedOrder {
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
  final dynamic deliveryFeedback;
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
  final List<OrderItem> items;
  final String? createdAt;
  final String? updatedAt;

  TrackedOrder({
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
    this.deliveryFeedback,
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
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory TrackedOrder.fromJson(Map<String, dynamic> json) {
    return TrackedOrder(
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
      deliveryFeedback: json['delivery_feedback'],
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
    'delivery_feedback': deliveryFeedback,
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
    'items': items.map((e) => e.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  static List<OrderItem> _parseOrderItems(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromJson)
        .toList();
  }
}

class OrderItem {
  final int? id;
  final int? orderId;
  final int? productId;
  final int? productVariantId;
  final int? storeId;
  final int? sellerId;
  final String? sellerName;
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
  final dynamic userReview;
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
    this.sellerName,
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
      sellerName: parseString(json['seller_name']),
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
      userReview: json['user_review'],
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
    'seller_name': sellerName,
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
    'user_review': userReview,
    if (product != null) 'product': product!.toJson(),
    if (variant != null) 'variant': variant!.toJson(),
    if (store != null) 'store': store!.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class Product {
  final int? id;
  final String? name;
  final String? slug;
  final bool? isReturnable;
  final int? returnableDays;
  final bool? isCancelable;
  final String? cancelableTill;
  final String? image;
  final int? requiresOtp;

  Product({
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
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