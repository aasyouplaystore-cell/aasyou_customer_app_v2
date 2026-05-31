import 'dart:developer' as developer;

import '../../../config/helper.dart';
import '../../home_page/model/featured_section_product_model.dart';

class ProductDetailModel {
  final bool success;
  final String message;
  final ProductData? data;

  ProductDetailModel({
    bool? success,
    String? message,
    this.data,
  })  : success = success ?? false,
        message = message ?? '';

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductDetailModel(
        success: parseBool(json['success']) ?? false,
        message: parseString(json['message']) ?? '',
        data: json['data'] != null ? ProductData.fromJson(json['data']) : null,
      );
    } catch (e, stack) {
      developer.log('Error parsing ProductDetailModel: $e', stackTrace: stack);
      return ProductDetailModel(success: false, message: 'Failed to parse');
    }
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class ProductData {
  final int id;
  final int categoryId;
  final int brandId;
  final int sellerId;
  final String title;
  final String slug;
  final String type;
  final String shortDescription;
  final String description;
  final String category;
  final String brand;
  final String seller;
  final String categoryName;
  final String brandName;
  final String indicator;
  final List<FavoriteItem> favorite;
  final String estimatedDeliveryTime;
  final double ratings;
  final int ratingCount;
  final String mainImage;
  final String imageFit;
  final String itemCountInCart;
  final List<String> additionalImages;
  final int minimumOrderQuantity;
  final int quantityStepSize;
  final int totalAllowedQuantity;
  final bool isReturnable;
  final List<String> tags;
  final List<CustomField> customFields;
  final String warrantyPeriod;
  final String guaranteePeriod;
  final String madeIn;
  final bool isInclusiveTax;
  final String videoType;
  final String videoLink;
  final String status;
  final String featured;
  final Badge? badge;
  final dynamic metadata;
  final String createdAt;
  final String updatedAt;
  final StoreStatus? storeStatus;
  final List<ProductVariants> variants;
  final List<ProductAttributes> attributes;
  final List<CustomProductFeaturedSections> customProductFeaturedSections;
  final bool isSponsored;
  final int campaignId;
  final String visitorKey;

  ProductData({
    int? id,
    int? categoryId,
    int? brandId,
    int? sellerId,
    String? title,
    String? slug,
    String? type,
    String? shortDescription,
    String? description,
    String? category,
    String? brand,
    String? seller,
    String? categoryName,
    String? brandName,
    String? indicator,
    List<FavoriteItem>? favorite,
    String? estimatedDeliveryTime,
    double? ratings,
    int? ratingCount,
    String? mainImage,
    String? imageFit,
    String? itemCountInCart,
    List<String>? additionalImages,
    int? minimumOrderQuantity,
    int? quantityStepSize,
    int? totalAllowedQuantity,
    bool? isReturnable,
    List<String>? tags,
    List<CustomField>? customFields,
    String? warrantyPeriod,
    String? guaranteePeriod,
    String? madeIn,
    bool? isInclusiveTax,
    String? videoType,
    String? videoLink,
    String? status,
    String? featured,
    this.badge,
    this.metadata,
    String? createdAt,
    String? updatedAt,
    this.storeStatus,
    List<ProductVariants>? variants,
    List<ProductAttributes>? attributes,
    List<CustomProductFeaturedSections>? customProductFeaturedSections,
    bool? isSponsored,
    int? campaignId,
    String? visitorKey,
  })  : id = id ?? 0,
        categoryId = categoryId ?? 0,
        brandId = brandId ?? 0,
        sellerId = sellerId ?? 0,
        title = title ?? '',
        slug = slug ?? '',
        type = type ?? '',
        shortDescription = shortDescription ?? '',
        description = description ?? '',
        category = category ?? '',
        brand = brand ?? '',
        seller = seller ?? '',
        categoryName = categoryName ?? '',
        brandName = brandName ?? '',
        indicator = indicator ?? '',
        favorite = favorite ?? const [],
        estimatedDeliveryTime = estimatedDeliveryTime ?? '',
        ratings = ratings ?? 0.0,
        ratingCount = ratingCount ?? 0,
        mainImage = mainImage ?? '',
        imageFit = imageFit ?? '',
        itemCountInCart = itemCountInCart ?? '0',
        additionalImages = additionalImages ?? const [],
        minimumOrderQuantity = minimumOrderQuantity ?? 0,
        quantityStepSize = quantityStepSize ?? 1,
        totalAllowedQuantity = totalAllowedQuantity ?? 0,
        isReturnable = isReturnable ?? false,
        tags = tags ?? const [],
        customFields = customFields ?? const [],
        warrantyPeriod = warrantyPeriod ?? '',
        guaranteePeriod = guaranteePeriod ?? '',
        madeIn = madeIn ?? '',
        isInclusiveTax = isInclusiveTax ?? false,
        videoType = videoType ?? '',
        videoLink = videoLink ?? '',
        status = status ?? '',
        featured = featured ?? '',
        createdAt = createdAt ?? '',
        updatedAt = updatedAt ?? '',
        variants = variants ?? const [],
        attributes = attributes ?? const [],
        customProductFeaturedSections = customProductFeaturedSections ?? const [],
        isSponsored = isSponsored ?? false,
        campaignId = campaignId ?? 0,
        visitorKey = visitorKey ?? '';


  factory ProductData.fromJson(Map<String, dynamic> json) {
    try {
      return ProductData(
        id: parseInt(json['id']),
        categoryId: parseInt(json['category_id']),
        brandId: parseInt(json['brand_id']),
        sellerId: parseInt(json['seller_id']),
        title: parseString(json['title']),
        slug: parseString(json['slug']),
        type: parseString(json['type']),
        shortDescription: parseString(json['short_description']),
        description: parseString(json['description']),
        category: parseString(json['category']),
        brand: parseString(json['brand']),
        seller: parseString(json['seller']),
        categoryName: parseString(json['category_name']),
        brandName: parseString(json['brand_name']),
        indicator: parseString(json['indicator']),
        favorite: _parseFavoriteItems(json['favorite']),
        estimatedDeliveryTime: parseString(json['estimated_delivery_time']) ?? '',
        ratings: parseDouble(json['ratings']) ?? 0.0,
        ratingCount: parseInt(json['rating_count']) ?? 0,
        mainImage: parseString(json['main_image']) ?? '',
        imageFit: parseString(json['image_fit']) ?? '',
        itemCountInCart: parseString(json['item_count_in_cart']) ?? '0',
        additionalImages: _parseStringList(json['additional_images']),
        minimumOrderQuantity: parseInt(json['minimum_order_quantity']) ?? 0,
        quantityStepSize: parseInt(json['quantity_step_size']) ?? 1,
        totalAllowedQuantity: parseInt(json['total_allowed_quantity']) ?? 0,
        isReturnable: parseBool(json['is_returnable']) ?? false,
        tags: _parseTags(json['tags']),
        customFields: _parseCustomFields(json['custom_fields']),
        warrantyPeriod: parseString(json['warranty_period']) ?? '',
        guaranteePeriod: parseString(json['guarantee_period']) ?? '',
        madeIn: parseString(json['made_in']) ?? '',
        isInclusiveTax: parseBool(json['is_inclusive_tax']) ?? false,
        videoType: parseString(json['video_type']) ?? '',
        videoLink: parseString(json['video_link']) ?? '',
        status: parseString(json['status']) ?? '',
        featured: parseString(json['featured']) ?? '',
        badge: json['badge'] != null ? Badge.fromJson(json['badge']) : null,
        metadata: json['metadata'],
        createdAt: parseString(json['created_at']) ?? '',
        updatedAt: parseString(json['updated_at']) ?? '',
        storeStatus: json['store_status'] != null
            ? StoreStatus.fromJson(json['store_status'])
            : null,
        variants: _parseVariants(json['variants']),
        attributes: _parseAttributes(json['attributes']),
        customProductFeaturedSections: _parseCustomProductFeaturedSections(json['custom_product_sections']),
        isSponsored: parseBool(json['is_sponsored']),
        campaignId: parseInt(json['campaign_id']),
        visitorKey: parseString(json['visitor_key']),
      );
    } catch (e, stack) {
      developer.log('Error parsing ProductData: $e', stackTrace: stack);
      return ProductData();
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'brand_id': brandId,
    'seller_id': sellerId,
    'title': title,
    'slug': slug,
    'type': type,
    'short_description': shortDescription,
    'description': description,
    'category': category,
    'brand': brand,
    'seller': seller,
    'category_name': categoryName,
    'brand_name': brandName,
    'indicator': indicator,
    if (favorite.isNotEmpty) 'favorite': favorite.map((e) => e.toJson()).toList(),
    'estimated_delivery_time': estimatedDeliveryTime,
    'ratings': ratings,
    'rating_count': ratingCount,
    'main_image': mainImage,
    'image_fit': imageFit,
    'item_count_in_cart': itemCountInCart,
    'additional_images': additionalImages,
    'minimum_order_quantity': minimumOrderQuantity,
    'quantity_step_size': quantityStepSize,
    'total_allowed_quantity': totalAllowedQuantity,
    'is_returnable': isReturnable,
    'tags': tags,
    'custom_fields': customFields.map((e) => {'key': e.key, 'value': e.value}).toList(),
    'warranty_period': warrantyPeriod,
    'guarantee_period': guaranteePeriod,
    'made_in': madeIn,
    'is_inclusive_tax': isInclusiveTax,
    'video_type': videoType,
    'video_link': videoLink,
    'status': status,
    'featured': featured,
    if (badge != null) 'badge': badge!.toJson(),
    'metadata': metadata,
    'created_at': createdAt,
    'updated_at': updatedAt,
    if (storeStatus != null) 'store_status': storeStatus!.toJson(),
    'variants': variants.map((e) => e.toJson()).toList(),
    'attributes': attributes.map((e) => e.toJson()).toList(),

    if (customProductFeaturedSections.isNotEmpty)
      'custom_product_featured_sections':
      customProductFeaturedSections.map((e) => e.toJson()).toList(),
    'is_sponsored': isSponsored,
    'campaign_id': campaignId,
    'visitor_key': visitorKey
  };

  static List<FavoriteItem> _parseFavoriteItems(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(FavoriteItem.fromJson)
        .toList();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is String) {
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    if (value is Iterable) {
      return value.whereType<String>().where((e) => e.trim().isNotEmpty).toList();
    }
    return const [];
  }

  static List<String> _parseTags(dynamic value) {
    return _parseStringList(value);
  }

  static List<CustomField> _parseCustomFields(dynamic value) {
    if (value is! Map<String, dynamic>) return const [];
    return value.entries.map((e) => CustomField(key: e.key, value: e.value)).toList();
  }

  static List<ProductVariants> _parseVariants(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ProductVariants.fromJson)
        .toList();
  }

  static List<ProductAttributes> _parseAttributes(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ProductAttributes.fromJson)
        .toList();
  }

  static List<CustomProductFeaturedSections> _parseCustomProductFeaturedSections(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(CustomProductFeaturedSections.fromJson)
        .toList();
  }
}

