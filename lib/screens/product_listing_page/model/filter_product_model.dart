import 'package:aasyou/config/helper.dart';

class FilterProductModel {
  final bool? success;
  final String? message;
  final FilterProductData? data;

  FilterProductModel({
    this.success,
    this.message,
    this.data,
  });

  factory FilterProductModel.fromJson(Map<String, dynamic> json) {
    return FilterProductModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? FilterProductData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class FilterProductData {
  final int? categoriesCount;
  final int? brandsCount;
  final int? attributesCount;
  final List<FilterCategories> categories;
  final List<FilterBrands> brands;
  final List<FilterAttributesValues> attributes;

  FilterProductData({
    this.categoriesCount,
    this.brandsCount,
    this.attributesCount,
    List<FilterCategories>? categories,
    List<FilterBrands>? brands,
    List<FilterAttributesValues>? attributes,
  })  : categories = categories ?? const [],
        brands = brands ?? const [],
        attributes = attributes ?? const [];

  factory FilterProductData.fromJson(Map<String, dynamic> json) {
    return FilterProductData(
      categoriesCount: parseInt(json['categories_count']),
      brandsCount: parseInt(json['brands_count']),
      attributesCount: parseInt(json['attributes_count']),
      categories: _parseCategories(json['categories']),
      brands: _parseBrands(json['brands']),
      attributes: _parseAttributes(json['attributes']),
    );
  }

  Map<String, dynamic> toJson() => {
    'categories_count': categoriesCount,
    'brands_count': brandsCount,
    'attributes_count': attributesCount,
    'categories': categories.map((e) => e.toJson()).toList(),
    'brands': brands.map((e) => e.toJson()).toList(),
    'attributes': attributes.map((e) => e.toJson()).toList(),
  };

  static List<FilterCategories> _parseCategories(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(FilterCategories.fromJson)
        .toList();
  }

  static List<FilterBrands> _parseBrands(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(FilterBrands.fromJson)
        .toList();
  }

  static List<FilterAttributesValues> _parseAttributes(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(FilterAttributesValues.fromJson)
        .toList();
  }
}

// Renamed for clarity & consistency (was FilterCategories)
class FilterCategories {
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
  final int? parentId;
  final String? commission;
  final String? parentSlug;
  final String? description;
  final String? status;
  final bool? requiresApproval;
  final String? metadata;
  final int? subcategoryCount;
  final int? productCount;
  final bool? enabled;

  FilterCategories({
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
    this.parentId,
    this.commission,
    this.parentSlug,
    this.description,
    this.status,
    this.requiresApproval,
    this.metadata,
    this.subcategoryCount,
    this.productCount,
    this.enabled,
  });

  factory FilterCategories.fromJson(Map<String, dynamic> json) {
    return FilterCategories(
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
      parentId: parseInt(json['parent_id']),
      commission: parseString(json['commission']),
      parentSlug: parseString(json['parent_slug']),
      description: parseString(json['description']),
      status: parseString(json['status']),
      requiresApproval: parseBool(json['requires_approval']),
      metadata: parseString(json['metadata']),
      subcategoryCount: parseInt(json['subcategory_count']),
      productCount: parseInt(json['product_count']),
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
    'parent_id': parentId,
    'commission': commission,
    'parent_slug': parentSlug,
    'description': description,
    'status': status,
    'requires_approval': requiresApproval,
    'metadata': metadata,
    'subcategory_count': subcategoryCount,
    'product_count': productCount,
    'enabled': enabled,
  };
}

// Renamed for clarity & consistency (was FilterBrands)
class FilterBrands {
  final int? id;
  final String? title;
  final String? slug;
  final String? logo;
  final String? status;
  final String? scopeType;
  final int? scopeId;
  final String? scopeCategorySlug;
  final String? scopeCategoryTitle;
  final String? description;
  final String? metadata;
  final int? totalProducts;
  final bool? enabled;

  FilterBrands({
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
    this.totalProducts,
    this.enabled,
  });

  factory FilterBrands.fromJson(Map<String, dynamic> json) {
    return FilterBrands(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      logo: parseString(json['logo']),
      status: parseString(json['status']),
      scopeType: parseString(json['scope_type']),
      scopeId: parseInt(json['scope_id']),
      scopeCategorySlug: parseString(json['scope_category_slug']),
      scopeCategoryTitle: parseString(json['scope_category_title']),
      description: parseString(json['description']),
      metadata: parseString(json['metadata']),
      totalProducts: parseInt(json['total_products']),
      enabled: parseBool(json['enabled']),
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
    'total_products': totalProducts,
    'enabled': enabled,
  };
}

// Renamed for better readability (was FilterAttributesValues)
class FilterAttributesValues {
  final String? title;
  final String? slug;
  final List<AttributesValues> values;

  FilterAttributesValues({
    this.title,
    this.slug,
    List<AttributesValues>? values,
  }) : values = values ?? const [];

  factory FilterAttributesValues.fromJson(Map<String, dynamic> json) {
    return FilterAttributesValues(
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      values: _parseValues(json['values']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'slug': slug,
    'values': values.map((e) => e.toJson()).toList(),
  };

  static List<AttributesValues> _parseValues(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(AttributesValues.fromJson)
        .toList();
  }
}

class AttributesValues {
  final int? id;
  final String? title;
  final String? swatcheValue;
  final bool? enabled;

  AttributesValues({
    this.id,
    this.title,
    this.swatcheValue,
    this.enabled,
  });

  factory AttributesValues.fromJson(Map<String, dynamic> json) {
    return AttributesValues(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      swatcheValue: parseString(json['swatche_value']),
      enabled: parseBool(json['enabled']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'swatche_value': swatcheValue,
    'enabled': enabled,
  };
}