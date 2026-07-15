class OrderFilter {
  final String? selectedDateFilter;
  final String? selectedStatusSort;

  /// Billing-type: 'online' (app/web orders) | 'offline' (store/POS bills)
  /// | 'khata' (udhaar bills). null = all.
  final String? selectedBilling;

  const OrderFilter({
    this.selectedDateFilter,
    this.selectedStatusSort,
    this.selectedBilling,
  });

  OrderFilter copyWith({
    String? selectedStatuses,
    String? selectedSort,
    String? selectedBilling,
  }) {
    return OrderFilter(
      selectedDateFilter: selectedStatuses ?? selectedDateFilter,
      selectedStatusSort: selectedSort ?? selectedStatusSort,
      selectedBilling: selectedBilling ?? this.selectedBilling,
    );
  }

  int get activeCount =>
      (selectedDateFilter != null ? 1 : 0) +
      (selectedStatusSort != null ? 1 : 0) +
      (selectedBilling != null ? 1 : 0);

  bool get hasFilters => activeCount > 0;
}