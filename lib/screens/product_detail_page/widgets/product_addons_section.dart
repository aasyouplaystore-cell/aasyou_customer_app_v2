import 'package:flutter/material.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/utils/widgets/custom_addon_section.dart';

/// Inline AddOns picker rendered on the product detail page.
class ProductAddonsSection extends StatelessWidget {
  final List<AddonGroup> groups;
  final Map<int, Set<int>> selections;
  final Map<int, bool> errors;
  final int shakeSeed;
  final void Function(AddonGroup group, Set<int> next) onChanged;

  const ProductAddonsSection({
    super.key,
    required this.groups,
    required this.selections,
    required this.errors,
    required this.shakeSeed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return CustomAddonSection(
          group: group,
          selectedItemIds: selections[group.id] ?? const <int>{},
          showError: errors[group.id] ?? false,
          shakeSeed: shakeSeed,
          onChanged: (next) => onChanged(group, next),
        );
      },
    );
  }
}
