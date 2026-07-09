import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/utils/widgets/whole_page_progress.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final Map<String, dynamic> registrationData;
  final String verificationId;
  final String number;
  final String countryCode;
  final String isoCode;
  final bool isLogin;
  final String userName;
  final String referralCode;
  final bool isUpdate;
  final bool popOnSuccess;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.registrationData,
    required this.verificationId,
    required this.number,
    required this.countryCode,
    required this.isoCode,
    this.isLogin = false,
    required this.userName,
    required this.referralCode,
    this.isUpdate = false,
    this.popOnSuccess = false,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with CodeAutoFill {
  static const int _resendSecondsTotal = 60;

  final _otpController = TextEditingController();
  String? _verificationId;

  // Resend countdown
  int _resendSeconds = _resendSecondsTotal;
  bool _canResend = false;
  Timer? _resendTicker;

  bool _submitted = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isActive || !mounted) return;
      _startResendTimer();
      listenForCode();
    });
  }

  @override
  void dispose() {
    // Order matters: mark inactive and stop the sms_autofill listener BEFORE
    // disposing the controller — `mounted` is still true while dispose() runs,
    // so codeUpdated() must be gated by _isActive, not mounted.
    _isActive = false;
    cancel();
    _resendTicker?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // ─── SMS autofill callback ────────────────────────────────────────────────
  @override
  void codeUpdated() {
    if (!_isActive || !mounted) return;
    final c = code;
    if (c == null || c.length != 6) return;
    HapticFeedback.lightImpact();
    _otpController.text = c;
    _submitOtp(c);
  }

  // ─── Resend countdown ─────────────────────────────────────────────────────
  void _startResendTimer() {
    _resendTicker?.cancel();
    setState(() {
      _resendSeconds = _resendSecondsTotal;
      _canResend = false;
    });
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) _resendSeconds--;
        if (_resendSeconds == 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _onResendPressed() {
    if (!_canResend) return;
    _submitted = false; // allow a fresh submit after resend
    _startResendTimer();
    context.read<AuthBloc>().add(SendOtpToPhoneEvent(
          number: widget.number,
          countryCode: widget.countryCode,
          isoCode: widget.isoCode,
          isLogin: widget.isLogin,
          isUpdate: widget.isUpdate,
          userName: widget.userName,
          referralCode: widget.referralCode,
        ));
  }

  // ─── OTP submit (single source of truth) ─────────────────────────────────

  void _submitOtp(String otp) {
    if (_submitted) return;
    if (otp.length != 6) return;

    final l10n = AppLocalizations.of(context)!;
    final vid = _verificationId;
    if (vid == null || vid.isEmpty) {
      ToastManager.show(
        context: context,
        message: l10n.verificationIdNotFound,
        type: ToastType.error,
      );
      return;
    }

    _submitted = true;
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<AuthBloc>().add(VerifySentOtp(
          verificationId: vid,
          otpCode: otp,
          isLogin: widget.isLogin,
          phoneNumber: widget.phoneNumber,
          data: widget.registrationData,
          isUpdate: widget.isUpdate,
          name: widget.userName,
          referralCode: widget.referralCode,
        ));
  }

  void _onVerifyPressed() {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.pleaseEnterCompleteOTP,
        type: ToastType.error,
      );
      return;
    }
    _submitOtp(otp);
  }

  // ─── AuthBloc state listener ──────────────────────────────────────────────
  void _handleAuthState(BuildContext context, AuthState state) {
    if (!_isActive || !mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (state is LoginPhoneCodeSentState) {
      setState(() => _verificationId = state.verificationId);
      ToastManager.show(
        context: context,
        message: l10n.otpSentTo(widget.phoneNumber),
        type: ToastType.success,
      );
    } else if (state is OTPVerified) {
      _completeRegistration();
    } else if (state is AuthSuccess) {
      context.read<AuthBloc>().add(ClearRegistrationDataEvent());
      ToastManager.show(
        context: context,
        message: state.message,
        type: ToastType.success,
      );
      if (widget.popOnSuccess) {
        final router = GoRouter.of(context);
        router.pop();
        router.pop();
      } else {
        GoRouter.of(context).pushReplacement(AppRoutes.splashScreen);
      }
    } else if (state is AuthFailed) {
      _submitted = false; // allow retry
      // If the user already navigated away (handler fires after a state hop),
      // do nothing. _isActive is set false in dispose.
      if (!_isActive || !mounted) return;
      if (state.errorCode == 'session-expired') {
        // Old code can't succeed anymore — clear it and open resend right away
        // instead of making the user wait out the countdown.
        _resendTicker?.cancel();
        setState(() {
          _otpController.clear();
          _canResend = true;
        });
      }
      // Don't show a toast for an empty / generic error — let the previous
      // success state win.
      final msg = state.error.trim();
      if (msg.isEmpty || msg.toLowerCase() == 'null') return;
      ToastManager.show(
        context: context,
        message: msg,
        type: ToastType.error,
      );
    } else if (state is OTPFailed) {
      _submitted = false; // allow retry
      if (!_isActive || !mounted) return;
      final msg = state.error.trim();
      if (msg.isEmpty || msg.toLowerCase() == 'null') return;
      ToastManager.show(
        context: context,
        message: msg,
        type: ToastType.error,
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleAuthState,
      builder: (context, state) {
        final isLoading = state is VerifyingOTP ||
            state is AuthLoading ||
            state is LoginCodeSentProgress;

        return Stack(
          children: [
            CustomScaffold(
              showViewCart: false,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () => GoRouter.of(context).pop(),
                  icon: const Icon(TablerIcons.chevron_left),
                ),
                title: Text(
                  l10n.verifyOtp,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.tertiary,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _HeaderIcon(),
                    SizedBox(height: 24.h),
                    _Title(text: l10n.verifyYourPhone),
                    SizedBox(height: 8.h),
                    _Subtitle(
                      text: l10n.weSentVerificationCodeTo,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 4.h),
                    _PhoneNumberText(phone: widget.phoneNumber),
                    SizedBox(height: 32.h),
                    _OtpField(
                      controller: _otpController,
                      enabled: !isLoading,
                      onChanged: (c) {
                        if (c.length == 6) _submitOtp(c);
                      },
                      onCompleted: _submitOtp,
                    ),
                    SizedBox(height: 28.h),
                    CustomButton(
                      onPressed: isLoading ? null : _onVerifyPressed,
                      child: Text(
                        l10n.verifyOtp,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _ResendRow(
                      canResend: _canResend,
                      secondsLeft: _resendSeconds,
                      onResend: _onResendPressed,
                      mutedColor: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            if (isLoading) const WholePageProgress(),
          ],
        );
      },
    );
  }


  void _completeRegistration() {
    final bloc = context.read<AuthBloc>();
    final pending = bloc.getPendingRegistrationData();

    if (pending == null) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.registrationDataNotFound,
        type: ToastType.error,
      );
      return;
    }

    bloc.add(RegisterRequest(
      name: widget.registrationData['name'].toString(),
      email: widget.registrationData['email'].toString(),
      mobile: widget.registrationData['mobile'].toString(),
      password: widget.registrationData['password'].toString(),
      country: widget.registrationData['country'].toString(),
      iso2: widget.registrationData['iso2'].toString(),
      countryCode: widget.registrationData['countryCode'].toString(),
      completePhoneNumber:
          widget.registrationData['completePhoneNumber'].toString(),
      confirmPassword: widget.registrationData['confirmPassword'].toString(),
      referralCode: widget.registrationData['referralCode'].toString(),
    ));

    bloc.add(ClearRegistrationDataEvent());
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(22.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.18),
              AppTheme.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Icon(
          Icons.sms_outlined,
          size: 48.r,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: AppTheme.fontFamily,
        fontSize: 22.sp,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String text;
  final Color color;
  const _Subtitle({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 13.5.sp,
        color: color,
      ),
    );
  }
}

class _PhoneNumberText extends StatelessWidget {
  final String phone;
  const _PhoneNumberText({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Text(
      phone,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontFamily: AppTheme.fontFamily,
        fontSize: 16.sp,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.3,
      ),
    );
  }
}


class _OtpField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  const _OtpField({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AbsorbPointer(
      absorbing: !enabled,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: PinCodeTextField(
          appContext: context,
          length: 6,
          controller: controller,
          obscureText: false,
          animationType: AnimationType.fade,
          animationDuration: const Duration(milliseconds: 300),
          keyboardType: TextInputType.number,
          enableActiveFill: true,
          cursorColor: AppTheme.primaryColor,
          textStyle: TextStyle(
            color: colorScheme.tertiary,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10.r),
            fieldHeight: 50.h,
            fieldWidth: 45.w,
            activeFillColor: colorScheme.surface,
            inactiveFillColor: colorScheme.surfaceContainer,
            selectedFillColor: colorScheme.surface,
            activeColor: AppTheme.primaryColor,
            inactiveColor: colorScheme.outline,
            selectedColor: AppTheme.primaryColor,
            errorBorderColor: colorScheme.error,
          ),
          onChanged: onChanged,
          onCompleted: onCompleted,
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  final bool canResend;
  final int secondsLeft;
  final VoidCallback onResend;
  final Color mutedColor;

  const _ResendRow({
    required this.canResend,
    required this.secondsLeft,
    required this.onResend,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.didntReceiveCode,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: mutedColor),
        ),
        SizedBox(width: 4.w),
        if (canResend)
          TextButton(
            onPressed: onResend,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.resendOtp,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            l10n.resendInSeconds(secondsLeft),
            style: TextStyle(
              color: mutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
