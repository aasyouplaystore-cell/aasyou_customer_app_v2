
import '../../../config/helper.dart';

class CategoriesResponse {
  final bool? success;
  final String? message;
  final CategoriesPageData? data;

  CategoriesResponse({
    this.success,
    this.message,
    this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? CategoriesPageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class CategoriesPageData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final List<CategoryData> categories;

  CategoriesPageData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.categories = const [],
  });

  factory CategoriesPageData.fromJson(Map<String, dynamic> json) {
    return CategoriesPageData(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      categories: _parseCategoryList(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'data': categories.map((e) => e.toJson()).toList(),
  };

  static List<CategoryData> _parseCategoryList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(CategoryData.fromJson)
        .toList();
  }
}

/// Unified category model
class CategoryData {
  final int? id;
  final String? title;
  final String? slug;
  final String? image;
  final String? banner;
  final String? icon;
  final String? activeIcon;
  final String? backgroundType;
  final String? backgroundColor;
  final String? backgroundImage;
  final String? fontColor;
  final List<String>? searchLabels;
  final int? parentId;
  final String? commission;
  final String? parentSlug;
  final String? description;
  final String? status;
  final bool? requiresApproval;
  final Object? metadata;
  final int? subcategoryCount;
  final int? productCount;

  CategoryData({
    this.id,
    this.title,
    this.slug,
    this.image,
    this.banner,
    this.icon,
    this.activeIcon,
    this.backgroundType,
    this.backgroundColor,
    this.backgroundImage,
    this.fontColor,
    this.searchLabels,
    this.parentId,
    this.commission,
    this.parentSlug,
    this.description,
    this.status,
    this.requiresApproval,
    this.metadata,
    this.subcategoryCount,
    this.productCount,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      image: parseString(json['image']),
      banner: parseString(json['banner']),
      icon: parseString(json['icon']),
      activeIcon: parseString(json['active_icon']),
      backgroundType: parseString(json['background_type']),
      backgroundColor: parseString(json['background_color']),
      backgroundImage: parseString(json['background_image']),
      fontColor: parseString(json['font_color']),
      searchLabels: json['search_labels'].cast<String>(),
      parentId: parseInt(json['parent_id']),
      commission: parseString(json['commission']),
      parentSlug: parseString(json['parent_slug']),
      description: parseString(json['description']),
      status: parseString(json['status']),
      requiresApproval: parseBool(json['requires_approval']),
      metadata: json['metadata'],
      subcategoryCount: parseInt(json['subcategory_count']),
      productCount: parseInt(json['product_count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'image': image,
    'banner': banner,
    'icon': icon,
    'active_icon': activeIcon,
    'background_type': backgroundType,
    'background_color': backgroundColor,
    'background_image': backgroundImage,
    'font_color': fontColor,
    'search_labels': searchLabels,
    'parent_id': parentId,
    'commission': commission,
    'parent_slug': parentSlug,
    'description': description,
    'status': status,
    'requires_approval': requiresApproval,
    'metadata': metadata,
    'subcategory_count': subcategoryCount,
    'product_count': productCount,
  };
}