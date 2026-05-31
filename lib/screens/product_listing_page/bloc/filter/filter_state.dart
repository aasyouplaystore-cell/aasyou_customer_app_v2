//





class FilterState {
  final Set<String> selectedCategorySlugs;
  final Set<String> selectedBrandSlugs;
  final Set<int> selectedAttributeValueIds;     // ← changed to int

  final bool isApplied;

  FilterState({
    Set<String>? selectedCategorySlugs,
    Set<String>? selectedBrandSlugs,
    Set<int>? selectedAttributeValueIds,
    this.isApplied = false,
  })  : selectedCategorySlugs = selectedCategorySlugs ?? {},
        selectedBrandSlugs = selectedBrandSlugs ?? {},
        selectedAttributeValueIds = selectedAttributeValueIds ?? {};

  FilterState copyWith({
    Set<String>? selectedCategorySlugs,
    Set<String>? selectedBrandSlugs,
    Set<int>? selectedAttributeValueIds,
    bool? isApplied,
  }) {
    return FilterState(
      selectedCategorySlugs: selectedCategorySlugs ?? Set.from(this.selectedCategorySlugs),
      selectedBrandSlugs: selectedBrandSlugs ?? Set.from(this.selectedBrandSlugs),
      selectedAttributeValueIds:
      selectedAttributeValueIds ?? Set.from(this.selectedAttributeValueIds),
      isApplied: isApplied ?? this.isApplied,
    );
  }

  int get selectedCategoriesCount => selectedCategorySlugs.length;
  int get selectedBrandsCount => selectedBrandSlugs.length;
  int get selectedAttributesCount => selectedAttributeValueIds.length;

  int get totalSelectedCount =>
      selectedCategoriesCount + selectedBrandsCount + selectedAttributesCount;

  bool get hasActiveFilters =>
      selectedCategorySlugs.isNotEmpty ||
          selectedBrandSlugs.isNotEmpty ||
          selectedAttributeValueIds.isNotEmpty;

  bool isAttributeSelected(int id) => selectedAttributeValueIds.contains(id);

  FilterState toggleAttribute(int id) {
    final newSet = Set<int>.from(selectedAttributeValueIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    return copyWith(selectedAttributeValueIds: newSet);
  }
}