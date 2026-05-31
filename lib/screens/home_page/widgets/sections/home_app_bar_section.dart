import 'package:flutter/material.dart';

import '../../../../config/theme.dart';

class HomeAppBarSection extends StatelessWidget {
  final bool canUseTabController;
  final double appBarOpacity;
  final Color? textColor;
  final Widget title;
  final Widget flexibleSpaceBackground;
  final Widget searchField;
  final Widget? tabBar;
  final Widget? notificationsAction;
  final bool isDarkMode;
  final Color? darkBackgroundColor;

  const HomeAppBarSection({
    super.key,
    required this.canUseTabController,
    required this.appBarOpacity,
    required this.textColor,
    required this.title,
    required this.flexibleSpaceBackground,
    required this.searchField,
    required this.isDarkMode,
    this.darkBackgroundColor,
    this.tabBar,
    this.notificationsAction,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: canUseTabController ? 195.0 : 120,
      floating: false,
      pinned: true,
      elevation: 3,
      shadowColor:
          Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.2),
      backgroundColor: Color.lerp(
        Colors.transparent,
        isDarkMode ? const Color(0xFF0A1628) : const Color(0xFFBDDCFB),
        1 - appBarOpacity,
      ),
      automaticallyImplyLeading: false,
      title: title,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? darkBackgroundColor : AppTheme.primaryColor.withValues(alpha: 0.4),
        ),
        child: FlexibleSpaceBar(
          background: flexibleSpaceBackground,
        ),
      ),
      actions: [
        if (notificationsAction != null) notificationsAction!,
        const SizedBox(width: 10),
      ],
      bottom: canUseTabController
          ? PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Column(
                children: [
                  searchField,
                  const SizedBox(height: 5),
                  tabBar ?? const SizedBox(height: 50),
                ],
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: searchField,
              ),
            ),
    );
  }
}
