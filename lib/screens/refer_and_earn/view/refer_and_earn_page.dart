import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../../../config/settings_data_instance.dart';
import '../../../utils/widgets/custom_button.dart';
import '../bloc/refer_and_earn/refer_and_earn_bloc.dart';

class ReferAndEarnPage extends StatefulWidget {
  const ReferAndEarnPage({super.key});

  @override
  State<ReferAndEarnPage> createState() => _ReferAndEarnPageState();
}

class _ReferAndEarnPageState extends State<ReferAndEarnPage> {
  // Data from Bloc
  String referralCode = "";
  int totalReferrals = 0;
  double earnedAmount = 0.0;
  String? maxCommissionAmount;
  String? commissionRate;
  String? maxTimes;
  String? referralBonusType;

  @override
  void initState() {
    super.initState();
    context.read<ReferAndEarnBloc>().add(FetchReferInfo());
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showViewCart: false,
      title: AppLocalizations.of(context)!.referAndEarn,
      showAppBar: true,
      onConnectivityRestored: (context) async {
        context.read<ReferAndEarnBloc>().add(FetchReferInfo());
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: BlocBuilder<ReferAndEarnBloc, ReferAndEarnState>(
        builder: (context, state) {
          if (state is ReferAndEarnLoading) {
            return const CustomCircularProgressIndicator();
          }

          if (state is ReferAndEarnFailed) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.failedToLoadReferralData,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: () =>
                        context.read<ReferAndEarnBloc>().add(FetchReferInfo()),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          if (state is ReferAndEarnLoaded) {
            final data = state.referAndEarnData;
            final program = data.program;

            referralCode = data.referralCode ?? "NO CODE";
            totalReferrals = data.totalReferrals ?? 0;
            earnedAmount = (data.totalEarned ?? 0).toDouble();
            commissionRate = program?.referrerBonusValue ?? "0";
            maxCommissionAmount = program?.referrerBonusMaxCap ?? "0";
            maxTimes = program?.maxTimesBonus ?? "1";
            referralBonusType = data.program!.referrerBonusMethod.toString();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildEarningsCard(),
                  _buildReferAndEarnIllustrationDescription(),
                  const SizedBox(height: 16),
                  _buildReferralCodeCard(),
                  const SizedBox(height: 16),
                  // _buildAppLinkCard(),
                  _buildHowItWorks(),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // Widget _buildEarningsCard() {

  Widget _buildReferAndEarnIllustrationDescription () {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomImageContainer(
          imagePath: 'assets/images/refer-and-earn-illustration.png'
        ),
        const SizedBox(height: 8,),
        Text(
          AppLocalizations.of(context)!.referAndEarnTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 8,),
        Text(
          AppLocalizations.of(context)!.referAndEarnDescription,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ]
    );
  }

  Widget _buildReferralCodeCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Text(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralCode,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.codeCopied)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          _buildShareButton(),
        ],
      ),
    );
  }

  // Widget _buildAppLinkCard() {

  Widget _buildHowItWorks() {
    final currency = SettingsData.instance.system?.currencySymbol;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.howItWorks,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildStep(
          number: '1',
          title: AppLocalizations.of(context)!.shareYourCode,
          description: AppLocalizations.of(context)!.sendYourReferralCodeOrAppLinkToFriends,
        ),
        _buildStep(
          number: '2',
          title: AppLocalizations.of(context)!.friendSignsUp,
          description: AppLocalizations.of(context)!.theyRegisterUsingYourReferralCode,
        ),
        _buildStep(
          number: '3',
          title: AppLocalizations.of(context)!.youEarn,
          description:
          '${AppLocalizations.of(context)!.whenTheyCompleteTheirFirstOrderYouEarn} ${referralBonusType == 'fixed' ? currency : ''}$commissionRate${referralBonusType == 'percentage' ? '%' : ''} (${AppLocalizations.of(context)!.upTo} $currency$maxCommissionAmount).',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode(context) ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _handleNativeShare,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Icon(Icons.share_rounded, size: 20),
            Text(
              AppLocalizations.of(context)!.share,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),


      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode(context) ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  void _handleNativeShare() {
    final systemSettings = SettingsData.instance.system;
    final appSettings = SettingsData.instance.app;

    final String appLink = Platform.isIOS
        ? (appSettings?.appstoreLink ?? "")
        : (appSettings?.playstoreLink ?? "");

    final String message =
        "Hey! Use my referral code *$referralCode* to join ${systemSettings?.appName ?? 'our app'}.\n\nDownload now: $appLink";

    SharePlus.instance.share(
      ShareParams(
        text: message,
        title: 'Share Product',
      )
    );
  }

}