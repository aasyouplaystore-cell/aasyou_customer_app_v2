import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/notification_service.dart';
import 'package:aasyou/model/user_data_model/user_data_model.dart';
import 'package:aasyou/screens/auth/repo/auth_repo.dart';
import '../../../../bloc/user_details_bloc/user_details_bloc.dart';
import '../../../../bloc/user_details_bloc/user_details_event.dart';
import '../../model/auth_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository = AuthRepository();
  final UserDataBloc _userDetailBloc;

  Map<String, dynamic>? _pendingRegistrationData;
  String? _pendingPhoneNumber;
  String? _pendingCountryCode;
  String? _pendingIsoCode;
  int? _lastResendToken;

  // Firebase phone auth fires BOTH verificationCompleted (auto-retrieval) and
  // the manual submit path for the same credential; signing in twice consumes
  // the credential and surfaces session-expired. Guard so only one sign-in
  // runs per sent code; reset on a fresh send/resend or on failure.
  bool _phoneCredentialInFlight = false;

  AuthBloc(this._userDetailBloc) : super(AuthInitial()) {
    on<LoginRequest>(_onLoginRequest);
    on<RegisterRequest>(_onRegisterRequest);
    on<LogoutUserRequest>(_onLogoutUserRequest);
    on<DeleteUserRequest>(_onDeleteUserRequest);
    on<SendOtpToPhoneEvent>(_onSendOtpToPhone);
    on<VerifySentOtp>(_onVerifySentOtp);
    on<OnPhoneOtpSend>(_onPhoneOtpSent);
    on<OnPhoneAuthVerificationCompleted>(_onPhoneAuthVerified);
    on<CompleteMobileOtpLogin>(_onCompleteMobileOtpLogin);
    on<ResendOtpRequest>(_onResendOtp);
    on<AuthFailureEvent>(_onAuthFailureEvent);
    on<SocialAuthRequest>(_onSocialAuthRequest);
    on<GoogleLoginRequest>(_onGoogleLoginRequest);
    on<AppleLoginRequest>(_onAppleLoginRequest);
    on<StoreRegistrationDataEvent>(_onStoreRegistrationData);
    on<ClearRegistrationDataEvent>(_onClearRegistrationData);
    on<DeleteUserAccount>(_onDeleteUserAccount);
  }

  Future<void> _onStoreRegistrationData(
    StoreRegistrationDataEvent event,
    Emitter<AuthState> emit,
  ) async {
    _pendingRegistrationData = event.registrationData;
    _pendingPhoneNumber = event.phoneNumber;
    _pendingCountryCode = event.countryCode;
    _pendingIsoCode = event.isoCode;

    log('✅ Registration data stored in bloc');
    emit(RegistrationDataStored(
      registrationData: event.registrationData,
      phoneNumber: event.phoneNumber,
      countryCode: event.countryCode,
      isoCode: event.isoCode,
    ));
  }

  Map<String, dynamic>? getPendingRegistrationData() =>
      _pendingRegistrationData;

  String? getPendingPhoneNumber() => _pendingPhoneNumber;
  String? getPendingCountryCode() => _pendingCountryCode;
  String? getPendingIsoCode() => _pendingIsoCode;

  Future<void> _onClearRegistrationData(
    ClearRegistrationDataEvent event,
    Emitter<AuthState> emit,
  ) async {
    _pendingRegistrationData = null;
    _pendingPhoneNumber = null;
    _pendingCountryCode = null;
    _pendingIsoCode = null;
    log('🗑️ Registration data cleared from bloc');
  }

  Future<void> _onLoginRequest(
    LoginRequest event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(
        email: event.email ?? '',
        phoneNumber: event.phoneNumber ?? '',
        password: event.password,
      );

      if (response.first.success == true) {
        final userData = response.first.user!;
        final fcmToken = await getFCMToken();
        _userDetailBloc.add(SetUserData(UserDataModel(
          token: response.first.accessToken ?? '',
          userId: userData.id.toString(),
          name: userData.name ?? '',
          email: userData.email ?? '',
          mobile: userData.mobile ?? '',
          country: userData.country ?? '',
          iso2: userData.iso2 ?? '',
          profileImage: userData.profileImage ?? '',
          referralCode: userData.referralCode ?? '',
          language: 'en',
          emailVerified: userData.emailVerifiedAt ?? '',
          mobileVerified: userData.mobileVerifiedAt ?? '',
          fcm: fcmToken ?? '',
        )));

        emit(
            AuthSuccess(message: response.first.message ?? 'Login successful'));
      } else {
        emit(AuthFailed(error: response.first.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthFailed(error: e.toString()));
    }
  }

  Future<void> _onRegisterRequest(
    RegisterRequest event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Fetch the Firebase ID token of the currently signed-in user (set when
      // the phone OTP step completed). Sent to /register as `idToken` when
      // available; omitted otherwise so the endpoint stays backward-compatible.
      String? firebaseToken;
      try {
        firebaseToken =
            await FirebaseAuth.instance.currentUser?.getIdToken();
      } catch (e) {
        log('Failed to fetch Firebase ID token for register: $e');
      }

      final response = await _repository.register(
        name: event.name,
        email: event.email,
        mobile: event.mobile,
        country: event.country,
        iso2: event.iso2,
        password: event.password,
        confirmPassword: event.confirmPassword,
        referralCode: event.referralCode,
        firebaseToken: firebaseToken,
      );

      if (response.first.success == true) {
        final userData = response.first.user!;
        final fcmToken = await getFCMToken();
        _userDetailBloc.add(SetUserData(UserDataModel(
          token: response.first.accessToken ?? '',
          userId: userData.id.toString(),
          name: userData.name ?? '',
          email: userData.email ?? '',
          mobile: userData.mobile ?? '',
          country: userData.country ?? '',
          iso2: userData.iso2 ?? '',
          profileImage: userData.profileImage ?? '',
          referralCode: userData.referralCode ?? '',
          language: 'en',
          emailVerified: userData.emailVerifiedAt ?? '',
          mobileVerified: userData.mobileVerifiedAt ?? '',
          fcm: fcmToken ?? '',
        )));
        emit(AuthSuccess(
            message: response.first.message ?? 'Register successful'));
      } else {
        String errorMessage = response.first.message ?? 'Register failed';

        if (errorMessage
            .toLowerCase()
            .contains('mobile has already been taken')) {
          errorMessage =
              'This mobile number is already registered. Please use a different number or login.';
        }

        emit(AuthFailed(error: errorMessage));
      }
    } catch (e) {
      emit(AuthFailed(error: e.toString()));
    }
  }

  Future<void> _onLogoutUserRequest(
    LogoutUserRequest event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await FirebaseAuth.instance.signOut();
      await _repository.logout();
      _userDetailBloc.add(ClearUserData());

      _pendingRegistrationData = null;
      _pendingPhoneNumber = null;
      _pendingCountryCode = null;
      _pendingIsoCode = null;
      emit(LogoutUser());
    } catch (e) {
      emit(LogoutUser());
    }
  }

  Future<void> _onDeleteUserRequest(
    DeleteUserRequest event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.delete();
      _userDetailBloc.add(ClearUserData());
      _pendingRegistrationData = null;
      _pendingPhoneNumber = null;
      _pendingCountryCode = null;
      _pendingIsoCode = null;
      emit(DeleteUserSuccess());
    } catch (e) {
      emit(AuthFailed(error: e.toString()));
    }
  }

  Future<void> _onSendOtpToPhone(
    SendOtpToPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoginCodeSentProgress(
      registrationData: _pendingRegistrationData,
      phoneNumber: _pendingPhoneNumber,
      countryCode: _pendingCountryCode,
      isoCode: _pendingIsoCode,
      isLogin: event.isLogin,
    ));
    try {
      await _verifyPhoneNumber(
        countryCode: event.countryCode,
        phoneNumber: event.number,
        isoCode: event.isoCode,
        isLogin: event.isLogin,
        resendToken: _lastResendToken,
        isUpdate: event.isUpdate,
        userName: event.userName,
        referralCode: event.referralCode,
      );
    } catch (e) {
      log('OTP Send Failed: $e');
      emit(AuthFailed(error: e.toString()));
    }
  }

  Future<void> _onVerifySentOtp(
    VerifySentOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerifyingOTP());
    try {

      if (AppHelpers.smsGatewayIsFirebase) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: event.verificationId,
          smsCode: event.otpCode,
        );
        add(OnPhoneAuthVerificationCompleted(
          credential: credential,
          countryCode: event.countryCode,
          number: event.phoneNumber,
          isoCode: event.isoCode,
          isLogin: event.isLogin,
          isUpdate: event.isUpdate,
          name: event.name,
          referralCode: event.referralCode,
        ));
      } else {
        // isRegister is the opposite of isLogin
        final bool isRegister = !event.isLogin;
        final regData = event.data;

        log('Using Custom SMS Verification for: ${regData?['name']} | isRegister: $isRegister');

        final response = await _repository.verifyCustomOTP(
            mobile: event.phoneNumber?.replaceAll(' ', '') ?? '',
            otp: event.otpCode,
            isRegister: isRegister,
            name: regData?['name'] ?? event.name,
            email: regData?['email'],
            password: regData?['password'],
            confirmPassword: regData?['confirmPassword'],
            country: regData?['country'],
            iso2: regData?['iso2'],
            referralCode: event.referralCode ?? regData?['referralCode']);

        if (response['success'] == true) {
          // Both register and login return user data from verify-otp API
          final authModel = AuthModel.fromJson(response);
          final userData = authModel.user!;

          // Preserve the existing session token when this is an update
          final String tokenToStore = event.isUpdate
              ? (Global.userData?.token ?? authModel.accessToken ?? '')
              : (authModel.accessToken ?? '');

          final fcmToken = await getFCMToken();
          _userDetailBloc.add(SetUserData(UserDataModel(
            token: tokenToStore,
            userId: userData.id.toString(),
            name: userData.name ?? '',
            email: userData.email ?? '',
            mobile: userData.mobile ?? '',
            country: userData.country ?? '',
            iso2: userData.iso2 ?? '',
            profileImage: userData.profileImage ?? '',
            referralCode: userData.referralCode ?? '',
            language: 'en',
            emailVerified: userData.emailVerifiedAt ?? '',
            mobileVerified: userData.mobileVerifiedAt ?? '',
            fcm: fcmToken ?? '',
          )));

          _pendingRegistrationData = null;
          _pendingPhoneNumber = null;
          _pendingCountryCode = null;
          _pendingIsoCode = null;

          emit(AuthSuccess(
              message: authModel.message ??
                  (isRegister
                      ? 'Registration successful'
                      : 'Login successful')));
        } else {
          emit(AuthFailed(error: response['message'] ?? 'Verification failed'));
        }
      }

    } catch (e) {
      emit(AuthFailed(error: e.toString()));
    }
  }

  void _onPhoneOtpSent(OnPhoneOtpSend event, Emitter<AuthState> emit) {
    _lastResendToken = event.resendToken;
    log('📱 Emitting LoginPhoneCodeSentState with ID: ${event.verificationId}');
    emit(LoginPhoneCodeSentState(
      verificationId: event.verificationId,
      registrationData: _pendingRegistrationData,
      phoneNumber: _pendingPhoneNumber,
      countryCode: _pendingCountryCode,
      isoCode: _pendingIsoCode,
      isLogin: event.isLogin,
    ));
  }

  Future<void> _onPhoneAuthVerified(
    OnPhoneAuthVerificationCompleted event,
    Emitter<AuthState> emit,
  ) async {
    if (_phoneCredentialInFlight) {
      log('Ignoring duplicate phone-auth credential (sign-in already in flight)');
      return;
    }
    _phoneCredentialInFlight = true;
    try {
      final credential = event.credential;
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final token = await userCredential.user?.getIdToken(true);

      log('Phone Auth Success | Token: $token | Number: ${event.number}');

      if (event.isLogin) {
        // Handle Mobile OTP Login flow
        add(CompleteMobileOtpLogin(
          phoneNumber: event.number ?? '',
          token: token ?? '',
          name: event.name,
          referralCode: event.referralCode,
          isUpdate: event.isUpdate,
        ));
      } else {
        emit(OTPVerified(message: 'OTP Verified'));
      }
    } catch (e, s) {
      _phoneCredentialInFlight = false; // allow retry after failure
      log('Phone verification failed: $e', stackTrace: s);
      log('  type: ${e.runtimeType}');
      String errorMessage = e.toString();
      String? errorCode;
      String? code;
      String? rawMessage;

      // Pigeon-wrapped failures arrive as PlatformException whose `code` /
      // `message` carry the actual Firebase auth error. Detect both shapes
      // so the user sees a real diagnosis instead of the raw host-API name.
      if (e is FirebaseAuthException) {
        code = e.code;
        rawMessage = e.message;
      } else if (e is PlatformException) {
        code = e.code;
        rawMessage = e.message;
      }

      if (code != null) {
        switch (code) {
          case 'invalid-verification-code':
          case 'ERROR_INVALID_VERIFICATION_CODE':
            errorMessage = 'The entered OTP is incorrect. Please try again.';
            errorCode = 'invalid-otp';
            break;
          case 'session-expired':
          case 'ERROR_SESSION_EXPIRED':
            errorMessage = 'The OTP session has expired. Please request a new OTP.';
            errorCode = 'session-expired';
            break;
          case 'invalid-verification-id':
          case 'ERROR_INVALID_VERIFICATION_ID':
            errorMessage = 'The verification session is invalid. Please request a new OTP.';
            errorCode = 'session-expired';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your connection.';
            errorCode = 'network';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again in a few minutes.';
            break;
          case 'invalid-phone-number':
            errorMessage = 'Phone number format is invalid.';
            break;
          // Suppress technical Firebase noise. Log it for debugging, show a
          // generic friendly message to the user. App Check, Pigeon, internal
          // errors etc. are not user-actionable.
          case 'internal-error':
          case 'ERROR_INTERNAL_ERROR':
          case 'app-check-token-is-invalid':
          case 'app-not-authorized':
          case 'billing-not-enabled':
          case 'missing-client-identifier':
          case 'invalid-app-credential':
          case 'recaptcha-not-enabled':
          case 'unknown':
            log('Firebase noise [$code]: $rawMessage');
            errorMessage = 'Verification failed. Please try again.';
            break;
          default:
            // Anything else also gets a friendly message + technical detail logged.
            log('Firebase auth fail [$code]: $rawMessage');
            errorMessage = 'Verification failed. Please try again.';
        }
      }
      emit(AuthFailed(error: errorMessage, errorCode: errorCode));
    }
  }

  Future<void> _onResendOtp(
    ResendOtpRequest event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _verifyPhoneNumber(
        countryCode: event.countryCode,
        phoneNumber: event.phoneNumber,
        isoCode: event.isoCode,
        isLogin: event.isLogin,
        isUpdate: event.isUpdate,
      );
    } catch (e) {
      emit(AuthFailed(error: 'Please wait before resending.'));
    }
  }

  Future<void> _verifyPhoneNumber({
    required String countryCode,
    required String phoneNumber,
    required String isoCode,
    required bool isLogin,
    int? resendToken,
    bool isUpdate = false,
    String? userName,
    String? referralCode,
  }) async {
    final fullNumber = countryCode + phoneNumber;
    log('Verifying phone: $fullNumber | ISO: $isoCode | isUpdate: $isUpdate');
    _phoneCredentialInFlight = false; // fresh code => allow one sign-in again
    if (AppHelpers.smsGatewayIsFirebase) {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          add(OnPhoneAuthVerificationCompleted(
            credential: credential,
            countryCode: countryCode,
            number: phoneNumber,
            isoCode: isoCode,
            isLogin: isLogin,
            isUpdate: isUpdate,
            name: userName,
            referralCode: referralCode,
          ));
        },
        verificationFailed: (FirebaseAuthException e) {
          log('=== FULL ERROR ===');
          log('Code: ${e.code}');
          log('Message: ${e.message}');
          log('Stack trace: ${e.stackTrace}');
          // If it's a platform exception or has more details:
          log('Full exception: $e');
          log('Verification failed: ${e.message}');
          String errorMessage = 'Unable to send OTP right now. Please try again.';

          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The phone number format is incorrect. Please enter a valid number with country code.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Phone authentication is not enabled for this project.';
              break;
            case 'quota-exceeded':
              errorMessage = 'Daily SMS quota exceeded. Please try again tomorrow.';
              break;
            case 'app-check-token-is-invalid':
            case 'app-not-authorized':
            case 'missing-client-identifier':
            case 'billing-not-enabled':
            case 'recaptcha-not-enabled':
            case 'internal-error':
              // Technical / Firebase-infrastructure failures. Log + show generic.
              log('Firebase verifyPhoneNumber noise [${e.code}]: ${e.message}');
              errorMessage = 'Unable to send OTP right now. Please try again.';
              break;
            default:
              log('Firebase verifyPhoneNumber [${e.code}]: ${e.message}');
              errorMessage = 'Unable to send OTP right now. Please try again.';
          }

          add(AuthFailureEvent(error: errorMessage));
        },
        codeSent: (String verificationId, int? newResendToken) {
          log('✅ OTP Code Sent! VerificationId: $verificationId');
          add(OnPhoneOtpSend(
              verificationId: verificationId,
              resendToken: newResendToken,
              isLogin: isLogin));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('Auto retrieval timeout: $verificationId');
        },
        timeout: const Duration(seconds: 120),
        forceResendingToken: resendToken,
      );
    } else {
      log('Sending Custom OTP to: $fullNumber');
      try {
        await _repository.sendCustomOTP(
          mobile: fullNumber,
          name: userName,
          referralCode: referralCode,
        );
        log('✅ Custom OTP Sent!');
        add(OnPhoneOtpSend(
            verificationId: 'CUSTOM_SMS', resendToken: 0, isLogin: isLogin));
      } catch (e) {
        log('Custom OTP Send Failed: $e');
        add(AuthFailureEvent(error: e.toString()));
      }
    }
  }

  Future<void> _onAuthFailureEvent(
    AuthFailureEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthFailed(error: event.error));
  }

  Future<void> _onSocialAuthRequest(
    SocialAuthRequest event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final response = await _repository.socialAuth(
          firebaseToken: event.firebaseToken, isApple: event.isApple);
      if (response['success'] == true) {
        final authModel = AuthModel.fromJson(response);
        final user = authModel.user!;

        final fcmToken = await getFCMToken();
        _userDetailBloc.add(SetUserData(UserDataModel(
          token: authModel.accessToken ?? '',
          userId: user.id.toString(),
          name: user.name ?? '',
          email: user.email ?? '',
          mobile: user.mobile ?? '',
          country: user.country ?? '',
          iso2: user.iso2 ?? '',
          profileImage: user.profileImage ?? '',
          referralCode: user.referralCode ?? '',
          language: 'en',
          emailVerified: user.emailVerifiedAt ?? '',
          mobileVerified: user.mobileVerifiedAt ?? '',
          fcm: fcmToken ?? '',
        )));
        emit(SocialAuthSuccess(
          isRegister: authModel.user?.isRegister ?? false,
          message: authModel.message,
        ));
      } else {
        emit(AuthFailed(error: response['message']?.toString() ?? 'Social login failed'));
      }
    } catch (e) {
      emit(AuthFailed(error: e.toString()));
    }
  }

  Future<void> _onGoogleLoginRequest(
    GoogleLoginRequest event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      String firebaseUserToken = await _repository.googleLogin();
      log('Firebase token via google  $firebaseUserToken');
      if (firebaseUserToken.isEmpty) {
        // User cancelled OR silent failure — reset to initial WITHOUT
        // dispatching SocialAuthRequest (empty token would 401 on backend).
        emit(AuthInitial());
        return;
      }
      add(SocialAuthRequest(firebaseToken: firebaseUserToken, isApple: false));
    } catch (e) {
      log('Google Sign-In failed: $e');
      emit(AuthFailed(error: e.toString()));
    }
  }

  Future<void> _onAppleLoginRequest(
    AppleLoginRequest event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      String firebaseUserToken = await _repository.appleLogin();
      log('Firebase token via apple  $firebaseUserToken');
      if (firebaseUserToken.isEmpty) {
        emit(AuthInitial());
        return;
      }
      add(SocialAuthRequest(firebaseToken: firebaseUserToken, isApple: true));
    } catch (e) {
      log('Apple Sign-In failed: $e');
      emit(AuthFailed(error: e.toString()));
    }
  }

  Future<void> _onDeleteUserAccount(
      DeleteUserAccount event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _repository.deleteUser();
      if (response['success'] == true) {
        emit(DeleteUserSuccess());
      }
    } catch (e) {
      emit(AuthFailed(error: e.toString()));
    }
  }

  Future<void> _onCompleteMobileOtpLogin(
      CompleteMobileOtpLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _repository.mobileOtpLogin(
        firebaseToken: event.token,
        name: event.name,
        referralCode: event.referralCode,
        isUpdate: event.isUpdate,
      );

      if (response['success'] == true) {
        List<AuthModel> userData = [];
        userData.add(AuthModel.fromJson(response));
        final user = userData.first.user!;

        log('Is Update ${event.isUpdate}');

        final String tokenToStore = event.isUpdate
            ? (Global.userData?.token ?? userData.first.accessToken ?? '')
            : (userData.first.accessToken ?? '');

        final fcmToken = await getFCMToken();
        _userDetailBloc.add(SetUserData(UserDataModel(
          token: tokenToStore,
          userId: user.id.toString(),
          name: user.name ?? '',
          email: user.email ?? '',
          mobile: user.mobile ?? '',
          country: user.country ?? '',
          iso2: user.iso2 ?? '',
          profileImage: user.profileImage ?? '',
          referralCode: user.referralCode ?? '',
          language: 'en',
          emailVerified: user.emailVerifiedAt ?? '',
          mobileVerified: user.mobileVerifiedAt ?? '',
          fcm: fcmToken ?? '',
        )));
        emit(
            AuthSuccess(message: userData.first.message ?? 'Login successful'));
      } else {
        emit(AuthFailed(error: response['message'] ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthFailed(error: e.toString()));
    }
  }
}
