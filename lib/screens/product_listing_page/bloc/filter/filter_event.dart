// filter_event.dart
abstract class FilterEvent {}

class InitializeFilters extends FilterEvent {}

class ToggleCategorySelection extends FilterEvent {
  final String categorySlug;
  ToggleCategorySelection(this.categorySlug);
}

class ToggleBrandSelection extends FilterEvent {
  final String brandSlug;
  ToggleBrandSelection(this.brandSlug);
}

class ToggleAttributeValueSelection extends FilterEvent {
  final int attributeValueId;
  ToggleAttributeValueSelection(this.attributeValueId);
}

class ClearAllFilters extends FilterEvent {}

class ApplyFilters extends FilterEvent {}