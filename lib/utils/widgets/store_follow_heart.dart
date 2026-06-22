import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/api_base_helper.dart';
import '../../config/global.dart';
import '../../router/app_routes.dart';
import '../../screens/store_follow/bloc/store_follow_bloc.dart';
import 'custom_toast.dart';

/// Shared "follow store" heart icon used by every store-card surface.
///
/// Hoisted out of `popular_shop_card.dart` so the same auth-gate +
/// optimistic-toggle + ApiException-toast logic is reused by every card
/// (popular shop strip, listing-page banner, market-category list, map
/// popup, store-detail header, home browse-stores strip). This guarantees
/// every surface flips together the moment any one of them is tapped and
/// avoids 4-5 copies of the same code drifting apart.
///
/// Subscribes via [StoreFollowController.listenableFor] scoped to the given
/// [storeId] so unrelated card rebuilds are avoided when other stores'
/// follow buckets change.
///
/// Callers MUST have seeded the controller with the latest server snapshot
/// (typically via `StoreFollowController.instance.seedFromStore(...)`) before
/// rendering this widget; the [fallbackIsFollowed] / [fallbackFollowersCount]
/// params are only used to paint the first frame before the controller has
/// any state for the store.
class StoreFollowHeart extends StatelessWidget {
  /// Backend store-id this heart is bound to. All [StoreFollowController]
  /// reads / writes are keyed by this id.
  final int storeId;

  /// Initial follow flag from the server payload. Only used until the
  /// controller is seeded (typically same frame).
  final bool fallbackIsFollowed;

  /// Initial followers count from the server payload. Same usage notes as
  /// [fallbackIsFollowed].
  final int fallbackFollowersCount;

  /// Square size of the icon glyph itself. The hit-target is sized to
  /// `iconSize + 10` so even small icons stay tappable.
  final double iconSize;

  /// Optional handler that completely overrides the default toggle flow.
  /// Useful when a parent already knows how to handle the press (e.g. the
  /// legacy [PopularShopCard] external `onWishlistTap` hook). Auth-gating
  /// must be handled by the override in that case.
  final VoidCallback? onTapOverride;

  /// When true the heart paints inside a circular material surface (used
  /// on store-detail page headers so the icon stays legible on top of a
  /// banner image). Defaults to false (transparent).
  final bool circularSurface;

  /// Optional override colour for the un-followed icon glyph. Defaults to
  /// `onSurface.withValues(alpha: 0.75)`.
  final Color? inactiveColor;

  const StoreFollowHeart({
    super.key,
    required this.storeId,
    required this.fallbackIsFollowed,
    required this.fallbackFollowersCount,
    this.iconSize = 18,
    this.onTapOverride,
    this.circularSurface = false,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = StoreFollowController.instance;

    return ListenableBuilder(
      listenable: controller.listenableFor(storeId),
      builder: (context, _) {
        final state = controller.stateOf(storeId);
        final isFollowed = state?.isFollowed ?? fallbackIsFollowed;
        final isPending = state?.isPending ?? false;

        final double hit = iconSize + 10;

        final button = SizedBox(
          height: hit,
          width: hit,
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: iconSize,
            visualDensity: VisualDensity.compact,
            tooltip: isFollowed ? 'Unfollow' : 'Follow',
            onPressed: isPending
                ? null
                : (onTapOverride ?? () => _handleTap(context)),
            icon: Icon(
              isFollowed ? Icons.favorite : Icons.favorite_border,
              size: iconSize,
              color: isFollowed
                  ? Colors.redAccent
                  : (inactiveColor ??
                      theme.colorScheme.onSurface.withValues(alpha: 0.75)),
            ),
          ),
        );

        if (!circularSurface) return button;

        // Detail-page mode: paint the heart inside a soft circular surface
        // so it stays readable on top of the banner image.
        return Material(
          color: theme.colorScheme.surface.withValues(alpha: 0.92),
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: button,
          ),
        );
      },
    );
  }

  /// Default tap handler — auth-gates unauthenticated users to the login
  /// screen, then fires an optimistic toggle via [StoreFollowController].
  /// Any [ApiException] surfaces as a non-blocking toast so the UI behaves
  /// the same way on every card.
  Future<void> _handleTap(BuildContext context) async {
    if (Global.userData == null) {
      GoRouter.of(context).push(AppRoutes.login);
      return;
    }
    try {
      await StoreFollowController.instance.toggle(storeId);
    } on ApiException catch (e) {
      if (context.mounted) {
        ToastManager.show(context: context, message: e.errorMessage);
      }
    } catch (e) {
      if (context.mounted) {
        ToastManager.show(context: context, message: e.toString());
      }
    }
  }
}
