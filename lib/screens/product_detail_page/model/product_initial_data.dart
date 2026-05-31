/// Lightweight product payload passed to [ProductDetailPage] so the.
class ProductInitialData {
  final String title;
  final String mainImage;
  final List<String> additionalImages;
  final String videoUrl;

  ProductInitialData({
    required this.title,
    required this.mainImage,
    this.additionalImages = const [],
    this.videoUrl = '',
  });
}
