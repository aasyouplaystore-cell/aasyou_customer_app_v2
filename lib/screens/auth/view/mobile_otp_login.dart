import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/user_details_bloc/user_details_bloc.dart';
import '../../../bloc/user_details_bloc/user_details_event.dart';
import '../../../config/api_base_helper.dart';
import '../../../config/global.dart';
import '../../../config/helper.dart';
import '../../../config/notification_service.dart';
import '../../../config/settings_data_instance.dart';
import '../../../config/theme.dart';
import '../../../model/user_data_model/user_data_model.dart';
import '../../../router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_textfield.dart';
import '../../../utils/widgets/custom_toast.dart';
import '../../../utils/widgets/shake_widget.dart';
import '../../../utils/widgets/whole_page_progress.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/truecaller_cubit.dart';
import '../bloc/user_verification/user_verification_bloc.dart';
import '../bloc/user_verification/user_verification_event.dart';
import '../bloc/user_verification/user_verification_state.dart';
import '../model/auth_model.dart';
import '../repo/auth_repo.dart';

/// Pair of (ShakeWidget key, FocusNode) used to highlight the first invalid.
typedef _FieldHandle = ({
  GlobalKey<ShakeWidgetState> shakeKey,
  FocusNode focusNode,
});

class MobileOtpLoginPage extends StatefulWidget {
  final bool? isDirectLogin;

  /// When true, this page is being used by an already-logged-in user to.
  final bool isUpdate;

  const MobileOtpLoginPage({
    super.key,
    required this.isDirectLogin,
    this.isUpdate = false,
  });

  @override
  State<MobileOtpLoginPage> createState() => _MobileOtpLoginPageState();
}

