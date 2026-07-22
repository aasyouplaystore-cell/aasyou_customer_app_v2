import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../screens/near_by_stores/model/near_by_store_model.dart';
import '../../screens/store_follow/bloc/store_follow_bloc.dart';
import 'cache_manager.dart';
import 'store_follow_heart.dart';

/// Compact vertical "popular shop" card used in horizontal strips.
///
/// Phase B (B3) primitive + Shop-Follow:
///  - Fixed compact width (~160-180); caller sizes via SizedBox/ListView.
///  - Top media: AspectRatio 16:12 + ClipRRect rounded 12 with
///    [CachedNetworkImage] from `store.banner` (falls back to `store.logo`).
///  - Body: padded Column with the store name, then a row showing star rating
///    and a follow/heart [IconButton] on the right.
///  - Surface uses `theme.colorScheme.surface` (theme-aware light/dark) with
///    rounded 12 corners and a subtle elevation.
///  - InkWell tap routes to the store detail page using the same
///    `nearbyStoreDetails` route + `{store-slug, store-name}` extras pattern
///    used by [HomeBrowseStoresSection].
///
/// The heart icon is now wired to [StoreFollowController]:
///  * On build we seed the controller with the latest server values from
///    [StoreData] (`isFollowed` / `followersCount`) so the controller and
///    every other card render in sync.
///  * Tapping the heart fires an optimistic toggle + POST/DELETE call.
///  * If the user is unauthenticated we route them to the login screen
///    rather than calling the API (which would 401 + toast).
class PopularShopCard extends StatelessWidget {
  /// Store payload backing the card.
  final StoreData store;

  /// Optional tap override. When null, taps push the store detail route using
  /// the standard pattern, so this widget can be dropped into any strip
  /// without the caller wiring routing.
  final VoidCallback? onTap;

  /// Optional override for the heart icon press. When null the card runs
  /// the standard Shop-Follow toggle (auth check + optimistic toggle).
  final VoidCallback? onWishlistTap;

  const PopularShopCard({
    super.key,
    required this.store,
    this.onTap,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double rating =
        double.tryParse(store.avgStoreRating ?? '0.0') ?? 0.0;
    final String? imageUrl = (store.banner?.isNotEmpty ?? false)
        ? store.banner
        : ((store.logo?.isNotEmpty ?? false) ? store.logo : null);

    // Seed the controller from the server snapshot so every card stays in
    // sync. seedFromStore() is a no-op while an in-flight toggle is pending
    // for the store, so we don't stomp on the user's most recent tap.
    final controller = StoreFollowController.instance;
    final storeId = store.id;
    if (storeId != null) {
      controller.seedFromStore(
        storeId: storeId,
        isFollowed: store.isFollowed,
        followersCount: store.followersCount,
      );
    }

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => _openDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ------------------- Top media (16:12) -------------------
            AspectRatio(
              aspectRatio: 16 / 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        memCacheWidth: 700,
                        cacheManager: customCacheManager,
                        placeholder: (context, _) => _MediaPlaceholder(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (context, _, __) => _MediaPlaceholder(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      )
                    : _MediaPlaceholder(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
              ),
            ),

            // ------------------- Body -------------------
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    store.name ?? 'Unknown Store',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.80),
                        ),
                      ),
                      const Spacer(),
                      // Shop-Follow heart. ListenableBuilder scoped to this
                      // single store so unrelated card rebuilds are avoided.
                      if (storeId != null)
                        StoreFollowHeart(
                          storeId: storeId,
                          fallbackIsFollowed: store.isFollowed ?? false,
                          fallbackFollowersCount: store.followersCount ?? 0,
                          onTapOverride: onWishlistTap,
                        )
                      else
                        // Defensive: if no id we render the legacy UI-only
                        // heart so layout stays consistent.
                        SizedBox(
                          height: 28,
                          width: 28,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Follow',
                            onPressed: onWishlistTap ?? () {},
                            icon: Icon(
                              Icons.favorite_border,
                              size: 18,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Default route-push when [onTap] isn't supplied. Mirrors the existing
  /// `_openDetail` pattern in `home_browse_stores_section.dart` so the card
  /// works as a drop-in primitive without caller wiring.
  void _openDetail(BuildContext context) {
    final slug = store.slug;
    if (slug == null || slug.isEmpty) return;
    GoRouter.of(context).push(
      AppRoutes.nearbyStoreDetails,
      extra: {
        'store-slug': slug,
        'store-name': store.name,
      },
    );
  }
}

/// Subtle neutral placeholder shown while the network image is loading or
/// when the store has no banner/logo at all. Uses a theme-aware container
/// surface tint so it sits naturally on top of the card.
class _MediaPlaceholder extends StatelessWidget {
  final Color color;

  const _MediaPlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_outlined,
        size: 28,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}
