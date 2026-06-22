import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:aasyou/screens/auth/bloc/auth/auth_event.dart';
import 'package:aasyou/screens/auth/bloc/auth/auth_state.dart';
import 'package:aasyou/screens/auth/bloc/user_verification/user_verification_bloc.dart';
import 'package:aasyou/screens/auth/bloc/user_verification/user_verification_event.dart';
import 'package:aasyou/screens/auth/bloc/user_verification/user_verification_state.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/utils/widgets/whole_page_progress.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

/// Mobile verification page — used by already-logged-in users to add or.
class MobileVerificationPage extends StatefulWidget {
  const MobileVerificationPage({super.key});

  @override
  State<MobileVerificationPage> createState() => _MobileVerificationPageState();
}

class _MobileVerificationPageState extends State<MobileVerificationPage> {
  final _formKey = GlobalKey<FormState>();

  String _phoneNumber = '';
  String _completePhoneNumber = '';
  String _countryCode = '';
  String _countryIso2 = '';

  /// True after we've pushed the OTP verification page.
  bool _didPushOtp = false;

  /// User has tapped "Change" on the verified callout, so we should treat.
  bool _editing = false;

  /// Debounce timer for user-verification lookups against the phone field.
  Timer? _verifyDebounce;
  static const Duration _verifyDebounceDuration = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    // Clear any stale verification state from a previous screen so the
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserVerificationBloc>().add(ResetVerification());
    });

    _phoneNumber = _initialPhone;

    if (_initialPhone.isNotEmpty) {
      _countryIso2 = _initialCountryCode;

      /// You may need to map country code manually if required
      _countryCode = getDialCodeFromIso(_initialCountryCode) ?? '+91';

      _completePhoneNumber = '$_countryCode$_phoneNumber';
    }
  }

  @override
  void dispose() {
    _verifyDebounce?.cancel();
    super.dispose();
  }

  /// Debounced user-verification trigger — fires [VerifyUser] 700 ms after.
  void _onPhoneChanged(String number) {
    _verifyDebounce?.cancel();

    final cleaned = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      context.read<UserVerificationBloc>().add(ResetVerification());
      return;
    }

    _verifyDebounce = Timer(_verifyDebounceDuration, () {
      if (!mounted) return;
      // Ensure the field hasn't been cleared / changed since we scheduled.
      final latest = _phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      if (latest != cleaned) return;
      context
          .read<UserVerificationBloc>()
          .add(VerifyUser(value: cleaned, type: 'mobile'));
    });
  }

  bool get _alreadyVerified =>
      (Global.userData?.mobileVerified ?? '').trim().isNotEmpty;

  /// Effective "show as verified" — true only if the user has a verified.
  bool get _showAsVerified => _alreadyVerified && !_editing;

  String get _initialCountryCode {
    final stored = (Global.userData?.iso2 ?? '').trim().toUpperCase();
    return stored.isEmpty ? AppHelpers.countryCode : stored;
  }

  String get _initialPhone => (Global.userData?.mobile ?? '').trim();

  void _onSendPressed() {
    log('Complete Number : $_completePhoneNumber');
    log('Phone Number : $_phoneNumber');
    log('Country Code : $_countryCode');
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState?.validate() != true) return;

    if (_phoneNumber.isEmpty ||
        _countryCode.isEmpty ||
        _countryIso2.isEmpty) {
      ToastManager.show(
        context: context,
        message: l10n.pleaseEnterYourPhoneNumber,
        type: ToastType.error,
      );
      return;
    }

    // User-verification gate — don't let a taken number through.
    final verState = context.read<UserVerificationBloc>().state;
    if (verState is VerifyingUser) {
      return;
    }
    if (verState is UserVerified && verState.isUserVerified == true) {
      ToastManager.show(
        context: context,
        message: l10n.phoneNumberAlreadyRegistered,
        type: ToastType.error,
      );
      return;
    }
    if (verState is UserVerificationFailed) {
      ToastManager.show(
        context: context,
        message: l10n.unableToVerifyUser,
        type: ToastType.error,
      );
      return;
    }

    context.read<AuthBloc>().add(SendOtpToPhoneEvent(
          number: _phoneNumber,
          countryCode: _countryCode,
          isoCode: _countryIso2,
          isLogin: true,
          isUpdate: true,
          userName: Global.userData?.name ?? '',
          referralCode: null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    log('Hello Hello $_alreadyVerified');
    log('Mobile verified ${Global.userData!.mobileVerified}');
    return CustomScaffold(
      title: l10n.mobileVerification,
      showAppBar: true,
      showViewCart: false,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginPhoneCodeSentState) {
            ToastManager.show(
              context: context,
              message: l10n.otpSentTo(_completePhoneNumber),
              type: ToastType.success,
            );
            _didPushOtp = true;
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
                'userName': Global.userData?.name ?? '',
                'referralCode': '',
                // Backend: preserve session token (this is a re-verification).
                'isUpdate': true,
                // View: this is an inline flow — after AuthSuccess, pop
                'popOnSuccess': true,
              },
            );
          }
          else if (state is AuthSuccess && !_didPushOtp) {
            // Silent Firebase verification path (no OTP screen shown) —
            ToastManager.show(
              context: context,
              message: state.message,
              type: ToastType.success,
            );
            GoRouter.of(context).pop();
          } else if (state is AuthFailed) {
            ToastManager.show(
              context: context,
              message: state.error,
              type: ToastType.error,
            );
          }
        },
        builder: (context, state) {
          final isBusy = state is AuthLoading ||
              state is LoginCodeSentProgress;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HeaderIcon(),
                      SizedBox(height: 18.h),
                      Text(
                        _showAsVerified
                            ? l10n.verified
                            : l10n.enterYourPhoneNumberToReceiveOtp,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _showAsVerified ? 17.5 : 14.5,
                          fontWeight: _showAsVerified
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _showAsVerified
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildPhoneField(l10n, enabled: !_showAsVerified && !isBusy),
                      // Inline verification helper — spinner / available /
                      if (!_showAsVerified)
                        _MobileVerificationHelper(l10n: l10n),
                      SizedBox(height: 24.h),
                      if (_showAsVerified)
                        _AlreadyVerifiedCallout(
                          l10n: l10n,
                          onChangePressed: isBusy
                              ? null
                              : () {
                                  // Reset verification when entering edit
                                  context
                                      .read<UserVerificationBloc>()
                                      .add(ResetVerification());
                                  setState(() => _editing = true);
                                },
                        )
                      else
                        BlocBuilder<UserVerificationBloc,
                            UserVerificationState>(
                          builder: (context, verState) {
                            final isVerifying = verState is VerifyingUser;
                            final isTaken = verState is UserVerified &&
                                verState.isUserVerified == true;
                            final disabled =
                                isBusy || isVerifying || isTaken;
                            return CustomButton(
                              onPressed: disabled ? null : _onSendPressed,
                              child: Text(
                                l10n.sendOtp,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              if (isBusy) const WholePageProgress(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhoneField(AppLocalizations l10n, {required bool enabled}) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: _phoneField(l10n),
      ),
    );
  }

  Widget _phoneField(AppLocalizations l10n) {
    return IntlPhoneField(
      initialValue: _initialPhone,
      showDropdownIcon: false,
      showCountryFlag: false,
      disableLengthCheck: true,
      cursorColor: Theme.of(context).colorScheme.tertiary,
      initialCountryCode: _initialCountryCode,
      countries: phoneInputAllowedCountries,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l10n.phoneNumber,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              fontSize: isTablet(context) ? 20 : 16,
            ),
        hintText: l10n.enterYourPhoneNumber,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              fontSize: isTablet(context) ? 20 : 16,
            ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        prefixIcon: Icon(
          Icons.phone,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      onChanged: (phone) {
        setState(() {
          _phoneNumber = phone.number;
          _completePhoneNumber = phone.completeNumber;
          _countryCode = phone.countryCode;
          _countryIso2 = phone.countryISOCode;
        });
        if (!_showAsVerified) {
          _onPhoneChanged(phone.number);
        }
      },
      validator: (phone) {
        if (_showAsVerified) return null;
        if (phone == null || phone.number.trim().isEmpty) {
          return l10n.pleaseEnterYourPhoneNumber;
        }
        final number = phone.number.trim();
        if (number.length < 5) return l10n.phoneNumberTooShort;
        if (number.length > 16) return l10n.phoneNumberTooLong;
        if (!RegExp(r'^\d+$').hasMatch(number)) return l10n.onlyNumbersAllowed;
        return null;
      },
    );
  }
}

/// Helper row rendered directly below the phone field.
class _MobileVerificationHelper extends StatelessWidget {
  final AppLocalizations l10n;

  const _MobileVerificationHelper({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserVerificationBloc, UserVerificationState>(
      builder: (context, state) {
        String? message;
        Widget? icon;
        Color? color;

        if (state is VerifyingUser) {
          message = l10n.verifying;
          icon = const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.warningColor,
            ),
          );
          color = AppTheme.warningColor;
        } else if (state is UserVerified) {
          // REGISTER semantic: number must be available (not already taken).
          final taken = state.isUserVerified == true;
          message = taken
              ? l10n.phoneNumberAlreadyRegistered
              : l10n.phoneNumberAvailable;
          icon = Icon(
            taken ? Icons.cancel : Icons.check_circle,
            size: 16,
            color: taken ? AppTheme.errorColor : AppTheme.successColor,
          );
          color = taken ? AppTheme.errorColor : AppTheme.successColor;
        } else if (state is UserVerificationFailed) {
          message = l10n.unableToVerifyUser;
          icon = const Icon(Icons.error,
              size: 16, color: AppTheme.errorColor);
          color = AppTheme.errorColor;
        }

        if (message == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 6.h, left: 4.w),
          child: Row(
            children: [
              if (icon != null) ...[
                icon,
                SizedBox(width: 6.w),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.phone_iphone,
          size: 48,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _AlreadyVerifiedCallout extends StatelessWidget {
  final AppLocalizations l10n;

  /// When non-null, a "Change" button is rendered to the right of the.
  final VoidCallback? onChangePressed;

  const _AlreadyVerifiedCallout({
    required this.l10n,
    this.onChangePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.successColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: AppTheme.successColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.phoneNumberVerifiedSuccessfully,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
              ),
            ),
          ),
          if (onChangePressed != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onChangePressed,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.change,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
