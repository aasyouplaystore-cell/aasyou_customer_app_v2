import 'dart:convert';
import 'dart:developer';

import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';

import '../../../config/helper.dart';
import '../../../services/location/location_service.dart';
import '../model/store_detail_model.dart';

class NearByStoreRepo {
  Future<Map<String, dynamic>?> getNearByStores({
    int page = 1,
    int perPage = 15,
    required String searchQuery,
  }) async {
    try {
      final locationService = LocationService.getStoredLocation();
      if (locationService == null) {
        return null;
      }

      final latitude = locationService.latitude;
      final longitude = locationService.longitude;

      final Map<String, dynamic> query = {
        'latitude': latitude,
        'longitude': longitude,
        'page': page.toString(),
        'per_page': perPage.toString(),
        if(searchQuery.isNotEmpty)
          'search': searchQuery
      };

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        ApiRoutes.nearByStores,
        query,
      );

      // Extract .data and ensure it's a Map
      dynamic data = response.data;

      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        log('API SUCCESS: Stores fetched');
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<StoreDetailModel>> fetchStoreDetail({required String storeSlug}) async {
    try{
      final locationService = LocationService.getStoredLocation();
      final latitude = locationService!.latitude;
      final longitude = locationService.longitude;

      final response = await AppHelpers.apiBaseHelper.getAPICall(
        '${ApiRoutes.storeDetailApi}$storeSlug?latitude=$latitude&longitude=$longitude',
        {}
      );
      if(response.statusCode == 200) {
        List<StoreDetailModel> storeData = [];
        storeData.add(StoreDetailModel.fromJson(response.data));
        return storeData;
      } else {
        return [];
      }
    }catch(e) {

      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> findStoresReq({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
    required double userLat,
    required double userLng,
  }) async {
    try{
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.findStoresApi,
        {
          'ne_lat': neLat,
          'ne_lng': neLng,
          'sw_lat': swLat,
          'sw_lng': swLng,
          'latitude': userLat,
          'longitude': userLng,
        },
      );

      if(response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(response.data['message'] ?? '');
      }
    }catch(e) {
      throw ApiException(e.toString());
    }
  }
}