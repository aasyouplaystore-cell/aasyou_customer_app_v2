class OrderFilter {
  final String? selectedDateFilter;
  final String? selectedStatusSort;

  const OrderFilter({
    this.selectedDateFilter,
    this.selectedStatusSort,
  });

  OrderFilter copyWith({
    String? selectedStatuses,
    String? selectedSort,
  }) {
    return OrderFilter(
      selectedDateFilter: selectedStatuses ?? selectedDateFilter,
      selectedStatusSort: selectedSort ?? selectedStatusSort,
    );
  }

  int get activeCount =>
      (selectedDateFilter != null ? 1 : 0) + (selectedStatusSort != null ? 1 : 0);

  bool get hasFilters => activeCount > 0;
}