import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import '../../../config/helper.dart';

class NotificationRepository {
  /// Fetches a page of notifications from the API
  Future<Map<String, dynamic>> fetchNotifications({
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await AppHelpers.apiBaseHelper.getAPICall(
        '${ApiRoutes.notificationsApi}?page=$page&per_page=$perPage',
        {},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(response.data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Marks a specific notification as read
  Future<Map<String, dynamic>> markAsRead(String id) async {
    try {
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.markNotificationAsReadApi(id),
        {},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(
            response.data['message'] ?? 'Failed to mark as read');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Marks all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.markAllNotificationsAsReadApi,
        {},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(
            response.data['message'] ?? 'Failed to mark all as read');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
