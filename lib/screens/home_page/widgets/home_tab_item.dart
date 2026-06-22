import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/settings_model/settings_model.dart';

import '../model/category_model.dart';
import 'tab_icon_widget.dart';

/// Shared visual chrome for the home quick-filter tabs (All / Electronics /
/// Mobile / Computer / Laptop ...). Renders a rounded white container with a
/// neutral gray border by default, and an orange-tinted border + background
/// when [isSelected] is true. Centred icon over a single-line label.
class _HomeFilterTabChrome extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;

  const _HomeFilterTabChrome({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;
    final Color borderColor = isSelected
        ? primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.6);
    final Color background = isSelected
        ? primary.withValues(alpha: 0.18)
        : theme.colorScheme.surface;
    final Color labelColor = isSelected
        ? primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 78,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeAllTabStatic extends StatelessWidget {
  const HomeAllTabStatic({super.key});

  @override
  Widget build(BuildContext context) {
    // Static variant is only used when there's no live TabController to bind
    // against; we render it in the unselected state and let the surrounding
    // TabBar's own indicator hint at the selected affordance.
    return Tab(
      height: 80,
      child: _HomeFilterTabChrome(
        icon: const Icon(HeroiconsOutline.squares2x2, size: 24),
        label: AppLocalizations.of(context)!.all,
        isSelected: false,
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
        // Two-level fallback so neither selected nor un-selected state can
        // ever be iconless. Preferred icon for the current state first, then
        // the other one, then the built-in Heroicon glyph.
        final String iconUrl = isSelected
            ? (settings.activeIcon.isNotEmpty
                ? settings.activeIcon
                : settings.icon)
            : (settings.icon.isNotEmpty
                ? settings.icon
                : settings.activeIcon);

        final iconWidget = iconUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: iconUrl,
                fit: BoxFit.contain,
                // Never let an in-flight or failed image leave the tab blank —
                // fall back to the Heroicon glyph instead.
                placeholder: (_, __) =>
                    const Icon(HeroiconsOutline.squares2x2, size: 24),
                errorWidget: (_, __, ___) =>
                    const Icon(HeroiconsOutline.squares2x2, size: 24),
              )
            : const Icon(HeroiconsOutline.squares2x2, size: 24);

        final String label = settings.title.isNotEmpty
            ? settings.title
            : AppLocalizations.of(context)!.all;

        return Tab(
          height: 80,
          child: _HomeFilterTabChrome(
            icon: iconWidget,
            label: label,
            isSelected: isSelected,
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
          height: 80,
          child: _HomeFilterTabChrome(
            icon: buildTabIcon(category, isSelected),
            label: category.title ?? '',
            isSelected: isSelected,
          ),
        );
      },
    );
  }
}
