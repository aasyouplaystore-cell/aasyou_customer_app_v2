import 'package:flutter/material.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';

class CustomSubCategoryCard extends StatelessWidget {
  final String categoryImage;
  final String categoryName;
  final VoidCallback? onTap;

  const CustomSubCategoryCard({
    super.key,
    required this.categoryName,
    required this.categoryImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CustomImageContainer(
                    imagePath: categoryImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  categoryName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
