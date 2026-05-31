import 'package:hive/hive.dart';

part 'recent_product_model.g.dart'; // ← this will be generated

@HiveType(typeId: 3)
class RecentProduct extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String productSlug;

  RecentProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productSlug,
  });
}
