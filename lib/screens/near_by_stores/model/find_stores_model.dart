import '../../../config/helper.dart';
import 'near_by_store_model.dart'; // parseInt, parseString, parseBool, parseDouble

class FindStoresModel {
  final bool? success;
  final String? message;
  final FindStoresData? data;

  FindStoresModel({
    this.success,
    this.message,
    this.data,
  });

  factory FindStoresModel.fromJson(Map<String, dynamic> json) {
    return FindStoresModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? FindStoresData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class FindStoresData {
  final int? count;
  final List<StoreData> stores;

  FindStoresData({
    this.count,
    List<StoreData>? stores,
  }) : stores = stores ?? const [];

  factory FindStoresData.fromJson(Map<String, dynamic> json) {
    return FindStoresData(
      count: parseInt(json['count']),
      stores: _parseStores(json['stores']),
    );
  }

  Map<String, dynamic> toJson() => {
    'count': count,
    'stores': stores.map((e) => e.toJson()).toList(),
  };

  static List<StoreData> _parseStores(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(StoreData.fromJson)
        .toList();
  }
}
