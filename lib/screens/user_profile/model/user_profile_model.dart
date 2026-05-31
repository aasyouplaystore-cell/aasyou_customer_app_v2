
import 'package:aasyou/config/helper.dart';

class UserProfileModel {
  final bool? success;
  final String? message;
  final UserData? data;

  UserProfileModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (data != null) 'data': data!.toJson(),
  };
}

class UserData {
  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? country;
  final String? iso2;
  final dynamic walletBalance;
  final String? referralCode;
  final String? friendsCode;
  final int? rewardPoints;
  final String? profileImage;
  final String? emailVerifiedAt;
  final String? mobileVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  UserData({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.country,
    this.iso2,
    this.walletBalance,
    this.referralCode,
    this.friendsCode,
    this.rewardPoints,
    this.profileImage,
    this.emailVerifiedAt,
    this.mobileVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      email: parseString(json['email']),
      mobile: parseString(json['mobile']),
      country: parseString(json['country']),
      iso2: parseString(json['iso_2']),
      walletBalance: json['wallet_balance'],
      referralCode: parseString(json['referral_code']),
      friendsCode: parseString(json['friends_code']),
      rewardPoints: parseInt(json['reward_points']),
      profileImage: parseString(json['profile_image']),
      emailVerifiedAt: parseString(json['email_verified_at']),
      mobileVerifiedAt: parseString(json['mobile_verified_at']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'country': country,
    'iso_2': iso2,
    'wallet_balance': walletBalance,
    'referral_code': referralCode,
    'friends_code': friendsCode,
    'reward_points': rewardPoints,
    'profile_image': profileImage,
    'email_verified_at': emailVerifiedAt,
    'mobile_verified_at': mobileVerifiedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

}