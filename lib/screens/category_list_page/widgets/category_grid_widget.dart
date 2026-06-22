import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import '../../../router/app_routes.dart';
import '../../home_page/model/category_model.dart';
import '../../product_listing_page/model/product_listing_type.dart';

class CategoryGridWidget extends StatelessWidget {
  final List<CategoryData> categories;
  final EdgeInsets padding;
  final double spacing;

  const CategoryGridWidget({
    super.key,
    required this.categories,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    this.spacing = 12.0,
  });

  /// Phone = 4 cols (per user spec — denser grid).
  /// Tablet = 5, large tablet = 6.
  int _crossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 6;
    if (screenWidth >= 800) return 5;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount(context),
          crossAxisSpacing: 8,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryListTile(
            category: category,
            onTap: () {
              GoRouter.of(context).push(AppRoutes.productListing, extra: {
                'isTheirMoreCategory':
                    (category.subcategoryCount ?? 0) > 0 ? true : false,
                'title': category.title,
                'logo': category.image,
                'totalProduct': category.productCount,
                'type': ProductListingType.category,
                'identifier': category.slug,
              });
            },
          );
        },
      ),
    );
  }
}

/// Tile used on the Categories list page (`/categories`).
///
/// Soft cream-tinted card with a visible border, a clear peach blob behind
/// the product photo, decorative peach speckles in the corners, and the
/// category name bold below. Matches the designer mockup.
class _CategoryListTile extends StatelessWidget {
  final CategoryData category;
  final VoidCallback onTap;

  const _CategoryListTile({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFFFFF7EF);
    const Color cardBorder = Color(0xFFFFE3CC);
    const Color peach = Color(0xFFFFD2B0);
    const Color peachSoft = Color(0xFFFFE0C6);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6A1F).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(3, 10, 3, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Decorative peach circles in the corners.
                      Positioned(
                        top: 0,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: peach,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: peach,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 4,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: peachSoft,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Large peach blob behind the icon
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              peachSoft,
                              peach,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Foreground product image / icon
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: CustomImageContainer(
                            imagePath: category.image ?? '',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    category.title ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                      height: 1.2,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCardWithFixedColor extends StatelessWidget {
  final String name;
  final String imagePath;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isNetworkImage;

  const CategoryCardWithFixedColor({
    super.key,
    required this.name,
    required this.imagePath,
    required this.backgroundColor,
    this.onTap,
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomImageContainer(
                        imagePath: imagePath,
                        fit: BoxFit.contain,
                      )
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
