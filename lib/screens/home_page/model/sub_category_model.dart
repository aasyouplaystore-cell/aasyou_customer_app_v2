
import 'package:aasyou/config/helper.dart';

import 'category_model.dart';

class SubCategoriesResponse {
  final bool? success;
  final String? message;
  final SubCategoriesPageData? data;

  SubCategoriesResponse({
    this.success,
    this.message,
    this.data,
  });

  factory SubCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoriesResponse(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? SubCategoriesPageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class SubCategoriesPageData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final List<CategoryData> subCategories;

  SubCategoriesPageData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.subCategories = const [],
  });

  factory SubCategoriesPageData.fromJson(Map<String, dynamic> json) {
    return SubCategoriesPageData(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      subCategories: _parseSubCategoryList(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'data': subCategories.map((e) => e.toJson()).toList(),
  };

  static List<CategoryData> _parseSubCategoryList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(CategoryData.fromJson)
        .toList();
  }
}
