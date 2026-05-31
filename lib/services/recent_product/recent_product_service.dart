import 'package:hive/hive.dart';
import '../../model/recent_product_model/recent_product_model.dart';

class RecentlyViewedService {
  static const String boxName = 'recently_viewed';
  static const int maxItems = 12;

  static Future<Box<RecentProduct>> get _box async =>
      await Hive.openBox<RecentProduct>(boxName);

  /// Add or move product to top (most recent)
  static Future<void> addProduct(RecentProduct product) async {
    final box = await _box;

    // Remove if already exists (deduplicate)
    final existingKey = box.keys.firstWhere(
          (key) => box.get(key)?.id == product.id,
      orElse: () => null,
    );

    if (existingKey != null) {
      await box.delete(existingKey);
    }

    // Add to beginning (we'll use keys 0,1,2... for order)
    await box.add(product); // adds with auto-increment key

    // Trim if too many items
    if (box.length > maxItems) {
      final oldestKeys = box.keys.toList()..sort();
      await box.delete(oldestKeys.first); // remove oldest
    }
  }

  /// Get list in order: newest first
  static Future<List<RecentProduct>> getRecentlyViewed() async {
    final box = await _box;
    final list = box.values.toList();

    // Since add() uses increasing keys → reverse to get newest first
    return list.reversed.toList();
  }

  /// Optional: Clear all
  static Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }
}