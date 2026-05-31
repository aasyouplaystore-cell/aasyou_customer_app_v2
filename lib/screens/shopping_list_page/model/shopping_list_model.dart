import 'package:aasyou/config/helper.dart';
import '../../product_detail_page/model/product_detail_model.dart';

class ShoppingListModel {
  final bool? success;
  final String? message;
  final List<ShoppingListData> data;

  ShoppingListModel({
    this.success,
    this.message,
    List<ShoppingListData>? data,
  }) : data = data ?? const [];

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: _parseShoppingLists(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
  };

  static List<ShoppingListData> _parseShoppingLists(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ShoppingListData.fromJson)
        .toList();
  }
}

class ShoppingListData {
  final String? keyword;
  final int? totalProducts;
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final List<ProductData> products;

  ShoppingListData({
    this.keyword,
    this.totalProducts,
    this.currentPage,
    this.lastPage,
    this.perPage,
    List<ProductData>? products,
  }) : products = products ?? const [];

  factory ShoppingListData.fromJson(Map<String, dynamic> json) {
    return ShoppingListData(
      keyword: parseString(json['keyword']),
      totalProducts: parseInt(json['total_products']),
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      products: _parseProducts(json['products']),
    );
  }

  Map<String, dynamic> toJson() => {
    'keyword': keyword,
    'total_products': totalProducts,
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'products': products.map((e) => e.toJson()).toList(),
  };

  static List<ProductData> _parseProducts(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ProductData.fromJson)
        .toList();
  }
}