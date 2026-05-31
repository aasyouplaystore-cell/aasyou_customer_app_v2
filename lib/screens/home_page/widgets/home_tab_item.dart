import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/settings_model/settings_model.dart';

import '../model/category_model.dart';
import 'tab_icon_widget.dart';

class HomeAllTabStatic extends StatelessWidget {
  const HomeAllTabStatic({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(HeroiconsOutline.squares2x2, size: 28),
          ),
          Text(
            AppLocalizations.of(context)!.all,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }
}

class HomeAllTabDynamic extends StatelessWidget {
  final TabController controller;
  final HomeGeneralSettings settings;

  const HomeAllTabDynamic({
    super.key,
    required this.controller,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final bool isSelected = controller.index == 0;
        final String iconUrl = isSelected
            ? (settings.activeIcon.isNotEmpty
                ? settings.activeIcon
                : settings.icon)
            : settings.icon;

        final iconWidget = iconUrl.isNotEmpty
            ? CachedNetworkImage(imageUrl: iconUrl, fit: BoxFit.contain)
            : const Icon(HeroiconsOutline.squares2x2, size: 28);

        return Tab(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 50,
                child: iconWidget,
              ),
              Text(
                settings.title.isNotEmpty
                    ? settings.title
                    : AppLocalizations.of(context)!.all,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 3),
            ],
          ),
        );
      },
    );
  }
}

class HomeCategoryTab extends StatelessWidget {
  final TabController controller;
  final CategoryData category;
  final int index;

  const HomeCategoryTab({
    super.key,
    required this.controller,
    required this.category,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final bool isSelected = controller.index == index + 1;
        return Tab(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 50,
                child: buildTabIcon(category, isSelected),
              ),
              Text(
                category.title ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 3),
            ],
          ),
        );
      },
    );
  }
}
