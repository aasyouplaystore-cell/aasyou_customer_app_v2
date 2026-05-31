import 'package:aasyou/config/helper.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';

class FeaturedSectionsResponse {
  final bool? success;
  final String? message;
  final FeaturedPageData? data;

  FeaturedSectionsResponse({
    this.success,
    this.message,
    this.data,
  });

  factory FeaturedSectionsResponse.fromJson(Map<String, dynamic> json) {
    return FeaturedSectionsResponse(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? FeaturedPageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class FeaturedPageData {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final List<FeaturedSectionData> sections;

  FeaturedPageData({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.sections = const [],
  });

  factory FeaturedPageData.fromJson(Map<String, dynamic> json) {
    return FeaturedPageData(
      currentPage: parseInt(json['current_page']),
      lastPage: parseInt(json['last_page']),
      perPage: parseInt(json['per_page']),
      total: parseInt(json['total']),
      sections: _parseSectionList(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'data': sections.map((e) => e.toJson()).toList(),
  };

  static List<FeaturedSectionData> _parseSectionList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(FeaturedSectionData.fromJson)
        .toList();
  }
}

class FeaturedSectionData {
  final int? id;
  final String? title;
  final String? slug;
  final String? shortDescription;
  final String? style;
  final String? sectionType;
  final int? sortOrder;
  final String? status;
  final String? scopeType;
  final int? scopeId;
  final String? scopeCategorySlug;
  final String? scopeCategoryTitle;
  final String? backgroundType;
  final String? backgroundColor;
  final String? desktop4kBackgroundImage;
  final String? desktopFdhBackgroundImage;
  final String? tabletBackgroundImage;
  final String? mobileBackgroundImage;
  final String? textColor;
  final List<Category> categories;
  final Category? scopeCategory;
  final List<ProductData> products;
  final int? productsCount;
  final String? createdAt;
  final String? updatedAt;

  FeaturedSectionData({
    this.id,
    this.title,
    this.slug,
    this.shortDescription,
    this.style,
    this.sectionType,
    this.sortOrder,
    this.status,
    this.scopeType,
    this.scopeId,
    this.scopeCategorySlug,
    this.scopeCategoryTitle,
    this.backgroundType,
    this.backgroundColor,
    this.desktop4kBackgroundImage,
    this.desktopFdhBackgroundImage,
    this.tabletBackgroundImage,
    this.mobileBackgroundImage,
    this.textColor,
    this.categories = const [],
    this.scopeCategory,
    this.products = const [],
    this.productsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory FeaturedSectionData.fromJson(Map<String, dynamic> json) {
    return FeaturedSectionData(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      shortDescription: parseString(json['short_description']),
      style: parseString(json['style']),
      sectionType: parseString(json['section_type']),
      sortOrder: parseInt(json['sort_order']),
      status: parseString(json['status']),
      scopeType: parseString(json['scope_type']),
      scopeId: parseInt(json['scope_id']),
      scopeCategorySlug: parseString(json['scope_category_slug']),
      scopeCategoryTitle: parseString(json['scope_category_title']),
      backgroundType: parseString(json['background_type']),
      backgroundColor: parseString(json['background_color']),
      desktop4kBackgroundImage: parseString(json['desktop_4k_background_image']),
      desktopFdhBackgroundImage: parseString(json['desktop_fdh_background_image']),
      tabletBackgroundImage: parseString(json['tablet_background_image']),
      mobileBackgroundImage: parseString(json['mobile_background_image']),
      textColor: parseString(json['text_color']),
      categories: _parseCategoryList(json['categories']),
      scopeCategory: json['scope_category'] != null
          ? Category.fromJson(json['scope_category'])
          : null,
      products: _parseProductList(json['products']),
      productsCount: parseInt(json['products_count']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'short_description': shortDescription,
    'style': style,
    'section_type': sectionType,
    'sort_order': sortOrder,
    'status': status,
    'scope_type': scopeType,
    'scope_id': scopeId,
    'scope_category_slug': scopeCategorySlug,
    'scope_category_title': scopeCategoryTitle,
    'background_type': backgroundType,
    'background_color': backgroundColor,
    'desktop_4k_background_image': desktop4kBackgroundImage,
    'desktop_fdh_background_image': desktopFdhBackgroundImage,
    'tablet_background_image': tabletBackgroundImage,
    'mobile_background_image': mobileBackgroundImage,
    'text_color': textColor,
    'categories': categories.map((e) => e.toJson()).toList(),
    if (scopeCategory != null) 'scope_category': scopeCategory!.toJson(),
    'products': products.map((e) => e.toJson()).toList(),
    'products_count': productsCount,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  static List<Category> _parseCategoryList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  static List<ProductData> _parseProductList(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ProductData.fromJson)
        .toList();
  }
}

// ────────────────────────────────────────────────

class Category {
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
  final int? parentId;
  final String? description;
  final String? status;
  final bool? requiresApproval;
  final Object? metadata;

  Category({
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
    this.parentId,
    this.description,
    this.status,
    this.requiresApproval,
    this.metadata,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
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
      parentId: parseInt(json['parent_id']),
      description: parseString(json['description']),
      status: parseString(json['status']),
      requiresApproval: parseBool(json['requires_approval']),
      metadata: json['metadata'],
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
    'parent_id': parentId,
    'description': description,
    'status': status,
    'requires_approval': requiresApproval,
    'metadata': metadata,
  };
}

// ────────────────────────────────────────────────

class FavoriteItem {
  final int? id;
  final int? wishlistId;
  final String? wishlistTitle;
  final int? variantId;
  final String? variantName;
  final int? storeId;
  final String? storeName;

  FavoriteItem({
    this.id,
    this.wishlistId,
    this.wishlistTitle,
    this.variantId,
    this.variantName,
    this.storeId,
    this.storeName,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: parseInt(json['id']),
      wishlistId: parseInt(json['wishlist_id']),
      wishlistTitle: parseString(json['wishlist_title']),
      variantId: parseInt(json['variant_id']),
      variantName: parseString(json['variant_name']),
      storeId: parseInt(json['store_id']),
      storeName: parseString(json['store_name']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'wishlist_id': wishlistId,
    'wishlist_title': wishlistTitle,
    'variant_id': variantId,
    'variant_name': variantName,
    'store_id': storeId,
    'store_name': storeName,
  };
}

class StoreStatus {
  final bool? isOpen;
  final String? currentSlot;
  final String? nextOpeningTime;

  StoreStatus({
    this.isOpen,
    this.currentSlot,
    this.nextOpeningTime,
  });

  factory StoreStatus.fromJson(Map<String, dynamic> json) {
    return StoreStatus(
      isOpen: parseBool(json['is_open']),
      currentSlot: parseString(json['current_slot']),
      nextOpeningTime: parseString(json['next_opening_time']),
    );
  }

  Map<String, dynamic> toJson() => {
    'is_open': isOpen,
    'current_slot': currentSlot,
    'next_opening_time': nextOpeningTime,
  };
}

class AttributesList {
  final String? name;
  final String? slug;
  final String? swatchType; // fixed typo: swatcheType → swatchType
  final List<String> values;
  final List<SwatchValue> swatchValues;

  AttributesList({
    this.name,
    this.slug,
    this.swatchType,
    this.values = const [],
    this.swatchValues = const [],
  });

  factory AttributesList.fromJson(Map<String, dynamic> json) {
    return AttributesList(
      name: parseString(json['name']),
      slug: parseString(json['slug']),
      swatchType: parseString(json['swatche_type']),
      values: (json['values'] as List<dynamic>?)?.cast<String>() ?? const [],
      swatchValues: _parseSwatchValues(json['swatch_values']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug,
    'swatche_type': swatchType,
    'values': values,
    'swatch_values': swatchValues.map((e) => e.toJson()).toList(),
  };

  static List<SwatchValue> _parseSwatchValues(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(SwatchValue.fromJson)
        .toList();
  }
}

class SwatchValue {
  final String? value;
  final String? swatch;

  SwatchValue({
    this.value,
    this.swatch,
  });

  factory SwatchValue.fromJson(Map<String, dynamic> json) {
    return SwatchValue(
      value: parseString(json['value']),
      swatch: parseString(json['swatch']),
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'swatch': swatch,
  };
}