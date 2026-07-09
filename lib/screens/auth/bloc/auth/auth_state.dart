import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthFailed extends AuthState {
  final String error;

  /// Machine-readable failure kind for UI decisions (null = generic).
  /// Known values: 'invalid-otp', 'session-expired', 'network'.
  final String? errorCode;
  AuthFailed({required this.error, this.errorCode});
  @override
  List<Object?> get props => [error, errorCode];
}

class RegistrationDataStored extends AuthState {
  final Map<String, dynamic> registrationData;
  final String phoneNumber;
  final String countryCode;
  final String isoCode;

  RegistrationDataStored({
    required this.registrationData,
    required this.phoneNumber,
    required this.countryCode,
    required this.isoCode,
  });

  @override
  List<Object?> get props =>
      [registrationData, phoneNumber, countryCode, isoCode];
}

class LogoutUser extends AuthState {}

class DeleteUserSuccess extends AuthState {}

class OTPLoading extends AuthState {}

class VerifyingOTP extends AuthState {}

class OTPVerified extends AuthState {
  final String message;
  OTPVerified({required this.message});
  @override
  List<Object?> get props => [message];
}

class OTPFailed extends AuthState {
  final String error;
  OTPFailed({required this.error});
  @override
  List<Object?> get props => [error];
}

class LoginCodeSentProgress extends AuthState {
  final Map<String, dynamic>? registrationData;
  final String? phoneNumber;
  final String? countryCode;
  final String? isoCode;
  final bool isLogin;

  LoginCodeSentProgress({
    this.registrationData,
    this.phoneNumber,
    this.countryCode,
    this.isoCode,
    this.isLogin = false,
  });

  @override
  List<Object?> get props =>
      [registrationData, phoneNumber, countryCode, isoCode, isLogin];
}

class LoginPhoneCodeSentState extends AuthState {
  final String? verificationId;
  final Map<String, dynamic>? registrationData;
  final String? phoneNumber;
  final String? countryCode;
  final String? isoCode;
  final bool isLogin;

  LoginPhoneCodeSentState({
    this.verificationId,
    this.registrationData,
    this.phoneNumber,
    this.countryCode,
    this.isoCode,
    this.isLogin = false,
  });

  @override
  List<Object?> get props => [
        verificationId,
        registrationData,
        phoneNumber,
        countryCode,
        isoCode,
        isLogin,
      ];
}

class SocialAuthSuccess extends AuthState {
  final bool isRegister;
  final String? message;

  SocialAuthSuccess({this.isRegister = false, this.message});

  @override
  List<Object?> get props => [isRegister, message];
}
