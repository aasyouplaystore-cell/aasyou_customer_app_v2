import '../../../config/helper.dart';

class AuthModel {
  final bool? success;
  final String? message;
  final String? accessToken;
  final String? tokenType;
  final UserData? user;

  AuthModel({
    this.success,
    this.message,
    this.accessToken,
    this.tokenType,
    this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      success: parseBool(json['success']),
      message: parseString(json['message']),
      accessToken: parseString(json['access_token']),
      tokenType: parseString(json['token_type']),

      user: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'access_token': accessToken,
    'token_type': tokenType,
    if (user != null) 'data': user!.toJson(),
  };
}

class UserData {
  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? country;
  final String? iso2;
  final int? walletBalance;
  final String? referralCode;
  final String? friendsCode;
  final int? rewardPoints;
  final String? profileImage;
  final String? emailVerifiedAt;
  final String? mobileVerifiedAt;
  final String? loggedInType;
  final String? createdAt;
  final String? updatedAt;
  final bool? isRegister;

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
    this.loggedInType,
    this.createdAt,
    this.updatedAt,
    this.isRegister,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      email: parseString(json['email']),
      mobile: parseString(json['mobile']),
      country: parseString(json['country']),
      iso2: parseString(json['iso_2']),
      walletBalance: parseInt(json['wallet_balance']),
      referralCode: parseString(json['referral_code']),
      friendsCode: parseString(json['friends_code']),
      rewardPoints: parseInt(json['reward_points']),
      profileImage: parseString(json['profile_image']),
      emailVerifiedAt: parseString(json['email_verified_at']),
      mobileVerifiedAt: parseString(json['mobile_verified_at']),
      loggedInType: parseString(json['logged_in_type']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
      isRegister: parseBool(json['is_register']),
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
    'logged_in_type': loggedInType,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'is_register': isRegister,
  };

}