class StoreStatus {
  final bool isOpen;
  final CurrentSlot? currentSlot;
  final String nextOpeningTime;

  StoreStatus({
    bool? isOpen,
    this.currentSlot,
    String? nextOpeningTime,
  })  : isOpen = isOpen ?? false,
        nextOpeningTime = nextOpeningTime ?? '';

  factory StoreStatus.fromJson(Map<String, dynamic> json) {
    return StoreStatus(
      isOpen: parseBool(json['is_open']) ?? false,
      currentSlot: json['current_slot'] != null
          ? CurrentSlot.fromJson(json['current_slot'])
          : null,
      nextOpeningTime: parseString(json['next_opening_time']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'is_open': isOpen,
    if (currentSlot != null) 'current_slot': currentSlot!.toJson(),
    'next_opening_time': nextOpeningTime,
  };
}

class CurrentSlot {
  final String from;
  final String to;

  CurrentSlot({
    String? from,
    String? to,
  })  : from = from ?? '',
        to = to ?? '';

  factory CurrentSlot.fromJson(Map<String, dynamic> json) {
    return CurrentSlot(
      from: parseString(json['from']) ?? '',
      to: parseString(json['to']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
  };
}

class CustomField {
  final String key;
  final dynamic value;

  CustomField({required this.key, required this.value});

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}

class ProductVariants {
  final int id;
  final String title;
  final String slug;
  final String image;
  final int weight;
  final int height;
  final int breadth;
  final int length;
  final bool availability;
  final String barcode;
  final bool isDefault;
  final double price;
  final double specialPrice;
  final int storeId;
  final String storeSlug;
  final String storeName;
  final int stock;
  final String sku;
  final Map<String, dynamic> attributes;
  final List<AddonGroup> addonGroups;

  ProductVariants({
    int? id,
    String? title,
    String? slug,
    String? image,
    int? weight,
    int? height,
    int? breadth,
    int? length,
    bool? availability,
    String? barcode,
    bool? isDefault,
    double? price,
    double? specialPrice,
    int? storeId,
    String? storeSlug,
    String? storeName,
    int? stock,
    String? sku,
    Map<String, dynamic>? attributes,
    List<AddonGroup>? addonGroups,
  })  : id = id ?? 0,
        title = title ?? '',
        slug = slug ?? '',
        image = image ?? '',
        weight = weight ?? 0,
        height = height ?? 0,
        breadth = breadth ?? 0,
        length = length ?? 0,
        availability = availability ?? false,
        barcode = barcode ?? '',
        isDefault = isDefault ?? false,
        price = price ?? 0.0,
        specialPrice = specialPrice ?? 0.0,
        storeId = storeId ?? 0,
        storeSlug = storeSlug ?? '',
        storeName = storeName ?? '',
        stock = stock ?? 0,
        sku = sku ?? '',
        attributes = attributes ?? const {},
        addonGroups = addonGroups ?? const [];

  factory ProductVariants.fromJson(Map<String, dynamic> json) {
    return ProductVariants(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      image: parseString(json['image']),
      weight: parseInt(json['weight']) ?? 0,
      height: parseInt(json['height']) ?? 0,
      breadth: parseInt(json['breadth']) ?? 0,
      length: parseInt(json['length']) ?? 0,
      availability: parseBool(json['availability']) ?? false,
      barcode: parseString(json['barcode']) ?? '',
      isDefault: parseBool(json['is_default']) ?? false,
      price: parseDouble(json['price'].toString()) ?? 0.0,
      specialPrice: parseDouble(json['special_price'].toString()) ?? 0.0,
      storeId: parseInt(json['store_id']) ?? 0,
      storeSlug: parseString(json['store_slug']) ?? '',
      storeName: parseString(json['store_name']) ?? '',
      stock: parseInt(json['stock']) ?? 0,
      sku: parseString(json['sku']) ?? '',
      attributes: json['attributes'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['attributes'])
          : const {},
      addonGroups: _parseAddonGroups(json['addon_groups']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'image': image,
    'weight': weight,
    'height': height,
    'breadth': breadth,
    'length': length,
    'availability': availability,
    'barcode': barcode,
    'is_default': isDefault,
    'price': price,
    'special_price': specialPrice,
    'store_id': storeId,
    'store_slug': storeSlug,
    'store_name': storeName,
    'stock': stock,
    'sku': sku,
    'attributes': attributes,
    'addon_groups': addonGroups.map((e) => e.toJson()).toList(),
  };

  static List<AddonGroup> _parseAddonGroups(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(AddonGroup.fromJson)
        .toList();
  }
}

/// A group of addon items attached to a product variant.
class AddonGroup {
  final int id;
  final String uuid;
  final String title;
  final String slug;
  final String selectionType; // "single" | "multiple"
  final bool isRequired;
  final int sortOrder;
  final List<AddonItem> items;

  AddonGroup({
    int? id,
    String? uuid,
    String? title,
    String? slug,
    String? selectionType,
    bool? isRequired,
    int? sortOrder,
    List<AddonItem>? items,
  })  : id = id ?? 0,
        uuid = uuid ?? '',
        title = title ?? '',
        slug = slug ?? '',
        selectionType = selectionType ?? '',
        isRequired = isRequired ?? false,
        sortOrder = sortOrder ?? 0,
        items = items ?? const [];

  factory AddonGroup.fromJson(Map<String, dynamic> json) {
    return AddonGroup(
      id: parseInt(json['id']) ?? 0,
      uuid: parseString(json['uuid']) ?? '',
      title: parseString(json['title']) ?? '',
      slug: parseString(json['slug']) ?? '',
      selectionType: parseString(json['selection_type']) ?? '',
      isRequired: parseBool(json['is_required']) ?? false,
      sortOrder: parseInt(json['sort_order']) ?? 0,
      items: _parseAddonItems(json['items']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'title': title,
    'slug': slug,
    'selection_type': selectionType,
    'is_required': isRequired,
    'sort_order': sortOrder,
    'items': items.map((e) => e.toJson()).toList(),
  };

  static List<AddonItem> _parseAddonItems(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(AddonItem.fromJson)
        .toList();
  }
}

/// An individual addon item inside an [AddonGroup].
class AddonItem {
  final int id;
  final String uuid;
  final String title;
  final String slug;
  final String indicator; // "veg" | "non-veg" | ""
  final double price;
  final double cost;
  final int stock;
  final bool isAvailable;

  AddonItem({
    int? id,
    String? uuid,
    String? title,
    String? slug,
    String? indicator,
    double? price,
    double? cost,
    int? stock,
    bool? isAvailable,
  })  : id = id ?? 0,
        uuid = uuid ?? '',
        title = title ?? '',
        slug = slug ?? '',
        indicator = indicator ?? '',
        price = price ?? 0.0,
        cost = cost ?? 0.0,
        stock = stock ?? 0,
        isAvailable = isAvailable ?? false;

  factory AddonItem.fromJson(Map<String, dynamic> json) {
    return AddonItem(
      id: parseInt(json['id']) ?? 0,
      uuid: parseString(json['uuid']) ?? '',
      title: parseString(json['title']) ?? '',
      slug: parseString(json['slug']) ?? '',
      indicator: parseString(json['indicator']) ?? '',
      price: parseDouble(json['price'].toString()) ?? 0.0,
      cost: parseDouble(json['cost'].toString()) ?? 0.0,
      stock: parseInt(json['stock']) ?? 0,
      isAvailable: parseBool(json['is_available']) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'title': title,
    'slug': slug,
    'indicator': indicator,
    'price': price,
    'cost': cost,
    'stock': stock,
    'is_available': isAvailable,
  };
}

class ProductAttributes {
  final String name;
  final String slug;
  final String swatcheType;
  final List<String> values;
  final List<SwatchValues> swatchValues;

  ProductAttributes({
    String? name,
    String? slug,
    String? swatcheType,
    List<String>? values,
    List<SwatchValues>? swatchValues,
  })  : name = name ?? '',
        slug = slug ?? '',
        swatcheType = swatcheType ?? '',
        values = values ?? const [],
        swatchValues = swatchValues ?? const [];

  factory ProductAttributes.fromJson(Map<String, dynamic> json) {
    return ProductAttributes(
      name: parseString(json['name']),
      slug: parseString(json['slug']),
      swatcheType: parseString(json['swatche_type']),
      values: (json['values'] as List<dynamic>?)?.cast<String>() ?? const [],
      swatchValues: _parseSwatchValues(json['swatch_values']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug,
    'swatche_type': swatcheType,
    'values': values,
    'swatch_values': swatchValues.map((e) => e.toJson()).toList(),
  };

  static List<SwatchValues> _parseSwatchValues(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(SwatchValues.fromJson)
        .toList();
  }
}

class SwatchValues {
  final String value;
  final String swatch;

  SwatchValues({
    String? value,
    String? swatch,
  })  : value = value ?? '',
        swatch = swatch ?? '';

  factory SwatchValues.fromJson(Map<String, dynamic> json) {
    return SwatchValues(
      value: parseString(json['value']) ?? '',
      swatch: parseString(json['swatch']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'swatch': swatch,
  };
}

class CustomProductFeaturedSections {
  int? id;
  String? uuid;
  String? title;
  String? description;
  int? sortOrder;
  List<ProductFeaturedSectionFields>? fields;

  CustomProductFeaturedSections(
      {this.id,
        this.uuid,
        this.title,
        this.description,
        this.sortOrder,
        this.fields});

  CustomProductFeaturedSections.fromJson(Map<String, dynamic> json) {
    id = parseInt(json['id']);
    uuid = parseString(json['uuid']);
    title = parseString(json['title']);
    description = parseString(json['description']);
    sortOrder = parseInt(json['sort_order']);
    if (json['fields'] != null) {
      fields = <ProductFeaturedSectionFields>[];
      json['fields'].forEach((v) {
        fields!.add(ProductFeaturedSectionFields.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['title'] = title;
    data['description'] = description;
    data['sort_order'] = sortOrder;
    if (fields != null) {
      data['fields'] = fields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductFeaturedSectionFields {
  int? id;
  String? uuid;
  String? title;
  String? description;
  String? image;
  int? sortOrder;

  ProductFeaturedSectionFields(
      {this.id,
        this.uuid,
        this.title,
        this.description,
        this.image,
        this.sortOrder});

  ProductFeaturedSectionFields.fromJson(Map<String, dynamic> json) {
    id = parseInt(json['id']);
    uuid = parseString(json['uuid']);
    title = parseString(json['title']);
    description = parseString(json['description']);
    image = parseString(json['image']);
    sortOrder = parseInt(json['sort_order']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['sort_order'] = sortOrder;
    return data;
  }
}

class Badge {
  int? id;
  String? label;
  String? bgColor;
  String? textColor;
  String? borderColor;

  Badge({this.id, this.label, this.bgColor, this.textColor, this.borderColor});

  Badge.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    bgColor = json['bg_color'];
    textColor = json['text_color'];
    borderColor = json['border_color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    data['bg_color'] = bgColor;
    data['text_color'] = textColor;
    data['border_color'] = borderColor;
    return data;
  }
}