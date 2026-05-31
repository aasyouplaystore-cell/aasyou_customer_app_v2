import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/global.dart';
import '../../../config/helper.dart';
import '../../../config/settings_data_instance.dart';
import '../../../config/theme.dart';
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
import '../bloc/user_verification/user_verification_bloc.dart';
import '../bloc/user_verification/user_verification_event.dart';
import '../bloc/user_verification/user_verification_state.dart';

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

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      // Reset verification state when page opens
      context.read<UserVerificationBloc>().add(ResetVerification());
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        image: DecorationImage(
          image: AssetImage('assets/images/doodle.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      child: Stack(
        children: [
          // Brand wordmark (text fallback until AasYou PNG logo asset arrives).
          Positioned(
            top: 70.h,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Text(
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
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
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
          initialCountryCode: AppHelpers.countryCode,
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
    super.dispose();
  }
}
