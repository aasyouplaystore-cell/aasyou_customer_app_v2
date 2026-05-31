import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/screens/product_listing_page/bloc/filter_product/filter_product_event.dart';
import 'package:aasyou/screens/product_listing_page/model/filter_product_model.dart';
import 'package:aasyou/config/theme.dart';
import '../../screens/product_listing_page/bloc/filter/filter_bloc.dart';
import '../../screens/product_listing_page/bloc/filter/filter_event.dart';
import '../../screens/product_listing_page/bloc/filter/filter_state.dart';
import '../../screens/product_listing_page/bloc/filter_product/filter_product_bloc.dart';
import '../../screens/product_listing_page/bloc/filter_product/filter_product_state.dart';
import '../../screens/product_listing_page/model/product_listing_type.dart';

enum FilterTab { categories, brands, attributes }

class CustomFilterBottomSheet extends StatefulWidget {
  final Function(List<FilterCategories>, List<FilterBrands>, List<AttributesValues>) onApplyFilters;
  final ProductListingType listingType;
  final List<int> categoryIds;
  final List<int> brandsIds;
  final String value;

  const CustomFilterBottomSheet({
    super.key,
    required this.onApplyFilters,
    required this.listingType,
    required this.categoryIds,
    required this.brandsIds,
    required this.value
  });

  @override
  State<CustomFilterBottomSheet> createState() => _CustomFilterBottomSheetState();

