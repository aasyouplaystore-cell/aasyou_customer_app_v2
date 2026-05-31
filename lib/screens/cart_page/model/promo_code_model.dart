
import '../../../config/helper.dart';

class PromoCodesResponse {
  final bool? success;
  final String? message;
  final List<PromoCodeData> promoCodes;

  PromoCodesResponse({
    this.success,
    this.message,
    this.promoCodes = const [],
  });

  factory PromoCodesResponse.fromJson(Map<String, dynamic> json) {
    return PromoCodesResponse(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      promoCodes: _parsePromoCodeList(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': promoCodes.map((e) => e.toJson()).toList(),
  };

  static List<PromoCodeData> _parsePromoCodeList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(PromoCodeData.fromJson)
        .toList();
  }
}

class PromoCodeData {
  final int? id;
  final String? code;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? discountType;
  final String? discountAmount;
  final String? promoMode;
  final int? usageCount;
  final int? individualUse;
  final int? maxTotalUsage;
  final int? maxUsagePerUser;
  final String? minOrderTotal;
  final String? maxDiscountValue;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  PromoCodeData({
    this.id,
    this.code,
    this.description,
    this.startDate,
    this.endDate,
    this.discountType,
    this.discountAmount,
    this.promoMode,
    this.usageCount,
    this.individualUse,
    this.maxTotalUsage,
    this.maxUsagePerUser,
    this.minOrderTotal,
    this.maxDiscountValue,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PromoCodeData.fromJson(Map<String, dynamic> json) {
    return PromoCodeData(
      id: parseInt(json['id']),
      code: parseString(json['code']),
      description: parseString(json['description']),
      startDate: parseString(json['start_date']),
      endDate: parseString(json['end_date']),
      discountType: parseString(json['discount_type']),
      discountAmount: parseString(json['discount_amount']),
      promoMode: parseString(json['promo_mode']),
      usageCount: parseInt(json['usage_count']),
      individualUse: parseInt(json['individual_use']),
      maxTotalUsage: parseInt(json['max_total_usage']),
      maxUsagePerUser: parseInt(json['max_usage_per_user']),
      minOrderTotal: parseString(json['min_order_total']),
      maxDiscountValue: parseString(json['max_discount_value']),
      deletedAt: parseString(json['deleted_at']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'description': description,
    'start_date': startDate,
    'end_date': endDate,
    'discount_type': discountType,
    'discount_amount': discountAmount,
    'promo_mode': promoMode,
    'usage_count': usageCount,
    'individual_use': individualUse,
    'max_total_usage': maxTotalUsage,
    'max_usage_per_user': maxUsagePerUser,
    'min_order_total': minOrderTotal,
    'max_discount_value': maxDiscountValue,
    'deleted_at': deletedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}