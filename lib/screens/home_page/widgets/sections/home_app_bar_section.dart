import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

import '../../../../bloc/user_cart_bloc/user_cart_bloc.dart';
import '../../../../bloc/user_cart_bloc/user_cart_state.dart';
import '../../../../config/theme.dart';
import '../../../../router/app_routes.dart';

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
      expandedHeight: canUseTabController ? 210.0 : 120,
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
          color: isDarkMode ? darkBackgroundColor : null,
          gradient: isDarkMode
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.55),
                    AppTheme.primaryColor.withValues(alpha: 0.0),
                    AppTheme.primaryColor.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.35, 0.60, 0.75, 1.0],
                ),
        ),
        child: FlexibleSpaceBar(
          background: flexibleSpaceBackground,
        ),
      ),
      actions: [
        if (notificationsAction != null) notificationsAction!,
        _buildCartAction(context),
        const SizedBox(width: 10),
      ],
      bottom: canUseTabController
          ? PreferredSize(
              preferredSize: const Size.fromHeight(86),
              child: Column(
                children: [
                  searchField,
                  const SizedBox(height: 6),
                  tabBar ?? const SizedBox(height: 80),
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

  Widget _buildCartAction(BuildContext context) {
    return IconButton(
      tooltip: 'Cart',
      onPressed: () {
        GoRouter.of(context).push(AppRoutes.cart);
      },
      icon: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int itemCount = 0;
          if (state is CartLoaded) {
            itemCount = state.totalItems;
          }
          final bool showBadge = itemCount > 0;
          return Badge(
            isLabelVisible: showBadge,
            label: Text(
              itemCount > 9 ? '9+' : itemCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
            backgroundColor: Colors.red.shade600,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(HeroiconsOutline.shoppingCart, color: textColor),
          );
        },
      ),
    );
  }
}