  static void show({
    required BuildContext context,
    required Function(List<FilterCategories>, List<FilterBrands>, List<AttributesValues>) onApplyFilters,
    required ProductListingType listingType,
    required List<int> categoryIds,
    required List<int> brandsIds,
    required String value
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomFilterBottomSheet(
              onApplyFilters: onApplyFilters,
              listingType: listingType,
              categoryIds: categoryIds,
              brandsIds: brandsIds,
              value: value,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomFilterBottomSheetState extends State<CustomFilterBottomSheet> {
  List<FilterCategories> allCategories = [];
  List<FilterBrands> allBrands = [];
  List<FilterAttributesValues> allAttributeGroups = [];

  String selectedTab = 'categories';

  @override
  void initState() {
    super.initState();
    if (widget.listingType == ProductListingType.category) {
      selectedTab = 'brands';
    }
    context.read<FilterProductBloc>().add(FetchFilterData(
      context: context,
      categorySlugs: null,
      brandSlugs: null,
      attributeIds: null,
      filterType: widget.listingType,
      value: widget.value,
    ));
    // context.read<FilterBrandsBloc>().add(FetchFilterBrands(categorySlug: '', brandsIds: widget.brandsIds));
    context.read<FilterBloc>().add(InitializeFilters());
  }

  void _clearFilters() {
    context.read<FilterBloc>().add(ClearAllFilters());
  }

  void _applyFilters(FilterState filterState) {
    // Filter and return only selected items
    final selectedCategories = allCategories
        .where((category) => filterState.selectedCategorySlugs.contains(category.slug))
        .toList();

    final selectedBrands = allBrands
        .where((brand) => filterState.selectedBrandSlugs.contains(brand.slug))
        .toList();

    final selectedAttributeValues = allAttributeGroups
        .expand((group) => group.values)
        .where((v) => v.id != null && filterState.selectedAttributeValueIds.contains(v.id))
        .toList();

    context.read<FilterBloc>().add(ApplyFilters());
    widget.onApplyFilters(selectedCategories, selectedBrands, selectedAttributeValues);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, filterState) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              topRight: Radius.circular(14.r),
            ),
          ),
          child: Column(
            children: [
              // Header with total filter count
              _buildHeader(filterState),

              // Content area with tabs and list
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.0,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterTabs(filterState),
                      Expanded(
                        child: _buildContent(filterState),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              _buildBottomButtons(context, filterState),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(FilterState filterState) {
    if (selectedTab == 'categories') {
      return _buildCategoriesList(filterState);
    } else if (selectedTab == 'brands') {
      return _buildBrandsList(filterState);
    } else if (selectedTab.startsWith('attribute_')) {
      final slug = selectedTab.substring('attribute_'.length);
      final group = allAttributeGroups.firstWhere(
            (g) => g.slug == slug,
        orElse: () => FilterAttributesValues(title: 'Unknown', values: []),
      );
      return _buildAttributeGroupList(group, filterState);
    }
    return _buildEmptyState('Invalid tab');
  }

  Widget _buildAttributeGroupList(FilterAttributesValues group, FilterState filterState) {
    return BlocBuilder<FilterProductBloc, FilterProductState>(
      builder:(BuildContext context, FilterProductState state) {
        if(state is FilterProductLoaded) {
          final values = group.values;
          if (values.isEmpty) {
            return _buildEmptyState('No values available');
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: values.length,
            itemBuilder: (context, index) {
              final value = values[index];
              final isSelected = filterState.selectedAttributeValueIds.contains(value.id);
              final isEnabled = value.enabled ?? true;

              return CheckboxListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.title ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isEnabled
                              ? (isSelected ? AppTheme.primaryColor : Theme.of(context).textTheme.bodyMedium?.color)
                              : Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                value: isSelected,
                onChanged: isEnabled
                    ? (bool? checked) {
                  if (value.id != null) {
                    context.read<FilterBloc>().add(
                      ToggleAttributeValueSelection(value.id!),
                    );
                  }
                }
                    : null,
                activeColor: AppTheme.primaryColor,
                checkColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                dense: true,
                tileColor: isEnabled ? null : Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.06),
              );
            },
          );
        }
        else if(state is FilterProductLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        );
      }
    );

  }

  Widget _buildHeader(FilterState filterState) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.filters,
            style: TextStyle(
              fontSize: isTablet(context) ? 24 : 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          if (filterState.hasActiveFilters) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${filterState.totalSelectedCount}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterTabs(FilterState filterState) {
    return BlocBuilder<FilterProductBloc, FilterProductState>(
      builder: (context, state) {
        if (state is FilterProductLoaded) {
          allAttributeGroups = state.filterAttributesValues;
        }

        return Container(
          padding: const EdgeInsets.only(top: 8),
          width: 110.w,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: ListView(
            children: [
              if (widget.listingType != ProductListingType.category)
                _buildFilterTab(
                  title: 'Categories',
                  tabId: 'categories',
                  selectedCount: filterState.selectedCategoriesCount,
                ),
              if (widget.listingType != ProductListingType.brand)
                _buildFilterTab(
                  title: 'Brands',
                  tabId: 'brands',
                  selectedCount: filterState.selectedBrandsCount,
                ),
              ...allAttributeGroups.map((group) {
                final selectedCount = group.values.where((v) => filterState.selectedAttributeValueIds.contains(v.id)).length;
                return _buildFilterTab(
                  title: group.title ?? 'Unknown',
                  tabId: 'attribute_${group.slug}',
                  selectedCount: selectedCount,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTab({
    required String title,
    required String tabId,
    required int selectedCount,
  }) {
    final isSelected = selectedTab == tabId;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = tabId;
        });
        final filterState = BlocProvider.of<FilterBloc>(context).state;
        context.read<FilterProductBloc>().add(FetchFilterData(
          context: context,
          categorySlugs: filterState.selectedCategorySlugs.toList(),
          brandSlugs: filterState.selectedBrandSlugs.toList(),
          attributeIds: filterState.selectedAttributeValueIds.toList(),
          filterType: widget.listingType,
          value: widget.value,
        ));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected ? [
              AppTheme.primaryColor.withValues(alpha: 0.2),
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.primaryColor.withValues(alpha: 0.05),
              Colors.transparent,
              Colors.transparent,
            ] : [Colors.transparent, Colors.transparent, Colors.transparent, Colors.transparent, Colors.transparent],
            stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
          ),
          border: Border(
            left: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            if (selectedCount > 0) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$selectedCount',
                  style: TextStyle(
                    fontSize: isTablet(context) ? 14 : 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, FilterState filterState) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Clear Filters button
          Expanded(
            child: OutlinedButton(
              onPressed: filterState.hasActiveFilters ? _clearFilters : null,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(
                  color: filterState.hasActiveFilters
                      ? AppTheme.primaryColor
                      : Theme.of(context).colorScheme.outline,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                disabledForegroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                disabledBackgroundColor: Colors.transparent,
              ),
              child: Text(
                l10n?.clearFilters ?? 'Clear Filters',
                style: TextStyle(
                  fontSize: isTablet(context) ? 18 : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: filterState.hasActiveFilters
                      ? AppTheme.primaryColor
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Apply Filters button
          Expanded(
            child: ElevatedButton(
              onPressed: () => _applyFilters(filterState),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                l10n?.applyFilters ?? 'Apply Filters',
                style: TextStyle(
                  fontSize: isTablet(context) ? 18 : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(FilterState filterState) {
    return BlocBuilder<FilterProductBloc, FilterProductState>(
      builder: (BuildContext context, FilterProductState state) {
        if (state is FilterProductLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        if (state is FilterProductLoaded) {
          allCategories = state.filterCategories
              .where((category) => category.status == 'active')
              .toList();

          if (allCategories.isEmpty) {
            return _buildEmptyState('No categories available');
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final isSelected = filterState.selectedCategorySlugs.contains(category.slug);

              return _buildCategoryItem(category, isSelected);
            },
          );
        }

        if (state is FilterProductFailed) {
          return _buildErrorState('Failed to load categories');
        }

        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(FilterCategories category, bool isSelected) {
    final isEnabled = category.enabled ?? true;

    return CheckboxListTile(
      title: Text(
        category.title ?? 'Unknown',
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isEnabled
              ? (isSelected ? AppTheme.primaryColor : Theme.of(context).textTheme.bodyMedium?.color)
              : Theme.of(context).colorScheme.onSecondaryContainer, // Disabled text color
          fontFamily: AppTheme.fontFamily,
        ),
      ),
      value: isSelected,
      onChanged: isEnabled
          ? (bool? value) {
        context.read<FilterBloc>().add(
          ToggleCategorySelection(category.slug!),
        );
      }
          : null,
      activeColor: AppTheme.primaryColor,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      dense: true,
      visualDensity: VisualDensity.compact,
      // Optional: lower opacity when disabled
      tileColor: isEnabled ? null : Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.06),
    );
  }

  Widget _buildBrandsList(FilterState filterState) {
    return BlocBuilder<FilterProductBloc, FilterProductState>(
      builder: (BuildContext context, FilterProductState state) {
        if (state is FilterProductLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        if (state is FilterProductLoaded) {
          allBrands = state.filterBrands
              .where((brand) => brand.status == 'active')
              .toList();

          if (allBrands.isEmpty) {
            return _buildEmptyState('No brands available');
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: allBrands.length,
            itemBuilder: (context, index) {
              final brand = allBrands[index];
              final isSelected = filterState.selectedBrandSlugs.contains(brand.slug);

              return _buildBrandItem(brand, isSelected);
            },
          );
        }

        if (state is FilterProductFailed) {
          return _buildErrorState('Failed to load brands');
        }

        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildBrandItem(FilterBrands brand, bool isSelected) {
    final isEnabled = brand.enabled ?? true;

    return CheckboxListTile(
      title: Row(
        children: [
          if (brand.logo != null && brand.logo!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: Opacity(
                opacity: isEnabled ? 1.0 : 0.5,
                child: Image.network(
                  brand.logo!,
                  width: 30.w,
                  height: 30.w,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        Icons.broken_image,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Text(
              brand.title ?? 'Unknown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isEnabled
                    ? (isSelected ? AppTheme.primaryColor : Theme.of(context).textTheme.bodyMedium?.color)
                    : Theme.of(context).colorScheme.onSecondaryContainer,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ],
      ),
      value: isSelected,
      onChanged: isEnabled
          ? (bool? value) {
        context.read<FilterBloc>().add(
          ToggleBrandSelection(brand.slug!),
        );
      }
          : null,
      activeColor: AppTheme.primaryColor,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      dense: true,
      visualDensity: VisualDensity.compact,
      tileColor: isEnabled ? null : Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.06),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 48.sp,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(
              fontSize: isTablet(context) ? 18 : 14.sp,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.red[300],
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(
              fontSize: isTablet(context) ? 18 : 14.sp,
              color: Colors.red[400],
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}







//
