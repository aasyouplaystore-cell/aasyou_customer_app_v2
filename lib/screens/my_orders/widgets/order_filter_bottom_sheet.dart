// lib/screens/my_orders/widgets/order_filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import '../model/order_filter_model.dart';

class OrderFilterSheet extends StatefulWidget {
  final List<String> dateOptions;   // from settings API
  final List<String> sortOptions;     // from settings API
  final OrderFilter currentFilter;
  final ValueChanged<OrderFilter> onApply;

  const OrderFilterSheet({
    super.key,
    required this.dateOptions,
    required this.sortOptions,
    required this.currentFilter,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required List<String> dateOptions,
    required List<String> sortOptions,
    required OrderFilter currentFilter,
    required ValueChanged<OrderFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => OrderFilterSheet(
        dateOptions: dateOptions,
        sortOptions: sortOptions,
        currentFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends State<OrderFilterSheet> {
  late String? _selectedDateFilter;
  late String? _selectedStatusSort;

  @override
  void initState() {
    super.initState();
    _selectedDateFilter = widget.currentFilter.selectedDateFilter;
    _selectedStatusSort = widget.currentFilter.selectedStatusSort;
  }

  void _toggleStatus(String status) {
    setState(() {
      if(_selectedDateFilter == status){
        _selectedDateFilter = null;
        return;
      } else {
        _selectedDateFilter = status;
        return;
      }
    });
  }

  void _toggleSort(String sort) {
    setState(() {
      if(_selectedStatusSort == sort){
        _selectedStatusSort = null;
        return;
      } else {
        _selectedStatusSort = sort;
        return;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedDateFilter = null;
      _selectedStatusSort = null;
    });
    widget.onApply(OrderFilter(
      selectedDateFilter: _selectedDateFilter,
      selectedStatusSort: _selectedStatusSort,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
        
            const Divider(height: 1),
        
            // --- Section 1: Order Status (single-select) ---
            const _SectionLabel(label: 'Date Range'),
            _ChipWrap(
              options: widget.dateOptions,
              selected: _selectedDateFilter != null ? {_selectedDateFilter!} : {},
              onTap: _toggleStatus,
            ),
        
            const SizedBox(height: 8),
        
            // --- Section 2: Sort By (single-select) ---
            const _SectionLabel(label: 'Sort by'),
            _ChipWrap(
              options: widget.sortOptions,
              selected: _selectedStatusSort != null ? {_selectedStatusSort!} : {},
              onTap: _toggleSort,
              singleSelect: true,
            ),
        
            const SizedBox(height: 16),
        
            // Apply button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  isDisabled: _selectedStatusSort == null && _selectedDateFilter == null,
                  onPressed: () {
                    widget.onApply(OrderFilter(
                      selectedDateFilter: _selectedDateFilter,
                      selectedStatusSort: _selectedStatusSort,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Apply filters',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onTap;
  final bool singleSelect;

  const _ChipWrap({
    required this.options,
    required this.selected,
    required this.onTap,
    this.singleSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = selected.contains(option);
          return FilterChip(
            label: Text(
              removeUnderscores(capitalizeFirstLetter(option)),
              style: TextStyle(
                color: isSelected ? Colors.white : null,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onTap(option),
            showCheckmark: false,
            color: WidgetStatePropertyAll(isSelected ? AppTheme.primaryColor.withValues(alpha: 0.8) : Colors.transparent),
          );
        }).toList(),
      ),
    );
  }
}