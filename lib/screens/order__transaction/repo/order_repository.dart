import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import '../../../config/helper.dart';

class OrderTransactionRepository {
  Future<Map<String, dynamic>> fetchOrderTransactions({
    required int perPage,
    required int page,
    String? search,
    String? paymentStatus,
  }) async {
    try {
      String url = '${ApiRoutes.orderTransactionsApi}?page=$page&per_page=$perPage';

      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        url += '&payment_status=$paymentStatus';
      }

      final response = await AppHelpers.apiBaseHelper.getAPICall(url, {});

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      } else {
        return {};
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}