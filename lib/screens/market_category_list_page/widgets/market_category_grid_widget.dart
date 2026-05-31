import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../../utils/widgets/custom_market_category_card.dart';
import '../../home_page/model/market_category_model.dart';

/// Grid for [MarketCategoryData]. Mirrors [CategoryGridWidget]'s responsive
/// breakpoints but uses [CustomMarketCategoryCard] (intrinsic 4:5 via
/// `AspectRatio`, so `childAspectRatio` is set to 0.80 instead of 0.60).
///
/// Tap pushes the Market Category detail screen (recursive drill-down for
/// subcategories).
class MarketCategoryGridWidget extends StatelessWidget {
  final List<MarketCategoryData> categories;
  final EdgeInsets padding;

  const MarketCategoryGridWidget({
    super.key,
    required this.categories,
    this.padding = const EdgeInsets.all(10.0),
  });

  int _crossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return 8;
    if (screenWidth >= 800) return 5;
    if (screenWidth >= 600) return 4;
    if (screenWidth >= 400) return 3;
    return 2;
  }

  double _spacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.03;
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
          crossAxisSpacing: _spacing(context),
          mainAxisSpacing: _spacing(context),
          // 4:5 card aspect ratio (matches CustomMarketCategoryCard).
          childAspectRatio: 4 / 5,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];
          return CustomMarketCategoryCard(
            data: item,
            onTap: () {
              final slug = item.slug ?? '';
              if (slug.isEmpty) return;
              GoRouter.of(context).push(
                AppRoutes.marketCategoryDetailPage,
                extra: {'slug': slug},
              );
            },
          );
        },
      ),
    );
  }
}
