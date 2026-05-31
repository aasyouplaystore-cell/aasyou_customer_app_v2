String productHeroTag(String productSlug) => 'product-image-$productSlug-${DateTime.timestamp()}';

String productGalleryHeroTag(String productSlug, int index) =>
    'product-image-$productSlug-${DateTime.timestamp()}';
