
import '../../../config/helper.dart';

class BannersResponse {
  final bool? success;
  final String? message;
  final BannerPageData? data;

  BannersResponse({
    this.success,
    this.message,
    this.data,
  });

  factory BannersResponse.fromJson(Map<String, dynamic> json) {
    return BannersResponse(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? BannerPageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class BannerPageData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final BannerGroups? groups;

  BannerPageData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.groups,
  });

  factory BannerPageData.fromJson(Map<String, dynamic> json) {
    return BannerPageData(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      groups: json['data'] != null ? BannerGroups.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    if (groups != null) 'data': groups!.toJson(),
  };
}

class BannerGroups {
  final List<BannerData> top;
  final List<BannerData> carousel;
  final List<BannerData> sidebar;

  BannerGroups({
    this.top = const [],
    this.carousel = const [],
    this.sidebar = const [],
  });

  factory BannerGroups.fromJson(Map<String, dynamic> json) {
    return BannerGroups(
      top: _parseBannerList(json['top']),
      carousel: _parseBannerList(json['carousel']),
      sidebar: _parseBannerList(json['sidebar']),
    );
  }

  Map<String, dynamic> toJson() => {
    'top': top.map((e) => e.toJson()).toList(),
    'carousel': carousel.map((e) => e.toJson()).toList(),
    'sidebar': sidebar.map((e) => e.toJson()).toList(),
  };

  static List<BannerData> _parseBannerList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(BannerData.fromJson)
        .toList();
  }
}

/// Single unified banner model — replaces Top / Carousel / Sidebar
class BannerData {
  final int? id;
  final String? type;
  final String? title;
  final String? scopeType;
  final int? scopeId;
  final String? scopeCategorySlug;
  final String? slug;
  final String? customUrl;
  final int? productId;
  final String? productSlug;
  final int? categoryId;
  final String? categorySlug;
  final int? brandId;
  final String? brandSlug;
  final String? position;
  final String? visibilityStatus;
  final int? displayOrder;
  final Object? metadata;
  final String? bannerImage;

  BannerData({
    this.id,
    this.type,
    this.title,
    this.scopeType,
    this.scopeId,
    this.scopeCategorySlug,
    this.slug,
    this.customUrl,
    this.productId,
    this.productSlug,
    this.categoryId,
    this.categorySlug,
    this.brandId,
    this.brandSlug,
    this.position,
    this.visibilityStatus,
    this.displayOrder,
    this.metadata,
    this.bannerImage,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: parseInt(json['id']),
      type: parseString(json['type']),
      title: parseString(json['title']),
      scopeType: parseString(json['scope_type']),
      scopeId: parseInt(json['scope_id']),
      scopeCategorySlug: parseString(json['scope_category_slug']),
      slug: parseString(json['slug']),
      customUrl: parseString(json['custom_url']),
      productId: parseInt(json['product_id']),
      productSlug: parseString(json['product_slug']),
      categoryId: parseInt(json['category_id']),
      categorySlug: parseString(json['category_slug']),
      brandId: parseInt(json['brand_id']),
      brandSlug: parseString(json['brand_slug']),
      position: parseString(json['position']),
      visibilityStatus: parseString(json['visibility_status']),
      displayOrder: parseInt(json['display_order']),
      metadata: json['metadata'],
      bannerImage: parseString(json['banner_image']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'scope_type': scopeType,
    'scope_id': scopeId,
    'scope_category_slug': scopeCategorySlug,
    'slug': slug,
    'custom_url': customUrl,
    'product_id': productId,
    'product_slug': productSlug,
    'category_id': categoryId,
    'category_slug': categorySlug,
    'brand_id': brandId,
    'brand_slug': brandSlug,
    'position': position,
    'visibility_status': visibilityStatus,
    'display_order': displayOrder,
    'metadata': metadata,
    'banner_image': bannerImage,
  };
}