import 'package:aasyou/config/helper.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';

class StoreProductListingModel {
  final bool? success;
  final String? message;
  final StoreProductListingData? data;

  StoreProductListingModel({
    this.success,
    this.message,
    this.data,
  });

  factory StoreProductListingModel.fromJson(Map<String, dynamic> json) {
    return StoreProductListingModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null
          ? StoreProductListingData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class StoreProductListingData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final List<ProductData> products;

  StoreProductListingData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    List<ProductData>? products,
  }) : products = products ?? const [];

  factory StoreProductListingData.fromJson(Map<String, dynamic> json) {
    return StoreProductListingData(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      products: _parseProducts(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'data': products.map((e) => e.toJson()).toList(),
  };

  static List<ProductData> _parseProducts(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ProductData.fromJson)
        .toList();
  }
}