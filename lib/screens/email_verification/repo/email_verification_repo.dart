import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/screens/email_verification/model/send_email_verification_model.dart';

import '../../../config/global.dart';

class EmailVerificationRepository {

  Future<SendEmailVerificationModel> sendVerificationEmail({
    required String email,
  }) async {
    try {
      final apiUrl = Global.userData!.emailVerified!.isNotEmpty ? ApiRoutes.sendEmailVerificationLinkApi : ApiRoutes.resendEmailVerificationLinkApi;
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        apiUrl,
        {'email': email},
      );

      if (response.data is Map<String, dynamic>) {
        final model = SendEmailVerificationModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (model.success == true) {
          return model;
        }
        throw ApiException(
          model.message ?? 'Failed to send verification email',
        );
      }
      throw ApiException('Failed to send verification email');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}
