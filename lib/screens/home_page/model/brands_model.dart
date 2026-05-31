
import '../../../config/helper.dart';

class BrandsResponse {
  final bool? success;
  final String? message;
  final BrandsPageData? data;

  BrandsResponse({
    this.success,
    this.message,
    this.data,
  });

  factory BrandsResponse.fromJson(Map<String, dynamic> json) {
    return BrandsResponse(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? BrandsPageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class BrandsPageData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final List<BrandData> brands;

  BrandsPageData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.brands = const [],
  });

  factory BrandsPageData.fromJson(Map<String, dynamic> json) {
    return BrandsPageData(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      brands: _parseBrandList(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'data': brands.map((e) => e.toJson()).toList(),
  };

  static List<BrandData> _parseBrandList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(BrandData.fromJson)
        .toList();
  }
}

/// Unified brand model
class BrandData {
  final int? id;
  final String? title;
  final String? slug;
  final String? logo;
  final String? status;
  final String? scopeType;
  final String? scopeId;
  final String? scopeCategorySlug;
  final String? scopeCategoryTitle;
  final String? description;
  final Object? metadata;

  BrandData({
    this.id,
    this.title,
    this.slug,
    this.logo,
    this.status,
    this.scopeType,
    this.scopeId,
    this.scopeCategorySlug,
    this.scopeCategoryTitle,
    this.description,
    this.metadata,
  });

  factory BrandData.fromJson(Map<String, dynamic> json) {
    return BrandData(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      logo: parseString(json['logo']),
      status: parseString(json['status']),
      scopeType: parseString(json['scope_type']),
      scopeId: parseString(json['scope_id']),      // ← was buggy in original
      scopeCategorySlug: parseString(json['scope_category_slug']),
      scopeCategoryTitle: parseString(json['scope_category_title']),
      description: parseString(json['description']),
      metadata: json['metadata'],                   // keep original value
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'logo': logo,
    'status': status,
    'scope_type': scopeType,
    'scope_id': scopeId,
    'scope_category_slug': scopeCategorySlug,
    'scope_category_title': scopeCategoryTitle,
    'description': description,
    'metadata': metadata,
  };
}