import 'package:aasyou/config/helper.dart';

class AppVersionModel {
  bool? success;
  String? message;
  AppVersionData? data;

  AppVersionModel({this.success, this.message, this.data});

  AppVersionModel.fromJson(Map<String, dynamic> json) {
    success = parseBool(json['success']);
    message = parseString(json['message']);
    data = json['data'] != null ? AppVersionData.fromJson(json['data']) : null;
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

class AppVersionData {
  bool? updateAvailable;
  String? updateType;
  String? minSupportedVersion;
  String? latestVersion;
  String? message;
  String? updateUrl;

  AppVersionData(
      {this.updateAvailable,
        this.updateType,
        this.minSupportedVersion,
        this.latestVersion,
        this.message,
        this.updateUrl});

  AppVersionData.fromJson(Map<String, dynamic> json) {
    updateAvailable = parseBool(json['update_available']);
    updateType = parseString(json['update_type']);
    minSupportedVersion = parseString(json['min_supported_version']);
    latestVersion = parseString(json['latest_version']);
    message = parseString(json['message']);
    updateUrl = parseString(json['update_url']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['update_available'] = updateAvailable;
    data['update_type'] = updateType;
    data['min_supported_version'] = minSupportedVersion;
    data['latest_version'] = latestVersion;
    data['message'] = message;
    data['update_url'] = updateUrl;
    return data;
  }
}
