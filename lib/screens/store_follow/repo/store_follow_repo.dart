import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';

import '../../../config/helper.dart';

/// Thin repository for the customer-facing Shop-Follow endpoints.
///
/// Backend contract (see StoreFollowApiController on the Laravel side):
///   - POST   /api/stores/{id}/follow   → idempotent firstOrCreate
///   - DELETE /api/stores/{id}/follow   → safe delete
///   - GET    /api/user/followed-stores → paginated follows for current user
///
/// Both write endpoints return:
///   { "success": true,
///     "message": "...",
///     "data": { "store_id": int, "is_followed": bool, "followers_count": int } }
///
/// All three routes sit behind `auth:sanctum`. ApiBaseHelper sends the
/// Bearer token via the shared `headers` map, so the caller does not have
/// to thread a token through.
class StoreFollowRepository {
  /// Follow a store. Server treats repeat calls as no-ops (idempotent).
  /// Returns the raw `data` map on success — callers should read
  /// `is_followed` and `followers_count` from it to refresh local state.
  Future<Map<String, dynamic>> followStore({required int storeId}) async {
    try {
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.followStoreApi(storeId),
        {},
      );
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        // Surface the inner data map for the caller; fall back to body
        // itself so a future API tweak doesn't break the UI silently.
        final data = body['data'];
        if (data is Map<String, dynamic>) return data;
        return body;
      }
      return {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Unfollow a store. Server is also tolerant of "not currently followed".
  Future<Map<String, dynamic>> unfollowStore({required int storeId}) async {
    try {
      final response = await AppHelpers.apiBaseHelper.deleteAPICall(
        ApiRoutes.followStoreApi(storeId),
        {},
      );
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final data = body['data'];
        if (data is Map<String, dynamic>) return data;
        return body;
      }
      return {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Paginated list of stores the current user follows. Mirrors the shape
  /// returned by the `index`-style store endpoints.
  Future<Map<String, dynamic>> getFollowedStores({
    int currentPage = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await AppHelpers.apiBaseHelper.getAPICall(
        '${ApiRoutes.followedStoresApi}?page=$currentPage&per_page=$perPage',
        {},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
