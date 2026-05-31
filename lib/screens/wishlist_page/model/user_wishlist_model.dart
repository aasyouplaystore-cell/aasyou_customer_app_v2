
import 'package:aasyou/config/helper.dart';

class UserWishlistModel {
  final bool? success;
  final String? message;
  final UserWishlistData? data;

  UserWishlistModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserWishlistModel.fromJson(Map<String, dynamic> json) {
    return UserWishlistModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? UserWishlistData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class UserWishlistData {
  final int? currentPage;
  final List<WishlistData> wishlists;
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

  UserWishlistData({
    this.currentPage,
    List<WishlistData>? wishlists,
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
  })  : wishlists = wishlists ?? const [],
        links = links ?? const [];

  factory UserWishlistData.fromJson(Map<String, dynamic> json) {
    return UserWishlistData(
      currentPage: parseInt(json['current_page']),
      wishlists: _parseWishlists(json['data']),
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
    'data': wishlists.map((e) => e.toJson()).toList(),
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

  static List<WishlistData> _parseWishlists(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(WishlistData.fromJson)
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

class WishlistData {
  final int? id;
  final String? title;
  final String? slug;
  final int? itemsCount;
  final List<WishlistItem> items;
  final String? createdAt;
  final String? updatedAt;

  WishlistData({
    this.id,
    this.title,
    this.slug,
    this.itemsCount,
    List<WishlistItem>? items,
    this.createdAt,
    this.updatedAt,
  }) : items = items ?? const [];

  factory WishlistData.fromJson(Map<String, dynamic> json) {
    return WishlistData(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      itemsCount: parseInt(json['items_count']),
      items: _parseItems(json['items']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'items_count': itemsCount,
    'items': items.map((e) => e.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  static List<WishlistItem> _parseItems(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(WishlistItem.fromJson)
        .toList();
  }

  // Your existing copyWith method (updated to match new field names)
  WishlistData copyWith({
    int? id,
    String? title,
    String? slug,
    int? itemsCount,
    List<WishlistItem>? items,
    String? createdAt,
    String? updatedAt,
  }) {
    return WishlistData(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      itemsCount: itemsCount ?? this.itemsCount,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WishlistItem {
  final int? id;
  final int? wishlistId;
  final WishlistProduct? product;
  final WishlistVariant? variant;
  final Store? store;
  final String? createdAt;
  final String? updatedAt;

  WishlistItem({
    this.id,
    this.wishlistId,
    this.product,
    this.variant,
    this.store,
    this.createdAt,
    this.updatedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: parseInt(json['id']),
      wishlistId: parseInt(json['wishlist_id']),
      product: json['product'] != null ? WishlistProduct.fromJson(json['product']) : null,
      variant: json['variant'] != null ? WishlistVariant.fromJson(json['variant']) : null,
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'wishlist_id': wishlistId,
    if (product != null) 'product': product!.toJson(),
    if (variant != null) 'variant': variant!.toJson(),
    if (store != null) 'store': store!.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class WishlistProduct {
  final int? id;
  final String? title;
  final String? slug;
  final String? image;
  final String? shortDescription;

  WishlistProduct({
    this.id,
    this.title,
    this.slug,
    this.image,
    this.shortDescription,
  });

  factory WishlistProduct.fromJson(Map<String, dynamic> json) {
    return WishlistProduct(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      image: parseString(json['image']),
      shortDescription: parseString(json['short_description']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'image': image,
    'short_description': shortDescription,
  };
}

class WishlistVariant {
  final int? id;
  final String? sku;
  final String? image;
  final int? price;
  final int? specialPrice;
  final int? storeId;
  final String? storeSlug;
  final String? storeName;
  final int? stock;

  WishlistVariant({
    this.id,
    this.sku,
    this.image,
    this.price,
    this.specialPrice,
    this.storeId,
    this.storeSlug,
    this.storeName,
    this.stock,
  });

  factory WishlistVariant.fromJson(Map<String, dynamic> json) {
    return WishlistVariant(
      id: parseInt(json['id']),
      sku: parseString(json['sku']),
      image: parseString(json['image']),
      price: parseInt(json['price']),
      specialPrice: parseInt(json['special_price']),
      storeId: parseInt(json['store_id']),
      storeSlug: parseString(json['store_slug']),
      storeName: parseString(json['store_name']),
      stock: parseInt(json['stock']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'image': image,
    'price': price,
    'special_price': specialPrice,
    'store_id': storeId,
    'store_slug': storeSlug,
    'store_name': storeName,
    'stock': stock,
  };
}

class Store {
  final int? id;
  final String? name;
  final String? slug;

  Store({
    this.id,
    this.name,
    this.slug,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      slug: parseString(json['slug']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
  };
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