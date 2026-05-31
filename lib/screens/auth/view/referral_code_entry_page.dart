import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/auth/bloc/apply_referral/apply_referral_bloc.dart';
import 'package:aasyou/services/referral_attribution_service.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/utils/widgets/whole_page_progress.dart';

import '../../cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';

class ReferralCodeEntryPage extends StatefulWidget {
  const ReferralCodeEntryPage({super.key});

  @override
  State<ReferralCodeEntryPage> createState() => _ReferralCodeEntryPageState();
}

class _ReferralCodeEntryPageState extends State<ReferralCodeEntryPage> {
  final TextEditingController _codeController = TextEditingController();
  final ReferralAttributionService _attribution =
      GetIt.instance<ReferralAttributionService>();

  bool _hasPrefilled = false;

  @override
  void initState() {
    super.initState();
    _loadStoredCode();
  }

  Future<void> _loadStoredCode() async {
    final stored = await _attribution.getCode();
    if (!mounted) return;
    if (stored != null && stored.isNotEmpty) {
      _codeController.text = stored;
      setState(() => _hasPrefilled = true);
    }
  }

  void _onApply() {
    FocusManager.instance.primaryFocus?.unfocus();
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _onSkip();
      return;
    }
    context
        .read<ApplyReferralBloc>()
        .add(ApplyReferralRequest(code: code));
  }

  void _onSkip() {
    FocusManager.instance.primaryFocus?.unfocus();
    context
        .read<ApplyReferralBloc>()
        .add(const ApplyReferralRequest(code: null));
  }

  Future<void> _onSuccess(String successMessage) async {
    await _attribution.clearCode();
    if (!mounted) return;
    if (successMessage.isNotEmpty) {
      ToastManager.show(
        context: context,
        message: successMessage,
        type: ToastType.success,
      );
    }
    // Mirror the AuthSuccess path: splash decides where to send the user.
    GoRouter.of(context).pushReplacement(AppRoutes.splashScreen);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      context.read<GetUserCartBloc>().add(SyncCart());
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: BlocConsumer<ApplyReferralBloc, ApplyReferralState>(
        listener: (context, state) {
          if (state is ApplyReferralSuccess) {
            final msg = state.message.isNotEmpty
                ? state.message
                : l10n.referralAppliedSuccess;
            _onSuccess(msg);
          } else if (state is ApplyReferralFailed) {
            ToastManager.show(
              context: context,
              message: state.message.isNotEmpty
                  ? state.message
                  : l10n.referralFailedRetry,
              type: ToastType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ApplyReferralLoading;
          return Stack(
            children: [
              CustomScaffold(
                showAppBar: true,
                showViewCart: false,
                appBarActions: [
                  TextButton(
                    onPressed: isLoading ? null : _onSkip,
                    child: Text(
                      l10n.skipReferral,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,)
                ],
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: SafeArea(
                  child: AbsorbPointer(
                    absorbing: isLoading,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 5.h),
                          _buildHeroIcon(),
                          SizedBox(height: 28.h),
                          Text(
                            l10n.referralCodeTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              l10n.referralCodeSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          CustomTextFormField(
                            controller: _codeController,
                            hintText: l10n.referralCodeHint,
                            prefixIcon: Icons.card_giftcard_outlined,
                            enabled: !isLoading,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onApply(),
                          ),
                          if (_hasPrefilled) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 14.sp,
                                    color: AppTheme.primaryColor),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    l10n.referralCodePrefilledHint,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 12.sp,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 10.h),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              onPressed: isLoading ? () {} : _onApply,
                              child: Text(
                                l10n.applyReferralCode,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          /*TextButton(
                            onPressed: isLoading ? null : _onSkip,
                            style: TextButton.styleFrom(
                              minimumSize: Size(double.infinity, 48.h),
                            ),
                            child: Text(
                              l10n.skipReferral,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),*/
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading) const WholePageProgress(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroIcon() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.card_giftcard_rounded,
        color: Colors.white,
        size: 44.sp,
      ),
    );
  }
}
