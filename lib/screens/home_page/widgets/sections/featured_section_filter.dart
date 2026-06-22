import 'package:aasyou/screens/home_page/model/featured_section_product_model.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';

/// Shared helper used by the per-`section_type` home widgets
/// (`HomeFeaturedProductsSection`, `HomeTopRatedSection`, and the
/// D-phase `HomeMangoManiaSection`).
///
/// The `/featured-sections` endpoint returns a flat list of sections, each
/// tagged with a `section_type` ("featured", "top_rated", "newly_added",
/// ...). Phase C splits the legacy single `HomeFeaturedSection` into one
/// widget per section type. To keep that split DRY, each widget delegates
/// the "filter sections by type, merge their products, pick a heading" work
/// to this helper.
///
/// Behaviour:
///   - matches case-insensitively on `section_type`
///   - skips sections with empty product lists
///   - merges products across all matching sections, preserving order
///   - caps the merged list at [maxProducts]
///   - chooses the heading + slug from the first matching section that has
///     a non-empty title; falls back to [fallbackTitle] when no section
///     carries one
///   - sums `productsCount` across matching sections so the See-All target
///     count is accurate even when the API splits a logical bucket into
///     multiple section rows
class FeaturedSectionTypeFilter {
  final String title;
  final String slug;
  final int? totalCount;
  final List<ProductData> products;

  const FeaturedSectionTypeFilter._({
    required this.title,
    required this.slug,
    required this.totalCount,
    required this.products,
  });

  static FeaturedSectionTypeFilter filter({
    required List<FeaturedSectionData> sections,
    required String sectionType,
    required int maxProducts,
    String fallbackTitle = '',
  }) {
    final wanted = sectionType.toLowerCase();
    final matches = sections.where((s) {
      final t = (s.sectionType ?? '').toLowerCase();
      return t == wanted && s.products.isNotEmpty;
    }).toList();

    if (matches.isEmpty) {
      return FeaturedSectionTypeFilter._(
        title: fallbackTitle,
        slug: '',
        totalCount: null,
        products: const [],
      );
    }

    final FeaturedSectionData heading = matches.firstWhere(
      (s) => (s.title ?? '').trim().isNotEmpty,
      orElse: () => matches.first,
    );

    final merged = <ProductData>[];
    for (final s in matches) {
      for (final p in s.products) {
        if (merged.length >= maxProducts) break;
        merged.add(p);
      }
      if (merged.length >= maxProducts) break;
    }

    int? total;
    for (final s in matches) {
      final c = s.productsCount;
      if (c != null) total = (total ?? 0) + c;
    }

    final resolvedTitle = (heading.title ?? '').trim().isNotEmpty
        ? heading.title!.trim()
        : fallbackTitle;

    return FeaturedSectionTypeFilter._(
      title: resolvedTitle,
      slug: heading.slug ?? '',
      totalCount: total,
      products: merged,
    );
  }
}
