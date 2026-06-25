import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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

  /// Sends a Firebase phone-auth OTP and returns the `verificationId` once
  /// `codeSent` fires.
  ///
  /// The previous implementation awaited `auth.verifyPhoneNumber(...)`
  /// then returned `''` — but `verifyPhoneNumber`'s outer Future resolves
  /// when platform setup completes, NOT when `codeSent` fires. Callers
  /// received an empty string and OTP entry was impossible. This now
  /// bridges the callback-style API into an awaitable Future via
  /// Completer (same pattern as `sendOTPWithCallback`).
  Future<String> sendOTP({required String phoneNumber}) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final Completer<String> completer = Completer<String>();

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(ApiException(
                _describeFirebaseAuthError(e, 'Failed to send OTP')));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } on FirebaseAuthException catch (e) {
      throw ApiException(_describeFirebaseAuthError(e, 'Failed to send OTP'));
    } on PlatformException catch (e) {
      throw ApiException(_describePlatformError(e, 'Failed to send OTP'));
    } on ApiException {
      // Already wrapped — re-throw as-is to avoid the
      // `ApiException: ApiException: <real msg>` double-prefix that
      // `e.toString()` wrapping would produce in the UI.
      rethrow;
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
          completer.completeError(
            ApiException(_describeFirebaseAuthError(e, 'Failed to send OTP')),
          );
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
    } on FirebaseAuthException catch (e) {
      throw ApiException(_describeFirebaseAuthError(e, 'Failed to send OTP'));
    } on PlatformException catch (e) {
      throw ApiException(_describePlatformError(e, 'Failed to send OTP'));
    } catch (e) {
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
    } on FirebaseAuthException catch (e) {
      throw ApiException(_describeFirebaseAuthError(e, 'OTP verification failed'));
    } on PlatformException catch (e) {
      throw ApiException(_describePlatformError(e, 'OTP verification failed'));
    } catch (e) {
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  // Surface Firebase auth errors with their stable `code` so debugging (and
  // user-facing messaging) can distinguish `invalid-verification-code` from
  // `session-expired` from `internal-error` etc. Without this the catch
  // block previously returned `e.toString()`, which on Pigeon-wrapped
  // platform errors collapses to the generated host-API method name and
  // hides the real cause.
  String _describeFirebaseAuthError(FirebaseAuthException e, String fallback) {
    final code = e.code.isEmpty ? 'unknown' : e.code;
    final message = (e.message ?? '').trim();
    return message.isEmpty ? '[$code] $fallback' : '[$code] $message';
  }

  String _describePlatformError(PlatformException e, String fallback) {
    final code = e.code.isEmpty ? 'platform-error' : e.code;
    final message = (e.message ?? '').trim();
    return message.isEmpty ? '[$code] $fallback' : '[$code] $message';
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
    } on ApiException {
      // Don't double-wrap an already-typed ApiException — that produces
      // `ApiException: ApiException: <real message>` in the UI toast.
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Exchanges a Truecaller `authorization_code` + PKCE `code_verifier` for
  /// an AasYou session.
  ///
  /// Backend (`/auth/truecaller/callback`) performs the OAuth code-for-token
  /// exchange against Truecaller, verifies the phone, and returns the same
  /// shape as `mobileOtpLogin` — caller can treat the response as a normal
  /// phone-based login result.
  ///
  /// Optional [friendsCode] / [iso2] / [country] are forwarded to support
  /// the "register via Truecaller" path (mirrors `register()`'s extra args).
  Future<Map<String, dynamic>> truecallerLogin({
    required String authorizationCode,
    required String codeVerifier,
    String? friendsCode,
    String? iso2,
    String? country,
  }) async {
    try {
      String? fcmToken = await getFCMToken();
      final response = await AppHelpers.apiBaseHelper.postAPICall(
        ApiRoutes.truecallerAuthApi,
        {
          'authorization_code': authorizationCode,
          'code_verifier': codeVerifier,
          'device_type': getDeviceType(),
          'fcm_token': fcmToken,
          if (friendsCode != null && friendsCode.isNotEmpty)
            'friends_code': friendsCode,
          if (iso2 != null && iso2.isNotEmpty) 'iso_2': iso2,
          if (country != null && country.isNotEmpty) 'country': country,
        },
      );
      // Mirror mobileOtpLogin's success contract: accept any 200 response.
      // The Laravel backend does NOT consistently return `success: true`
      // (the same shape works for /mobile-otp-auth at line 244 with no
      // success-flag check), so requiring BOTH made Truecaller login
      // throw ApiException on perfectly valid 200 payloads. The earlier
      // asymmetric check was a regression vs the sibling mobileOtpLogin.
      if (response.statusCode == 200) {
        // Defensive: if the backend explicitly returns success:false in a
        // 200 envelope, surface the error message rather than treating
        // the empty body as a valid session.
        if (response.data is Map &&
            response.data['success'] == false) {
          throw ApiException(response.data['message']?.toString() ??
              'Truecaller login failed');
        }
        return response.data;
      }
      throw ApiException(
          response.data['message']?.toString() ?? 'Truecaller login failed');
    } on ApiException {
      // Don't double-wrap — preserves the original message in the toast.
      rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
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
      // If we already threw an ApiException above (e.g. statusCode != 200),
      // rethrow so the message doesn't get prefixed with "ApiException: ".
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

}
