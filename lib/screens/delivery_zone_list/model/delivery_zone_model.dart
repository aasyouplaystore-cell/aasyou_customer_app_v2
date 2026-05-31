import '../../../config/helper.dart';

class DeliveryZoneModel {
  bool? success;
  String? message;
  DeliveryZoneModelData? data;

  DeliveryZoneModel({this.success, this.message, this.data});

  DeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? DeliveryZoneModelData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class DeliveryZoneModelData {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  List<DeliveryZoneData>? data;

  DeliveryZoneModelData({this.currentPage, this.lastPage, this.perPage, this.total, this.data});

  DeliveryZoneModelData.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
    if (json['data'] != null) {
      data = <DeliveryZoneData>[];
      json['data'].forEach((v) {
        data!.add(DeliveryZoneData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryZoneData {
  int? id;
  String? name;
  String? slug;
  String? centerLatitude;
  String? centerLongitude;
  double? radiusKm;
  List<BoundaryJson>? boundaryJson;
  bool? rushDeliveryEnabled;
  int? deliveryTimePerKm;
  int? rushDeliveryTimePerKm;
  int? rushDeliveryCharges;
  int? regularDeliveryCharges;
  int? freeDeliveryAmount;
  int? distanceBasedDeliveryCharges;
  int? perStoreDropOffFee;
  int? handlingCharges;
  int? bufferTime;
  String? status;
  String? deliveryBoyBaseFee;
  String? deliveryBoyPerStorePickupFee;
  String? deliveryBoyDistanceBasedFee;
  String? deliveryBoyPerOrderIncentive;
  String? createdAt;
  String? updatedAt;

  DeliveryZoneData(
      {this.id,
        this.name,
        this.slug,
        this.centerLatitude,
        this.centerLongitude,
        this.radiusKm,
        this.boundaryJson,
        this.rushDeliveryEnabled,
        this.deliveryTimePerKm,
        this.rushDeliveryTimePerKm,
        this.rushDeliveryCharges,
        this.regularDeliveryCharges,
        this.freeDeliveryAmount,
        this.distanceBasedDeliveryCharges,
        this.perStoreDropOffFee,
        this.handlingCharges,
        this.bufferTime,
        this.status,
        this.deliveryBoyBaseFee,
        this.deliveryBoyPerStorePickupFee,
        this.deliveryBoyDistanceBasedFee,
        this.deliveryBoyPerOrderIncentive,
        this.createdAt,
        this.updatedAt});

  DeliveryZoneData.fromJson(Map<String, dynamic> json) {
    id = parseInt(json['id']);
    name = parseString(json['name']);
    slug = parseString(json['slug']);
    centerLatitude = parseString(json['center_latitude']);
    centerLongitude = parseString(json['center_longitude']);
    radiusKm = parseDouble(json['radius_km']);
    if (json['boundary_json'] != null) {
      boundaryJson = <BoundaryJson>[];
      json['boundary_json'].forEach((v) {
        boundaryJson!.add(BoundaryJson.fromJson(v));
      });
    }
    rushDeliveryEnabled = parseBool(json['rush_delivery_enabled']);
    deliveryTimePerKm = parseInt(json['delivery_time_per_km']);
    rushDeliveryTimePerKm = parseInt(json['rush_delivery_time_per_km']);
    rushDeliveryCharges = parseInt(json['rush_delivery_charges']);
    regularDeliveryCharges = parseInt(json['regular_delivery_charges']);
    freeDeliveryAmount = parseInt(json['free_delivery_amount']);
    distanceBasedDeliveryCharges = parseInt(json['distance_based_delivery_charges']);
    perStoreDropOffFee = parseInt(json['per_store_drop_off_fee']);
    handlingCharges = parseInt(json['handling_charges']);
    bufferTime = (json['buffer_time']);
    status = parseString(json['status']);
    deliveryBoyBaseFee = parseString(json['delivery_boy_base_fee']);
    deliveryBoyPerStorePickupFee = parseString(json['delivery_boy_per_store_pickup_fee']);
    deliveryBoyDistanceBasedFee = parseString(json['delivery_boy_distance_based_fee']);
    deliveryBoyPerOrderIncentive = parseString(json['delivery_boy_per_order_incentive']);
    createdAt = parseString(json['created_at']);
    updatedAt = parseString(json['updated_at']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['center_latitude'] = centerLatitude;
    data['center_longitude'] = centerLongitude;
    data['radius_km'] = radiusKm;
    if (boundaryJson != null) {
      data['boundary_json'] =
          boundaryJson!.map((v) => v.toJson()).toList();
    }
    data['rush_delivery_enabled'] = rushDeliveryEnabled;
    data['delivery_time_per_km'] = deliveryTimePerKm;
    data['rush_delivery_time_per_km'] = rushDeliveryTimePerKm;
    data['rush_delivery_charges'] = rushDeliveryCharges;
    data['regular_delivery_charges'] = regularDeliveryCharges;
    data['free_delivery_amount'] = freeDeliveryAmount;
    data['distance_based_delivery_charges'] = distanceBasedDeliveryCharges;
    data['per_store_drop_off_fee'] = perStoreDropOffFee;
    data['handling_charges'] = handlingCharges;
    data['buffer_time'] = bufferTime;
    data['status'] = status;
    data['delivery_boy_base_fee'] = deliveryBoyBaseFee;
    data['delivery_boy_per_store_pickup_fee'] =
        deliveryBoyPerStorePickupFee;
    data['delivery_boy_distance_based_fee'] = deliveryBoyDistanceBasedFee;
    data['delivery_boy_per_order_incentive'] =
        deliveryBoyPerOrderIncentive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class BoundaryJson {
  double? lat;
  double? lng;

  BoundaryJson({this.lat, this.lng});

  BoundaryJson.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}
