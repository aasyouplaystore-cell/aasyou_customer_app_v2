
import '../../../config/helper.dart';

class NearbyStoresModel {
  final bool? success;
  final String? message;
  final NearbyStoresPageData? data;

  NearbyStoresModel({
    this.success,
    this.message,
    this.data,
  });

  factory NearbyStoresModel.fromJson(Map<String, dynamic> json) {
    return NearbyStoresModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? NearbyStoresPageData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class NearbyStoresPageData {
  final int? currentPage;
  final List<StoreData> stores;
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

  NearbyStoresPageData({
    this.currentPage,
    this.stores = const [],
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links = const [],
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory NearbyStoresPageData.fromJson(Map<String, dynamic> json) {
    return NearbyStoresPageData(
      currentPage: parseInt(json['current_page']),
      stores: _parseStores(json['data']),
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
    'data': stores.map((e) => e.toJson()).toList(),
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

  static List<StoreData> _parseStores(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(StoreData.fromJson)
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

class StoreData {
  final int? id;
  final String? name;
  final String? slug;
  final int? productCount;
  final String? description;
  final String? contactNumber;
  final String? contactEmail;
  final String? address;
  final String? latitude;
  final String? longitude;
  final double? distance;
  final String? timing;
  final String? logo;
  final String? banner;
  final bool? sameLocation;
  final String? createdAt;
  final String? updatedAt;
  final String? verificationStatus;
  final String? visibilityStatus;
  final StoreStatus? status;
  final String? avgProductsRating;
  final String? avgStoreRating;
  final int? totalStoreFeedback;
  final bool? isRecommended;

  StoreData({
    this.id,
    this.name,
    this.slug,
    this.productCount,
    this.description,
    this.contactNumber,
    this.contactEmail,
    this.address,
    this.latitude,
    this.longitude,
    this.distance,
    this.timing,
    this.logo,
    this.banner,
    this.sameLocation,
    this.createdAt,
    this.updatedAt,
    this.verificationStatus,
    this.visibilityStatus,
    this.status,
    this.avgProductsRating,
    this.avgStoreRating,
    this.totalStoreFeedback,
    this.isRecommended,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) {
    return StoreData(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      slug: parseString(json['slug']),
      productCount: parseInt(json['product_count']),
      description: parseString(json['description']),
      contactNumber: parseString(json['contact_number']),
      contactEmail: parseString(json['contact_email']),
      address: parseString(json['address']),
      latitude: parseString(json['latitude']),
      longitude: parseString(json['longitude']),
      distance: parseDouble(json['distance']),
      timing: parseString(json['timing']),
      logo: parseString(json['logo']),
      banner: parseString(json['banner']),
      sameLocation: parseBool(json['same_location']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
      verificationStatus: parseString(json['verification_status']),
      visibilityStatus: parseString(json['visibility_status']),
      status: json['status'] != null ? StoreStatus.fromJson(json['status']) : null,
      avgProductsRating: parseString(json['avg_products_rating']),
      avgStoreRating: parseString(json['avg_store_rating']),
      totalStoreFeedback: parseInt(json['total_store_feedback']),
      isRecommended: parseBool(json['is_recommended']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'product_count': productCount,
    'description': description,
    'contact_number': contactNumber,
    'contact_email': contactEmail,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'distance': distance,
    'timing': timing,
    'logo': logo,
    'banner': banner,
    'same_location': sameLocation,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'verification_status': verificationStatus,
    'visibility_status': visibilityStatus,
    if (status != null) 'status': status!.toJson(),
    'avg_products_rating': avgProductsRating,
    'avg_store_rating': avgStoreRating,
    'total_store_feedback': totalStoreFeedback,
    'is_recommended': isRecommended,
  };
}

class StoreStatus {
  final bool? isOpen;
  final String? status;

  StoreStatus({
    this.isOpen,
    this.status,
  });

  factory StoreStatus.fromJson(Map<String, dynamic> json) {
    return StoreStatus(
      isOpen: parseBool(json['is_open']),
      status: parseString(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'is_open': isOpen,
    'status': status,
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