class _MobileOtpLoginPageState extends State<MobileOtpLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  String? _completePhoneNumber;
  String _phoneNumber = '';
  String? _countryCode;
  String? _countryIso2;

  // Verification feedback (same as login_page.dart)
  bool? isUserVerified;
  bool? _phoneOk;
  String? helperText;
  Widget? statusIcon;

  /// Manually-managed errorText for the phone field.
  String? _phoneErrorText;
  bool _phoneSubmitAttempted = false;
  // Debounce for verification
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 800);

  // Animation controllers
  late AnimationController _slideController;

  // Shake + focus handles — on invalid submit, the first invalid field is
  final GlobalKey<ShakeWidgetState> _nameShakeKey =
      GlobalKey<ShakeWidgetState>();
  final GlobalKey<ShakeWidgetState> _phoneShakeKey =
      GlobalKey<ShakeWidgetState>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  /// Stays in scope for the lifetime of this page. Provided to the widget
  /// tree via [BlocProvider.value] so [BlocListener]/[BlocBuilder] children
  /// can observe its state. We construct it ourselves (rather than via
  /// `BlocProvider(create: ...)`) so we can call `initialize()` from
  /// `initState` without needing a separate `Builder` to obtain a context
  /// below the provider.
  late final TruecallerCubit _truecallerCubit;

  /// One-shot guard. We auto-trigger Truecaller consent the first time the
  /// cubit reaches `available`, BUT we do NOT auto-retry after a user
  /// dismiss/cancel — otherwise the consent sheet would keep slamming open
  /// and the user could never reach the phone-OTP fallback. After a failure
  /// they're free to retry via app-relaunch; before that, OTP works as-is.
  bool _truecallerAutoTriggered = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _truecallerCubit = TruecallerCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      // Reset verification state when page opens
      context.read<UserVerificationBloc>().add(ResetVerification());
      // Probe Truecaller availability *after* first frame — the platform
      // channel call adds ~1s latency we don't want to block the first
      // paint with. Android-only check lives inside the cubit, so calling
      // unconditionally is safe on iOS.
      _truecallerCubit.initialize();
    });
  }

  void _handlePhoneNumberChange(String value) {
    _debounceTimer?.cancel();

    if (value.isEmpty) {
      context.read<UserVerificationBloc>().add(ResetVerification());
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      if (_phoneNumber == value) {
        // Clean phone: remove all non-digits except +
        String cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
        context
            .read<UserVerificationBloc>()
            .add(VerifyUser(value: cleanPhone, type: 'mobile'));
      }
    });
  }

  // ─── Field-level validators (reused by form + submit) ──────────────────
  String? _validateName(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterYourFullName;
    }
    if (value.trim().length < 2) {
      return l10n.nameMustBeAtLeast2Characters;
    }
    return null;
  }

  String? _validatePhoneString(String? number, AppLocalizations l10n) {
    if (number == null || number.isEmpty) {
      return l10n.pleaseEnterYourPhoneNumber;
    }
    final trimmed = number.trim();
    if (trimmed.length < 5) return l10n.phoneNumberTooShort;
    if (trimmed.length > 16) return l10n.phoneNumberTooLong;
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) return l10n.onlyNumbersAllowed;
    return null;
  }

  /// Returns the first field (top-to-bottom) that fails its validator, or.
  _FieldHandle? _firstInvalidField(AppLocalizations l10n) {
    if (_isRegisterMode &&
        _validateName(_userNameController.text, l10n) != null) {
      return (shakeKey: _nameShakeKey, focusNode: _nameFocus);
    }
    if (_validatePhoneString(_phoneNumber, l10n) != null) {
      return (shakeKey: _phoneShakeKey, focusNode: _phoneFocus);
    }
    return null;
  }

  /// Shake + haptic + scroll-into-view + focus for an invalid field.
  Future<void> _shakeFocusScroll(_FieldHandle field) async {
    field.shakeKey.currentState?.shake();
    HapticFeedback.heavyImpact();
    final ctx = field.shakeKey.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignment: 0.2,
      );
    }
    if (!mounted) return;
    field.focusNode.requestFocus();
  }

  void _sendOtp() {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context)!;

    // Flag that a submit has been attempted — phone errorText will now
    setState(() {
      _phoneSubmitAttempted = true;
      _phoneErrorText = _validatePhoneString(_phoneNumber, l10n);
    });

    // 1. First-invalid → shake + focus + scroll, then render all errors.
    final invalid = _firstInvalidField(l10n);
    if (invalid != null) {
      _formKey.currentState?.validate();
      _shakeFocusScroll(invalid);
      return;
    }

    // 2. Phone-verification gate — only blocks REGISTER mode when phone
    //    is already taken. Login/signup via OTP is allowed for any number;
    //    backend auto-creates the account on /mobile-otp-auth.
    if (_isRegisterMode && _phoneOk == false) {
      ToastManager.show(
        context: context,
        message: l10n.phoneNumberAlreadyRegistered,
        type: ToastType.error,
      );
      return;
    }

    if (_completePhoneNumber == null || _phoneNumber.isEmpty) {
      return;
    }

    // Trigger AuthBloc to send OTP
    context.read<AuthBloc>().add(SendOtpToPhoneEvent(
          number: _phoneNumber,
          countryCode: _countryCode!,
          isoCode: _countryIso2!,
          isLogin: true,
          userName: _userNameController.text,
          referralCode: _referralCodeController.text,
          isUpdate: widget.isUpdate,
        ));
  }

  bool userIsRegistered() {
    final user = Global.userData;
    if (user == null) return false;

    // `user.mobile` holds the phone-number string; `user.mobileVerified` holds
    final mobile = user.mobile.trim();
    final mobileVerified = user.mobileVerified?.trim() ?? '';

    return mobile.isNotEmpty && mobileVerified.isNotEmpty;
  }

  /// Register mode means the user is signing up a NEW phone (post-social-auth).
  bool get _isRegisterMode =>
      widget.isDirectLogin == false && !userIsRegistered();

  @override
  Widget build(BuildContext context) {
    // Scope the Truecaller cubit to this page — it's only used here, and
    // tearing it down on pop frees its stream subscription. We use
    // `BlocProvider.value` because the cubit's lifecycle is owned by this
    // State (constructed in initState, closed in dispose).
    return BlocProvider<TruecallerCubit>.value(
      value: _truecallerCubit,
      child: BlocListener<TruecallerCubit, TruecallerState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, tcState) {
          // ── Auto-trigger Truecaller consent on first availability ─────
          // Per product direction: don't show a separate "Continue with
          // Truecaller" button at all. If the device has Truecaller
          // installed + signed-in (status == available), fire the consent
          // sheet automatically. If not available, fall through silently
          // to the phone-OTP form below.
          if (tcState.status == TruecallerStatus.available &&
              !_truecallerAutoTriggered) {
            _truecallerAutoTriggered = true;
            _truecallerCubit.login();
            return;
          }

          if (tcState.status == TruecallerStatus.success &&
              tcState.authorizationCode != null &&
              tcState.codeVerifier != null) {
            _handleTruecallerSuccess(
              authCode: tcState.authorizationCode!,
              codeVerifier: tcState.codeVerifier!,
            );
          } else if (tcState.status == TruecallerStatus.failure) {
            // User dismissed consent sheet, network failed, or backend
            // rejected the code — silently fall through to OTP form. NO
            // toast: the OLD 1.0 app's snackbar-on-cancel was confusing
            // (users see an error for an action they didn't take). The
            // phone field below is already visible and operable.
            // (Optional: re-enable the toast for non-user-cancel errors
            // once the SDK gives us a granular error code.)
          }
        },
        child: _buildScaffold(context),
      ),
    );
  }

  /// Fires when Truecaller hands back an `authorization_code` + PKCE
  /// verifier. Posts to the backend via [AuthRepository.truecallerLogin]
  /// using the user's referral code (if any) for the auto-register path.
  ///
  /// NB: We instantiate [AuthRepository] inline rather than reaching into a
  /// global Repo — the existing screen does the same for `mobileOtpLogin`.
  Future<void> _handleTruecallerSuccess({
    required String authCode,
    required String codeVerifier,
  }) async {
    try {
      final repo = AuthRepository();
      final response = await repo.truecallerLogin(
        authorizationCode: authCode,
        codeVerifier: codeVerifier,
        friendsCode: _referralCodeController.text.isEmpty
            ? null
            : _referralCodeController.text,
      );
      if (!mounted) return;

      // Persist session via the EXACT pattern AuthBloc._onCompleteMobileOtpLogin
      // uses: parse the response into an AuthModel, then dispatch SetUserData
      // to UserDataBloc. Without this, the access_token never lands in
      // persistent storage and the user appears logged-out on next launch
      // (or hits 401 on the very next authenticated request).
      final userData = AuthModel.fromJson(response);
      final user = userData.user;
      if (user == null) {
        throw ApiException('Truecaller login returned no user');
      }
      final fcmToken = await getFCMToken();
      if (!mounted) return;
      context.read<UserDataBloc>().add(SetUserData(UserDataModel(
            token: userData.accessToken ?? '',
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
      // Only navigate AFTER the session has been dispatched — guarantees
      // the home screen's bootstrap sees a logged-in user.
      GoRouter.of(context).go(AppRoutes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastManager.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    } catch (e) {
      if (!mounted) return;
      ToastManager.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Widget _buildScaffold(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is LoginPhoneCodeSentState) {
                // Navigate to OTP verification page
                GoRouter.of(context).push(
                  AppRoutes.otpVerification,
                  extra: {
                    'phoneNumber': _completePhoneNumber,
                    'registrationData': <String, dynamic>{},
                    'verificationId': state.verificationId,
                    'userNumber': _phoneNumber,
                    'countryCode': _countryCode,
                    'isoCode': _countryIso2,
                    'isLogin': true,
                    'userName': _userNameController.text,
                    'referralCode': _referralCodeController.text,
                    'isUpdate': widget.isUpdate,
                  },
                );
              } else if (state is AuthSuccess) {
                // Firebase Android instant-verification path: verifyPhoneNumber
                // fired verificationCompleted directly (no OTP entry), the
                // bloc auto-completed the backend exchange and emitted
                // AuthSuccess here. Route the user to splash so it can decide
                // home vs profile-completion, matching the OTP entry page.
                context.read<AuthBloc>().add(ClearRegistrationDataEvent());
                ToastManager.show(
                    context: context,
                    message: state.message,
                    type: ToastType.success);
                GoRouter.of(context).pushReplacement(AppRoutes.splashScreen);
              } else if (state is OTPVerified) {
                // Register flow instant-verify (isLogin=false) — proceed to
                // the next step the way OTPVerification page does.
                ToastManager.show(
                    context: context,
                    message: state.message,
                    type: ToastType.success);
              } else if (state is AuthFailed) {
                ToastManager.show(
                    context: context,
                    message: state.error,
                    type: ToastType.error);
              }
            },
            builder: (context, authState) {
              return Stack(
                children: [
                  _buildStaticBackground(),
                  _buildScrollableContent(),
                  if (authState is AuthLoading ||
                      authState is LoginCodeSentProgress)
                    const WholePageProgress(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStaticBackground() {
    // Richer brand-orange header — keeps the gradient direction "lit from
    // above" so the bottom stays SATURATED (not faded) right where it
    // meets the white card. Previous version went brand → lighter and
    // looked washed out at the seam.
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF8A4C), // warm top
            AppTheme.primaryColor, // brand
            Color(0xFFE55915), // deeper bottom for punch
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _LoginBackgroundPainter(),
      ),
    );
  }

  Widget _buildScrollableContent() {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      child: Stack(
        children: [
          // Brand logo (ported from old 1.0 design). Mask to white via
          // ColorFilter — the source asset is brand-orange, won't read
          // against the orange splash background otherwise.
          Positioned(
            top: 60.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/logo_with_name_white.png',
                    width: 160,
                    height: 54,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      'AasYou',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'मार्केट से डारेक्ट, आप के घर तक',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Skip Button
          Positioned(
            top: 10.h,
            right: 20.w,
            child: InkWell(
              onTap: () {
                Global.setIsFirstTime(false);
                GoRouter.of(context).go(AppRoutes.home);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.skip,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet(context) ? 18 : 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Main Content
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.32,
            child: keyboardOpen
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _buildFormContainer(),
                  )
                : _buildFormContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContainer() {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<UserVerificationBloc, UserVerificationState>(
      builder: (context, verificationState) {
        final isVerifying = verificationState is VerifyingUser;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h + MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.welcomeBack,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: isTablet(context) ? 32 : 22.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2.h),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.enterYourPhoneNumberToReceiveOtp,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: isTablet(context) ? 18 : 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  if(_isRegisterMode)...[
                    ShakeWidget(
                      key: _nameShakeKey,
                      shakeOffset: 8,
                      child: CustomTextFormField(
                        controller: _userNameController,
                        focusNode: _nameFocus,
                        labelText: l10n.fullName,
                        hintText: l10n.enterYourFullName,
                        prefixIcon: Icons.person,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) => _validateName(value, l10n),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // ── Truecaller CTA ────────────────────────────────────
                  // Sits ABOVE the phone field so users who have Truecaller
                  // installed can skip typing entirely. When unavailable
                  // (iOS / no app / SDK still probing) we render a
                  // zero-height SizedBox so the rest of the form doesn't
                  // shift down on cold start.
                  _buildTruecallerCta(),
                  ShakeWidget(
                    key: _phoneShakeKey,
                    shakeOffset: 8,
                    child: _buildPhoneField(verificationState),
                  ),
                  const SizedBox(height: 16),
                  if(SettingsData.instance.system!.referEarnStatus == true && _isRegisterMode)...[
                    CustomTextFormField(
                      controller: _referralCodeController,
                      labelText: l10n.referralCode,
                      hintText: l10n.referralCodeHintText,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 32),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      // Enable once a valid phone format is entered. Server-side
                      // verifyUser result is no longer required — backend will
                      // auto-register the number if it's new.
                      onPressed: isVerifying ||
                              _phoneNumber.isEmpty ||
                              (_isRegisterMode && _phoneOk == false)
                          ? null
                          : _sendOtp,
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Text(
                            isVerifying ? l10n.verifying : l10n.sendOtp,
                            style: TextStyle(
                              fontSize: isTablet(context) ? 28 : 16,
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // ── Continue as Guest ──────────────────────────────────
                  // Ported from AasYou 1.0 login. Lets users browse without
                  // signing in — wires straight to /home like the splash
                  // "Skip" button.
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Global.setIsFirstTime(false);
                        GoRouter.of(context).go(AppRoutes.home);
                      },
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'Continue as ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                          TextSpan(
                            text: 'Guest',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ── Become a Seller pill ───────────────────────────────
                  // Opens the seller app on Play Store (parity with old 1.0).
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.aasyou.vender',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.06),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.35),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.storefront_outlined,
                                color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Become a Seller',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: AppTheme.primaryColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Truecaller call-to-action shown above the phone field.
  ///
  /// Three visible states:
  ///   * [TruecallerStatus.available]   → blue "Continue with Truecaller"
  ///     button. Tapping fires `cubit.login()` which surfaces the consent
  ///     sheet; success/failure are picked up by the top-level BlocListener.
  ///   * [TruecallerStatus.authenticating] → CircularProgressIndicator in
  ///     Truecaller blue. Prevents double-taps.
  ///   * Otherwise → zero-height SizedBox so the form layout doesn't shift
  ///     when the SDK probe finally completes ~1s after first paint.
  ///
  /// IMPORTANT: This widget intentionally does NOT auto-fire `login()` on
  /// build. The OLD 1.0 app did, which caused the Truecaller consent sheet
  /// to slam open on every cold start — easily the most-complained-about
  /// UX bug in the previous release.
  /// Truecaller flow indicator — invisible by default.
  ///
  /// Per product direction (2026-06-10), there is NO manual
  /// "Continue with Truecaller" button. Instead the BlocListener at the
  /// top of build() auto-triggers `cubit.login()` the moment the SDK
  /// reaches `available` for the first time. The user just sees the
  /// native Truecaller consent sheet appear automatically.
  ///
  /// During the auto-trigger (status == authenticating), we show a small
  /// "Checking Truecaller…" hint so the phone field below doesn't feel
  /// like a dead screen for the ~300ms before the sheet slides up. In
  /// every other state we return zero-height so the layout collapses.
  Widget _buildTruecallerCta() {
    const truecallerBlue = Color(0xFF1B65F8);
    return BlocBuilder<TruecallerCubit, TruecallerState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, tcState) {
        if (tcState.status == TruecallerStatus.authenticating) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: SizedBox(
              height: 24.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(truecallerBlue),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Checking Truecaller…',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPhoneField(UserVerificationState state) {
    final l10n = AppLocalizations.of(context)!;
    final registerMode = _isRegisterMode;

    // Logic for verification feedback (matched from login_page.dart,
    if (_phoneNumber.isEmpty) {
      isUserVerified = null;
      _phoneOk = null;
      helperText = null;
      statusIcon = null;
    } else if (state is VerifyingUser) {
      isUserVerified = null;
      _phoneOk = null;
      helperText = l10n.verifying;
      statusIcon = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppTheme.warningColor),
      );
    } else if (state is UserVerified) {
      isUserVerified = state.isUserVerified;
      // OTP login allows BOTH existing + new users — backend auto-creates
      // the account on /mobile-otp-auth when the phone isn't registered yet.
      // We only block in register-mode if the phone is ALREADY taken (clash).
      _phoneOk = registerMode ? isUserVerified == false : true;
      if (registerMode && _phoneOk == false) {
        helperText = l10n.phoneNumberAlreadyRegistered;
        statusIcon = const Icon(Icons.cancel,
            color: AppTheme.errorColor, size: 16);
      } else {
        helperText = isUserVerified == true
            ? l10n.phoneNumberVerifiedSuccessfully
            : null; // Neutral for new users — no scary "not registered" red text
        statusIcon = isUserVerified == true
            ? const Icon(Icons.check_circle,
                color: AppTheme.successColor, size: 16)
            : null;
      }
    } else if (state is UserVerificationFailed) {
      // Verification *failing* is not the same as "phone unregistered" —
      isUserVerified = null;
      _phoneOk = null;
      helperText = l10n.unableToVerifyUser;
      statusIcon =
          const Icon(Icons.error, color: AppTheme.errorColor, size: 16);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntlPhoneField(
          showDropdownIcon: false,
          showCountryFlag: false,
          disableLengthCheck: true,
          cursorColor: Theme.of(context).colorScheme.tertiary,
          decoration: InputDecoration(
            labelText: l10n.phoneNumber,
            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontSize: isTablet(context) ? 20 : 16,
                ),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontSize: isTablet(context) ? 20 : 16,
                ),
            hintText: l10n.enterYourPhoneNumber,
            prefixIcon: Icon(
              Icons.phone,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
            prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontSize: isTablet(context) ? 20 : 16,
                ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            // Border colors handle both code paths — see register_page.dart
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: _phoneErrorText != null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: _phoneErrorText != null
                    ? Theme.of(context).colorScheme.error
                    : AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
          ),
          initialCountryCode: phoneInputInitialIso2,
          countries: phoneInputAllowedCountries,
          textInputAction: TextInputAction.done,
          focusNode: _phoneFocus,
          onChanged: (phone) {
            setState(() {
              _completePhoneNumber = phone.completeNumber;
              _countryCode = phone.countryCode;
              _phoneNumber = phone.number;
              _countryIso2 = phone.countryISOCode;
              // Keep the manual errorText in sync once the user has tried
              if (_phoneSubmitAttempted) {
                _phoneErrorText = _validatePhoneString(phone.number, l10n);
              }
            });
            _handlePhoneNumberChange(phone.number);
          },
          validator: (phone) => _validatePhoneString(phone?.number, l10n),
        ),
        // Manual errorText row — IntlPhoneField doesn't render it itself.
        if (_phoneErrorText != null) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              _phoneErrorText!,
              style: TextStyle(
                fontSize: isTablet(context) ? 16 : 12.sp,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
        if (helperText != null) ...[
          SizedBox(height: 6.h),
          Row(
            children: [
              if (statusIcon != null) ...[
                statusIcon!,
                SizedBox(width: 6.w),
              ],
              Expanded(
                child: Text(
                  helperText!,
                  style: TextStyle(
                    fontSize: isTablet(context) ? 18 : 12.sp,
                    color: _phoneOk == true
                        ? AppTheme.successColor
                        : _phoneOk == false
                            ? AppTheme.errorColor
                            : AppTheme.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _slideController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    // Cubit owns a StreamSubscription to TcSdk.streamCallbackData — closing
    // it cancels that sub so the Android side can't fire into a disposed
    // widget tree.
    _truecallerCubit.close();
    super.dispose();
  }
}

/// Subtle floating-circle decoration painted into the login screen's
/// orange header. Pure vectors — no asset weight. Mirrors the splash's
/// radial highlight + adds a few off-canvas bubbles so the orange feels
/// less flat without overwhelming the foreground form.
class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Wide soft halo behind the logo.
    paint.color = Colors.white.withValues(alpha: 0.10);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.18),
      size.width * 0.55,
      paint,
    );

    // Off-canvas bubbles (only the curved edges peek into view).
    paint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(
      Offset(-30, size.height * 0.05),
      120,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width + 30, size.height * 0.1),
      100,
      paint,
    );

    paint.color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.30),
      50,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.28),
      40,
      paint,
    );
  }

  @override
  bool shouldRepaint(_LoginBackgroundPainter old) => false;
}
