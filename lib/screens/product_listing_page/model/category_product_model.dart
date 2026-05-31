import 'package:aasyou/config/helper.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';

class CategoryProductModel {
  final bool? success;
  final String? message;
  final CategoryProductsPageData? data;

  CategoryProductModel({
    this.success,
    this.message,
    this.data,
  });

  factory CategoryProductModel.fromJson(Map<String, dynamic> json) {
    return CategoryProductModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null
          ? CategoryProductsPageData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class CategoryProductsPageData {
  final int? currentPage;
  final List<ProductData> products;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  CategoryProductsPageData({
    this.currentPage,
    List<ProductData>? products,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    List<PaginationLink>? links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  })  : products = products ?? const [],
        links = links ?? const [];

  factory CategoryProductsPageData.fromJson(Map<String, dynamic> json) {
    return CategoryProductsPageData(
      currentPage: parseInt(json['current_page']),
      products: _parseProducts(json['data']),
      firstPageUrl: parseString(json['first_page_url']),
      from: parseInt(json['from']),
      lastPage: parseInt(json['last_page']),
      lastPageUrl: parseString(json['last_page_url']),
      links: _parseLinks(json['links']),
      nextPageUrl: parseString(json['next_page_url']),
      path: parseString(json['path']),
      perPage: parseInt(json['per_page']),
      prevPageUrl: parseString(json['prev_page_url']),
      to: parseInt(json['to']),
      total: parseInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'data': products.map((e) => e.toJson()).toList(),
    'first_page_url': firstPageUrl,
    'from': from,
    'last_page': lastPage,
    'last_page_url': lastPageUrl,
    'links': links.map((e) => e.toJson()).toList(),
    'next_page_url': nextPageUrl,
    'path': path,
    'per_page': perPage,
    'prev_page_url': prevPageUrl,
    'to': to,
    'total': total,
  };

  static List<ProductData> _parseProducts(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ProductData.fromJson)
        .toList();
  }

  static List<PaginationLink> _parseLinks(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(PaginationLink.fromJson)
        .toList();
  }
}

class PaginationLink {
  final String? url;
  final String? label;
  final bool? active;

  PaginationLink({
    this.url,
    this.label,
    this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: parseString(json['url']),
      label: parseString(json['label']),
      active: parseBool(json['active']),
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'active': active,
  };
}