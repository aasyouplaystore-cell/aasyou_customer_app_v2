import 'package:aasyou/config/helper.dart';

/// Response shape for the `send-email-verification-link` endpoint.
class SendEmailVerificationModel {
  final bool? success;
  final String? message;

  SendEmailVerificationModel({this.success, this.message});

  factory SendEmailVerificationModel.fromJson(Map<String, dynamic> json) {
    return SendEmailVerificationModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
    );
  }
}
