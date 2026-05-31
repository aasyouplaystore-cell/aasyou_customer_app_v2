import 'package:flutter/material.dart';

import '../../../utils/widgets/custom_image_container.dart';

Widget buildTabIcon(dynamic category, bool isSelected) {
  String? imageUrl;
  if (category.icon != null && category.icon!.isNotEmpty) {
    imageUrl = isSelected && category.activeIcon != null
        ? category.activeIcon
        : category.icon;
  } else if (category.image != null && category.image!.isNotEmpty) {
    imageUrl = category.image;
  }
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CustomImageContainer(
      imagePath: imageUrl,
      fit: BoxFit.contain,
    );
  } else {
    return const Icon(
      Icons.category_outlined,
      size: 28,
    );
  }
}