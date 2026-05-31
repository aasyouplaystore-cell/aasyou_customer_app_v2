import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/global.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import '../../../config/helper.dart';
import '../../../model/user_data_model/user_data_model.dart';
import '../bloc/user_profile_bloc/user_profile_bloc.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    Global.setUserData(UserDataModel(
      token: Global.userData!.token,
      userId: Global.userData!.userId,
      name: Global.userData!.name,
      email: Global.userData!.email,
      mobile: Global.userData!.mobile,
      country: Global.userData!.country,
      iso2: Global.userData!.iso2,
      profileImage: Global.userData!.profileImage,
      referralCode: Global.userData!.referralCode,
      language: 'en',
      emailVerified: Global.userData!.emailVerified,
      mobileVerified: Global.userData!.mobileVerified,
      fcm: Global.userData!.fcm,
    ));
    context.read<UserProfileBloc>().add(FetchUserProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showSnack(String message, {Color? background}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleEdit() {
    if (AppHelpers.isDemo) {
      _showSnack(AppHelpers.demoModeMessage);
      return;
    }
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedImage = null;
      }
    });
  }

  void _saveProfile() {
    if (AppHelpers.isDemo) {
      _showSnack(AppHelpers.demoModeMessage);
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_selectedImage != null || _nameController.text.isNotEmpty) {
        context.read<UserProfileBloc>().add(
              UpdateUserProfile(
                userName: _nameController.text.trim(),
                userImage: _selectedImage,
              ),
            );
        setState(() {
          _isEditing = false;
        });
      } else {
        _showSnack(AppLocalizations.of(context)!
            .pleaseSelectAnImageAndEnterYourName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScaffold(
      title: AppLocalizations.of(context)!.profile,
      showAppBar: true,
      showViewCart: false,
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileFailed) {
            _showSnack(state.error, background: colorScheme.error);
          } else if (state is UserProfileLoaded) {
            _selectedImage = null;
          }
        },
        builder: (context, state) {
          final isLoggedIn =
              Global.userData != null && (Global.userData!.token.isNotEmpty);

          if (!isLoggedIn) {
            return _NotLoggedInView(colorScheme: colorScheme);
          }

          if (state is UserProfileLoading) {
            return _LoadingView(colorScheme: colorScheme);
          }

          if (state is UserProfileLoaded) {
            final userData = state.userData.data!;

            if (!_isEditing && _nameController.text.isEmpty) {
              _nameController.text = userData.name ?? '';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(userData, colorScheme),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    _buildEditForm(colorScheme)
                  else
                    _buildViewActions(colorScheme),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    AppLocalizations.of(context)!.accountInformation,
                    colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailsCard(userData, colorScheme),
                ],
              ),
            );
          }

          if (state is UserProfileFailed) {
            return _ErrorView(
              colorScheme: colorScheme,
              onRetry: () =>
                  context.read<UserProfileBloc>().add(FetchUserProfile()),
            );
          }

          return _EmptyView(colorScheme: colorScheme);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildHero(dynamic userData, ColorScheme colorScheme) {
    final hasRemoteImage =
        userData.profileImage != null && userData.profileImage!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.9),
                      AppTheme.primaryColor.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!) as ImageProvider
                      : (hasRemoteImage
                          ? NetworkImage(userData.profileImage!)
                          : null),
                  child: _selectedImage == null && !hasRemoteImage
                      ? Icon(
                          Icons.person_outline,
                          size: 52,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: AppHelpers.isDemo
                        ? () => _showSnack(AppHelpers.demoModeMessage)
                        : _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppHelpers.isDemo
                            ? Colors.grey
                            : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            userData.name ?? 'No Name',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            userData.email ?? 'No Email',
            style: TextStyle(
              fontSize: 13.5,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if ((userData.email ?? '').toString().trim().isNotEmpty)
            Builder(
              builder: (context) {
                Future<void> openEmailVerification() async {
                  await GoRouter.of(context).push(AppRoutes.emailVerification);
                  if (!context.mounted) return;
                  context.read<UserProfileBloc>().add(FetchUserProfile());
                }

                return _VerificationAction(
                  verified: (userData.emailVerifiedAt ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty,
                  onVerify: openEmailVerification,
                  // Lets a verified user re-open the verification page to
                  onEdit: openEmailVerification,
                );
              },
            )
          else
            _AddFieldAction(
              label: AppLocalizations.of(context)!.addEmail,
              onTap: () async {
                await GoRouter.of(context).push(AppRoutes.emailVerification);
                if (!mounted) return;
                context.read<UserProfileBloc>().add(FetchUserProfile());
              },
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildViewActions(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: _toggleEdit,
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: Text(AppLocalizations.of(context)!.editProfile),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildEditForm(ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterYourName;
              }
              if (value.trim().length < 2) {
                return AppLocalizations.of(context)!
                    .nameMustBeAtLeast2Characters;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleEdit,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(AppLocalizations.of(context)!.cancel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(AppLocalizations.of(context)!.saveChanges),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildDetailsCard(dynamic userData, ColorScheme colorScheme) {
    final l = AppLocalizations.of(context)!;

    final bool hasMobile =
        (userData.mobile ?? '').toString().trim().isNotEmpty;
    final bool mobileVerified =
        (userData.mobileVerifiedAt ?? '').toString().trim().isNotEmpty;

    Future<void> openMobileVerification() async {
      await GoRouter.of(context).push(AppRoutes.mobileVerification);
      if (!mounted) return;
      context.read<UserProfileBloc>().add(FetchUserProfile());
    }

    final items = <_DetailEntry>[
      _DetailEntry(
        icon: Icons.phone_outlined,
        label: l.mobile,
        value: userData.mobile ?? l.notProvided,
        trailing: hasMobile
            ? _VerificationAction(
                verified: mobileVerified,
                onVerify: openMobileVerification,
                // Lets a verified user re-open the verification page to
                onEdit: openMobileVerification,
              )
            : _AddFieldAction(
                label: l.addMobile,
                onTap: openMobileVerification,
              ),
      ),
      _DetailEntry(
        icon: Icons.public_outlined,
        label: l.country,
        value: userData.country ?? l.notProvided,

      ),
      _DetailEntry(
        icon: Icons.account_balance_wallet_outlined,
        label: '${l.wallet} ${l.balance}',
        value:
            '${AppHelpers.currency}${userData.walletBalance?.toString() ?? '0'}',
        valueColor: AppTheme.primaryColor,
      ),
      // _DetailEntry(
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildInfoItem(
              items[i].icon,
              items[i].label,
              items[i].value,
              valueColor: items[i].valueColor,
              trailing: items[i].trailing,
            ),
            if (i != items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 60,
                endIndent: 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool showCopyButton = false,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else if (showCopyButton)
            IconButton(
              onPressed: () {
                _showSnack(AppLocalizations.of(context)!
                    .labelCopiedToClipboard(label));
              },
              icon: Icon(
                Icons.copy_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              style: IconButton.styleFrom(
                minimumSize: const Size(32, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _DetailEntry {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  _DetailEntry({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });
}

class _VerificationAction extends StatelessWidget {
  final bool verified;
  final VoidCallback onVerify;
  final VoidCallback? onEdit;

  const _VerificationAction({
    required this.verified,
    required this.onVerify,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (verified) {
      final badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: AppTheme.successColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                size: 14, color: AppTheme.successColor),
            const SizedBox(width: 4),
            Text(
              l10n.verified,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
      );

      if (onEdit == null) return badge;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          const SizedBox(width: 4),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 16),
            color: AppTheme.primaryColor,
            tooltip: l10n.change,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            visualDensity: VisualDensity.compact,
          ),
        ],
      );
    }

    return OutlinedButton(
      onPressed: onVerify,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: const BorderSide(color: AppTheme.primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
      child: Text(l10n.verify),
    );
  }
}

class _AddFieldAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddFieldAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        side: const BorderSide(color: AppTheme.primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _NotLoggedInView extends StatelessWidget {
  final ColorScheme colorScheme;
  const _NotLoggedInView({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 56,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.notLoggedIn,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.pleaseLoginToViewYourProfile,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => GoRouter.of(context).push(AppRoutes.login),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.goToLogin),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final ColorScheme colorScheme;
  const _LoadingView({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.loadingProfile,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback onRetry;
  const _ErrorView({required this.colorScheme, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 56,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.failedToLoadProfile,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.pleaseCheckConnection,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.tryAgain),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final ColorScheme colorScheme;
  const _EmptyView({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 56,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context)!.noProfileDataAvailable,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
