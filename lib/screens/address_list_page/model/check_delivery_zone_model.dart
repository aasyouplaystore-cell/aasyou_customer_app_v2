
import '../../../config/helper.dart';

class CheckDeliveryZoneModel {
  final bool? success;
  final String? message;
  final DeliveryZoneInfo? data;

  CheckDeliveryZoneModel({
    this.success,
    this.message,
    this.data,
  });

  factory CheckDeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    return CheckDeliveryZoneModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? DeliveryZoneInfo.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class DeliveryZoneInfo {
  final bool? isDeliverable;
  final int? zoneCount;
  final String? zone;
  final dynamic zoneId;
  final Coordinates? coordinates;

  DeliveryZoneInfo({
    this.isDeliverable,
    this.zoneCount,
    this.zone,
    this.zoneId,
    this.coordinates,
  });

  factory DeliveryZoneInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneInfo(
      isDeliverable: parseBool(json['is_deliverable']),
      zoneCount: parseInt(json['zone_count']),
      zone: parseString(json['zone']),
      zoneId: json['zone_id'],
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_deliverable': isDeliverable,
    'zone_count': zoneCount,
    'zone': zone,
    'zone_id': zoneId,
    if (coordinates != null) 'coordinates': coordinates!.toJson(),
  };
}

class Coordinates {
  final double? latitude;
  final double? longitude;

  Coordinates({
    this.latitude,
    this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };


  @override
  String toString() => 'Coordinates(lat: $latitude, lng: $longitude)';
}