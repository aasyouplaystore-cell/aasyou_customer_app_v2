import '../../../config/helper.dart';

/// Response wrapper for /market-categories.
///
/// When the endpoint is called with a `slug` (detail mode), the backend
/// returns the children inside `data` AND a sibling `main_category_data`
/// describing the parent market category. When called without `slug`
/// (listing mode), only `data` is populated.
class MarketCategoriesResponse {
  final bool? success;
  final String? message;
  final MarketCategoriesPageData? data;
  final MarketCategoryData? mainCategoryData;

  MarketCategoriesResponse({
    this.success,
    this.message,
    this.data,
    this.mainCategoryData,
  });

  factory MarketCategoriesResponse.fromJson(Map<String, dynamic> json) {
    // main_category_data is nested INSIDE `data` per backend payload, but
    // tolerate root-level as a fallback for forward compatibility.
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;
    final mainRaw = (dataMap?['main_category_data'] is Map<String, dynamic>
            ? dataMap!['main_category_data']
            : json['main_category_data'])
        as Map<String, dynamic>?;
    return MarketCategoriesResponse(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: dataMap != null ? MarketCategoriesPageData.fromJson(dataMap) : null,
      mainCategoryData:
          mainRaw != null ? MarketCategoryData.fromJson(mainRaw) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (data != null) 'data': data!.toJson(),
        if (mainCategoryData != null)
          'main_category_data': mainCategoryData!.toJson(),
      };
}

class MarketCategoriesPageData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final List<MarketCategoryData> categories;

  MarketCategoriesPageData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.categories = const [],
  });

  factory MarketCategoriesPageData.fromJson(Map<String, dynamic> json) {
    return MarketCategoriesPageData(
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

  static List<MarketCategoryData> _parseCategoryList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(MarketCategoryData.fromJson)
        .toList();
  }
}

/// Market category model. Mirrors CategoryData but adds:
///   * [storeCount]   (from `store_count`)
///   * [enabled]      (from `enabled`)
/// and drops the seller `commission` field (markets don't carry a commission).
class MarketCategoryData {
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
  final String? parentSlug;
  final String? description;
  final String? status;
  final bool? requiresApproval;
  final Object? metadata;
  final int? subcategoryCount;
  final int? storeCount;
  final bool? enabled;

  MarketCategoryData({
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
    this.parentSlug,
    this.description,
    this.status,
    this.requiresApproval,
    this.metadata,
    this.subcategoryCount,
    this.storeCount,
    this.enabled,
  });

  factory MarketCategoryData.fromJson(Map<String, dynamic> json) {
    return MarketCategoryData(
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
      searchLabels: _parseStringList(json['search_labels']),
      parentId: parseInt(json['parent_id']),
      parentSlug: parseString(json['parent_slug']),
      description: parseString(json['description']),
      status: parseString(json['status']),
      requiresApproval: parseBool(json['requires_approval']),
      metadata: json['metadata'],
      subcategoryCount: parseInt(json['subcategory_count']),
      storeCount: parseInt(json['store_count']),
      enabled: parseBool(json['enabled']),
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
        'parent_slug': parentSlug,
        'description': description,
        'status': status,
        'requires_approval': requiresApproval,
        'metadata': metadata,
        'subcategory_count': subcategoryCount,
        'store_count': storeCount,
        'enabled': enabled,
      };

  MarketCategoryData copyWith({
    int? id,
    String? title,
    String? slug,
    String? image,
    String? banner,
    String? icon,
    String? activeIcon,
    String? backgroundType,
    String? backgroundColor,
    String? backgroundImage,
    String? fontColor,
    List<String>? searchLabels,
    int? parentId,
    String? parentSlug,
    String? description,
    String? status,
    bool? requiresApproval,
    Object? metadata,
    int? subcategoryCount,
    int? storeCount,
    bool? enabled,
  }) {
    return MarketCategoryData(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      banner: banner ?? this.banner,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      fontColor: fontColor ?? this.fontColor,
      searchLabels: searchLabels ?? this.searchLabels,
      parentId: parentId ?? this.parentId,
      parentSlug: parentSlug ?? this.parentSlug,
      description: description ?? this.description,
      status: status ?? this.status,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      metadata: metadata ?? this.metadata,
      subcategoryCount: subcategoryCount ?? this.subcategoryCount,
      storeCount: storeCount ?? this.storeCount,
      enabled: enabled ?? this.enabled,
    );
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value is Iterable) {
      return value
          .map((e) => e?.toString())
          .where((e) => e != null && e.isNotEmpty)
          .cast<String>()
          .toList();
    }
    return null;
  }
}

/// Mirrors the web `isCustomColor` helper: filter out pure black/white
/// defaults so callers can fall back to theme surface colors instead of
/// painting a hard #000/#fff background coming from the backend.
bool isCustomMarketCategoryColor(String? hex) {
  if (hex == null) return false;
  final v = hex.trim().toLowerCase();
  if (v.isEmpty) return false;
  const blacks = {'#000', '#000000', '#000000ff', '000', '000000'};
  const whites = {'#fff', '#ffffff', '#ffffffff', 'fff', 'ffffff'};
  if (blacks.contains(v)) return false;
  if (whites.contains(v)) return false;
  return true;
}
