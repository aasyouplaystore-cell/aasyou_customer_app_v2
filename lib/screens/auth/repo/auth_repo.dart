import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aasyou/config/api_base_helper.dart';
import 'package:aasyou/config/api_routes.dart';
import 'package:aasyou/config/constant.dart';
import 'package:aasyou/config/notification_service.dart';
import 'package:aasyou/screens/auth/model/auth_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../config/helper.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _serverClientId = AppConstant.serverClientId;

  String deviceType = '';
  String getDeviceType() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }

  Future<List<AuthModel>> login({
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      String? fcmToken = await getFCMToken();
      final response =
          await AppHelpers.apiBaseHelper.postAPICall(ApiRoutes.loginApi, {
        if (email.isNotEmpty) 'email': email,
        if (phoneNumber.isNotEmpty)
          'mobile': phoneNumber.isEmpty ? 0 : int.parse(phoneNumber),
        'password': password,
        'fcm_token': fcmToken,
        'device_type': getDeviceType()
      });
      if (response.data['success'] == true) {
        List<AuthModel> userData = [];
        userData.add(AuthModel.fromJson(response.data));
        return userData;
      } else {
        // API returned failure — throw a meaningful exception with the message
        String message = response.data['message']?.toString() ?? 'Login failed';
        throw ApiException(message);
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<AuthModel>> register(
      {required String name,
      required String email,
      required String mobile,
      required String country,
      required String iso2,
      required String password,
      required String confirmPassword,
      required String? referralCode,
      String? firebaseToken,
      }) async {
    try {
      String? fcmToken = await getFCMToken();
      final response =
          await AppHelpers.apiBaseHelper.postAPICall(ApiRoutes.registerApi, {
        'name': name,
        'email': email,
        'mobile': mobile,
        'password': password,
        'country': country,
        'iso_2': iso2,
        'friends_code': referralCode,
        'password_confirmation': confirmPassword,
        'fcm_token': fcmToken,
        'device_type': getDeviceType(),
        if (firebaseToken != null && firebaseToken.isNotEmpty)
          'idToken': firebaseToken,
      });

      if (response.data['success'] == true) {
        List<AuthModel> userData = [];
        userData.add(AuthModel.fromJson(response.data));
        return userData;
      }
      return [];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyUser(
      {required String type, required String value}) async {
    try {
      final response = await AppHelpers.apiBaseHelper
          .postAPICall(ApiRoutes.verifyUserApi, {'type': type, 'value': value});
      return response.data;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      log('Logout 🚪');
      await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.logoutApi,
        {
          'fcm_token': await getFCMToken()
        },
      );
    } catch (e) {
      throw ApiException('Failed to logout user');
    }
  }

  Future<String> sendOTP({required String phoneNumber}) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          throw ApiException(e.message ?? 'Failed to send OTP');
        },
        codeSent: (String verificationId, int? resendToken) {},
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );

      return '';
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, String>> sendOTPWithCallback({
    required String phoneNumber,
    Function(String verificationId)? onCodeSent,
  }) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final Completer<String> completer = Completer<String>();

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError(e.message ?? 'Failed to send OTP');
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
          if (onCodeSent != null) {
            onCodeSent(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );

      final verificationId = await completer.future;
      return {'verificationId': verificationId};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<bool> verifyOTP(
      {required String verificationId, required String otpCode}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Phone-callback API.
  Future<Map<String, dynamic>> mobileOtpLogin({
    required String firebaseToken,
    required String? name,
    required String? referralCode,
    required bool isUpdate,
  }) async {
    try {
      String? fcmToken = await getFCMToken();
      final response = await AppHelpers.apiBaseHelper
          .postAPICall(ApiRoutes.mobileOtpAuthApi, {
        'idToken': firebaseToken,
        'device_type': getDeviceType(),
        'fcm_token': fcmToken,
        if (name != null && name.isNotEmpty) 'name': name,
        if (referralCode != null && referralCode.isNotEmpty)
          'friends_code': referralCode,
        'is_update': isUpdate,
      });
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> socialAuth({
    required String firebaseToken,
    required bool isApple,
  }) async {
    try {
      String? fcmToken = await getFCMToken();
      String? apiUrl = '';
      if (isApple) {
        apiUrl = ApiRoutes.appleAuthApi;
      } else {
        apiUrl = ApiRoutes.googleAuthApi;
      }

      final response = await AppHelpers.apiBaseHelper.postAPICall(apiUrl, {
        'idToken': firebaseToken,
        'device_type': getDeviceType(),
        'fcm_token': fcmToken,
      });
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> googleLogin() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    try {
      await googleSignIn.initialize(serverClientId: _serverClientId);

      final GoogleSignInAccount googleUser =
          await googleSignIn.authenticate(scopeHint: ['email']);
      if (googleUser.id.isEmpty) {
        throw ApiException('User cancelled the login');
      }
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final authClient = googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        final IdTokenResult idTokenResult = await user.getIdTokenResult();
        final String? accessToken = idTokenResult.token;
        if (accessToken != null) {
          return accessToken;
        } else {
          throw ApiException('Failed to get token');
        }
      } else {
        throw ApiException('Failed to sign in');
      }
    } catch (e) {
      // Log full error so we can diagnose silent failures (SHA-1 mismatch,
      // Web client misconfig, etc.). Without this print the error vanishes.
      log('googleLogin error: $e');
      final errorMessage = e.toString().toLowerCase();

      // Narrow cancel detection — match only the specific cancellation
      // exception strings, not any error that happens to contain "cancel".
      final isUserCancelled = errorMessage.contains('canceled by the user') ||
          errorMessage.contains('cancelled by the user') ||
          errorMessage.contains('sign_in_canceled') ||
          errorMessage.contains('user_canceled') ||
          errorMessage.contains('user cancelled') ||
          errorMessage.contains('user canceled');
      if (isUserCancelled) {
        return '';
      }
      throw ApiException(e.toString());
    }
  }

  Future<String> appleLogin() async {
    try {
      // Trigger Apple Sign In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String appleName = appleCredential.familyName.toString();
      final String appleEmail = appleCredential.email.toString();
      final String appleState = appleCredential.state.toString();
      final String appleGivenName = appleCredential.givenName.toString();
      final String appleIdToken = appleCredential.identityToken.toString();
      final String appleUserId = appleCredential.userIdentifier.toString();
      final String appleAuthCode = appleCredential.authorizationCode.toString();

      log('Apple Name : $appleName');
      log('Apple Email : $appleEmail');
      log('Apple State : $appleState');
      log('Apple Given Name : $appleGivenName');
      log('Apple ID TOKEN : $appleIdToken');
      log('Apple User ID : $appleUserId');
      log('Apple Auth Code : $appleAuthCode');

      // Create Firebase credential from Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      await userCredential.user!.getIdToken(true);

      final user = userCredential.user;
      if (user != null) {
        // Get Firebase ID token (this is the JWT you likely want, similar to Google's accessToken in your example)
        final idTokenResult = await user.getIdTokenResult();
        final String? accessToken = idTokenResult.token;

        if (accessToken != null) {
          return accessToken;
        } else {
          throw ApiException('Failed to get Firebase ID token');
        }
      } else {
        throw ApiException('Failed to sign in with Apple');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle Apple-specific errors (e.g., user cancelled)
      if (e.code == AuthorizationErrorCode.canceled) {
        throw ApiException('User cancelled the Apple login');
      } else {
        throw ApiException('Apple login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await AppHelpers.apiBaseHelper
          .postAPICall(ApiRoutes.forgotPasswordApi, {'email': email});

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteUser() async {
    try {
      final response = await AppHelpers.apiBaseHelper
          .deleteAPICall(ApiRoutes.deleteUserApi, {});
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {};
      }
    } catch (e) {
      throw ApiException('Failed to get user profile');
    }
  }

  /// Sends an OTP via the custom SMS gateway.
  Future<void> sendCustomOTP({
    required String mobile,
    String? name,
    String? referralCode,
  }) async {
    try {
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.sendCustomOtpApi,
        {
          'mobile': mobile,
          if (name != null && name.isNotEmpty) 'name': name,
          if (referralCode != null && referralCode.isNotEmpty)
            'friends_code': referralCode,
        },
      );
      if (response.data['success'] != true) {
        throw ApiException(response.data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> applyReferral({String? code}) async {
    try {
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.applyReferralApi,
        {
          'friends_code': (code != null && code.isNotEmpty) ? code : null,
        },
      );
      if (response.data['success'] == true) {
        return response.data;
      }
      throw ApiException(
          response.data['message']?.toString() ?? 'Failed to apply referral');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyCustomOTP({
    required String mobile,
    required String otp,
    required bool isRegister,
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? country,
    String? iso2,
    String? referralCode,
  }) async {
    try {
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.verifyCustomOtpApi,
        {
          'mobile': mobile,
          'otp': otp,
          if (name != null && name.isNotEmpty) 'name': name,
          if (referralCode != null && referralCode.isNotEmpty)
            'friends_code': referralCode,
          if (isRegister) 'email': email,
          if (isRegister) 'password': password,
          if (isRegister) 'password_confirmation': confirmPassword,
          if (isRegister) 'country': country,
          if (isRegister) 'iso_2': iso2,
        },
      );

      if (response.data['success'] == true) {
        return response.data;
      } else {
        throw ApiException(
            response.data['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

}
