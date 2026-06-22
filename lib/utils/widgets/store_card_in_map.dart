import 'package:flutter/material.dart';
import 'package:aasyou/l10n/app_localizations.dart';

import '../../config/theme.dart';
import '../../screens/near_by_stores/model/near_by_store_model.dart';
import '../../screens/store_follow/bloc/store_follow_bloc.dart';
import 'custom_image_container.dart';
import 'store_follow_heart.dart';

class StoreCardInMap extends StatelessWidget {
  final StoreData store;
  final VoidCallback? onTap;

  const StoreCardInMap({
    super.key,
    required this.store,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double distance = store.distance ?? 0.0;
    final double rating = double.parse(store.avgStoreRating ?? '0.0');
    final int totalStoreFeedback = store.totalStoreFeedback!;

    // Seed the Shop-Follow controller so the heart on this map-popup card
    // stays in sync with every other card showing the same store.
    final int? storeId = store.id;
    if (storeId != null) {
      StoreFollowController.instance.seedFromStore(
        storeId: storeId,
        isFollowed: store.isFollowed,
        followersCount: store.followersCount,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------- Banner + Logo + Rating -------------------
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: store.banner?.isNotEmpty == true
                        ? CustomImageContainer(
                      imagePath: store.banner!,
                      fit: BoxFit.cover,

                    )
                        : _gradientPlaceholder(),
                  ),
                ),

                // Shop-Follow heart anchored to the banner top-right.
                if (storeId != null)
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: Material(
                      color:
                          Theme.of(context).colorScheme.surface.withValues(
                                alpha: 0.92,
                              ),
                      shape: const CircleBorder(),
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.18),
                      child: StoreFollowHeart(
                        storeId: storeId,
                        fallbackIsFollowed: store.isFollowed ?? false,
                        fallbackFollowersCount: store.followersCount ?? 0,
                        iconSize: 18,
                      ),
                    ),
                  ),

                // Circular Logo (bottom-left)
                PositionedDirectional(
                  start: 16,
                  bottom: -40,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2, strokeAlign: BorderSide.strokeAlignCenter),
                    ),
                    child: ClipOval(
                      child: store.logo?.isNotEmpty == true
                          ? CustomImageContainer(
                        imagePath: store.logo!,
                        fit: BoxFit.cover,

                      )
                          : _iconPlaceholder(),
                    ),
                  ),
                ),

                // Rating badge (top-right)
                PositionedDirectional(
                  end: 12,
                  bottom: -40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(AppTheme.ratingStarIconFilled, size: 12, color: AppTheme.ratingStarColor),
                        const SizedBox(width: 4),
                        Text('${rating.toStringAsFixed(1)}/5 ($totalStoreFeedback)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ------------------- Store Info -------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name ?? "Unknown Store",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                store.address ?? "No address",
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                maxLines: 4,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),


                  if(store.sameLocation == false)...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12)
                        ),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)!.noteThisStoreIsNOtAvailableInYourLocation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ]

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientPlaceholder() => Container(
    decoration: const BoxDecoration(
        color: AppTheme.primaryColor
    ),
    child: const Center(child: Icon(Icons.store, size: 50, color: Colors.white70)),
  );

  Widget _iconPlaceholder() => Container(
    color: Colors.blue.shade50,
    child: const Icon(Icons.store, size: 28, color: AppTheme.primaryColor),
  );
}