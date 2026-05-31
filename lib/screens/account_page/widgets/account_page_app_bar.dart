import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/global.dart';
import '../../../config/theme.dart';
import '../../../model/user_data_model/user_data_model.dart';
import '../../../router/app_routes.dart';
import '../../../utils/widgets/animated_button.dart';

class AccountPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountPageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 30.h),
        child: Column(
          children: [
            ValueListenableBuilder<UserDataModel?>(
              valueListenable: Global.userDataNotifier,
              builder: (context, userData, _) {
                final userName = userData?.name ?? '';
                final userEmail = userData?.email ?? '';
                final userProfile = userData?.profileImage ?? '';
                final userNumber = userData?.mobile ?? '';

                return Padding(
                  padding: EdgeInsets.only(
                    left: 12.0.w,
                    right: 12.0.w,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        backgroundImage: (userProfile.isNotEmpty &&
                                userProfile != 'profile_image')
                            ? NetworkImage(userProfile)
                            : null,
                        child: (userProfile.isEmpty ||
                                userProfile == 'profile_image')
                            ? const Icon(TablerIcons.user, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName.isNotEmpty ? userName : "Sign In",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (userEmail.isNotEmpty)
                              Text(
                                userEmail,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFEEEEEE),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            if (userNumber.isNotEmpty)
                              Text(
                                userNumber,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFEEEEEE),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (userData != null && userData.token.isNotEmpty) ...[
                        AnimatedButton(
                          animationType: TapAnimationType.scale,
                          onTap: () {
                            GoRouter.of(context).push(AppRoutes.userProfile);
                          },
                          child: const Icon(TablerIcons.edit,
                              color: Colors.white),
                        ),
                      ] else ...[
                        AnimatedButton(
                          animationType: TapAnimationType.scale,
                          onTap: () {
                            GoRouter.of(context).push(AppRoutes.login);
                          },
                          child: const Icon(TablerIcons.login,
                              color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            SizedBox(
              height: 15.h,
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 30.h);
}
