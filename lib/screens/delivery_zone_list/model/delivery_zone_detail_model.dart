class DeliveryZoneDetailModel {
  bool? success;
  String? message;
  DeliveryZoneDetailData? data;

  DeliveryZoneDetailModel({this.success, this.message, this.data});

  DeliveryZoneDetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? DeliveryZoneDetailData.fromJson(json['data']) : null;
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

class DeliveryZoneDetailData {
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

  DeliveryZoneDetailData(
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

  DeliveryZoneDetailData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    centerLatitude = json['center_latitude'];
    centerLongitude = json['center_longitude'];
    radiusKm = json['radius_km'];
    if (json['boundary_json'] != null) {
      boundaryJson = <BoundaryJson>[];
      json['boundary_json'].forEach((v) {
        boundaryJson!.add(BoundaryJson.fromJson(v));
      });
    }
    rushDeliveryEnabled = json['rush_delivery_enabled'];
    deliveryTimePerKm = json['delivery_time_per_km'];
    rushDeliveryTimePerKm = json['rush_delivery_time_per_km'];
    rushDeliveryCharges = json['rush_delivery_charges'];
    regularDeliveryCharges = json['regular_delivery_charges'];
    freeDeliveryAmount = json['free_delivery_amount'];
    distanceBasedDeliveryCharges = json['distance_based_delivery_charges'];
    perStoreDropOffFee = json['per_store_drop_off_fee'];
    handlingCharges = json['handling_charges'];
    bufferTime = json['buffer_time'];
    status = json['status'];
    deliveryBoyBaseFee = json['delivery_boy_base_fee'];
    deliveryBoyPerStorePickupFee = json['delivery_boy_per_store_pickup_fee'];
    deliveryBoyDistanceBasedFee = json['delivery_boy_distance_based_fee'];
    deliveryBoyPerOrderIncentive = json['delivery_boy_per_order_incentive'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
