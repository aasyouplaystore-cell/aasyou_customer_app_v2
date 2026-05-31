import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/config/helper.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/user_cart_model/cart_addon.dart';
import 'package:aasyou/model/user_cart_model/cart_sync_action.dart';
import 'package:aasyou/model/user_cart_model/user_cart.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/services/user_cart/cart_validation.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/utils/widgets/product_indicator.dart';
import 'package:aasyou/utils/widgets/quantity_stepper_inner.dart';
import 'package:spring_bottom_sheet/spring_bottom_sheet.dart';
import 'custom_addon_section.dart';

void showVariantBottomSheetWithAddons({
  required List<ProductVariants> variantsList,
  required ProductData productData,
  required String productImage,
  required int quantityStepSize,
  required BuildContext context,
  int? addressId,
  String? promoCode,
  bool? rushDelivery,
  bool? useWallet,
  bool? isFromCartPage,
}) {
  final storeId = variantsList.isNotEmpty ? variantsList.first.storeId : null;


  final BuildContext parentContext = context;
  final CartBloc parentCartBloc = context.read<CartBloc>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    useRootNavigator: true,
    builder: (BuildContext bottomSheetContext) {
      return SpringBottomSheet(
        child: VariantSelectionBottomSheet(
          variants: variantsList,
          productData: productData,
          productTitle: productData.title,
          productImage: productImage,
          width: MediaQuery.of(bottomSheetContext).size.width,
          height: MediaQuery.of(bottomSheetContext).size.height,
          storeId: storeId,
          onVariantSelected: (ProductVariants selectedVariant) {},
          onClose: () {
            GoRouter.of(context).pop();
          },
          addressId: addressId,
          promoCode: promoCode,
          rushDelivery: rushDelivery,
          useWallet: useWallet,
          isFromCartPage: isFromCartPage,
          parentContext: parentContext,
          parentCartBloc: parentCartBloc,
        ),
      );
    },
  );
}

class VariantSelectionBottomSheet extends StatefulWidget {
  final List<ProductVariants> variants;
  final ProductData productData;
  final String productImage;
  final String productTitle;
  final Function(ProductVariants)? onVariantSelected;
  final double? width;
  final double? height;
  final int? storeId;
  final VoidCallback? onClose;
  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;
  final bool? isFromCartPage;

  /// Caller's BuildContext.
  final BuildContext parentContext;

  /// Caller's [CartBloc] instance.
  final CartBloc parentCartBloc;

  const VariantSelectionBottomSheet({
    super.key,
    required this.variants,
    required this.productData,
    required this.productImage,
    required this.productTitle,
    this.onVariantSelected,
    this.width,
    this.height,
    this.storeId,
    this.onClose,
    this.addressId,
    this.promoCode,
    this.rushDelivery,
    this.useWallet,
    this.isFromCartPage,
    required this.parentContext,
    required this.parentCartBloc,
  });

  @override
  State<VariantSelectionBottomSheet> createState() =>
      _VariantSelectionBottomSheetState();
}

class _VariantSelectionBottomSheetState
    extends State<VariantSelectionBottomSheet> {
  late String selectedVariant = '';
  int _qty = 1;

  /// Per-group selection state, keyed by [AddonGroup.id].
  final Map<int, Set<int>> _groupSelections = {};

  /// Per-group error flags.
  final Map<int, bool> _groupErrors = {};

  /// Increments every time [_validateRequiredGroups] flags at least one.
  int _shakeSeed = 0;

  Color _mutedTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6);

  @override
  void initState() {
    super.initState();
    final defaultVariant = widget.productData.variants
        .where((data) => data.isDefault == true)
        .toList();
    selectedVariant = defaultVariant.isNotEmpty
        ? defaultVariant.first.id.toString()
        : (widget.variants.isNotEmpty
            ? widget.variants.first.id.toString()
            : '');

    // Seed the stepper to the smallest value that satisfies both the
    final int stepSize = widget.productData.quantityStepSize > 0
        ? widget.productData.quantityStepSize
        : 1;
    final int minQty = widget.productData.minimumOrderQuantity > 0
        ? widget.productData.minimumOrderQuantity
        : 1;
    _qty = minQty > stepSize ? minQty : stepSize;

    _initSelectionsForCurrentVariant();
  }

  // ---- Selected variant helpers -------------------------------------------

  ProductVariants? get _currentVariant {
    if (widget.variants.isEmpty) return null;
    return widget.variants.firstWhere(
      (v) => v.id.toString() == selectedVariant,
      orElse: () => widget.variants.first,
    );
  }

  List<AddonGroup> get _currentAddonGroups =>
      _currentVariant?.addonGroups ?? const [];

  /// Pre-populates [_groupSelections] for the current variant with an empty.
  void _initSelectionsForCurrentVariant() {
    _groupSelections.clear();
    _groupErrors.clear();
    for (final group in _currentAddonGroups) {
      _groupSelections[group.id] = <int>{};
      _groupErrors[group.id] = false;
    }
  }

  // ---- Selection / validation handlers ------------------------------------

  void _onGroupSelectionChanged(AddonGroup group, Set<int> next) {
    setState(() {
      _groupSelections[group.id] = next;
      // Clear any prior error for this group once the user interacts.
      if (_groupErrors[group.id] == true && next.isNotEmpty) {
        _groupErrors[group.id] = false;
      }
    });
  }

  /// Returns true when every required group has at least one selection.
  bool _validateRequiredGroups() {
    bool allValid = true;
    final newErrors = <int, bool>{};
    for (final group in _currentAddonGroups) {
      final selected = _groupSelections[group.id] ?? const <int>{};
      final isInvalid = group.isRequired && selected.isEmpty;
      newErrors[group.id] = isInvalid;
      if (isInvalid) allValid = false;
    }
    setState(() {
      HapticFeedback.mediumImpact();
      _groupErrors
        ..clear()
        ..addAll(newErrors);
      // Bump the seed so any currently-visible error messages re-shake,
      if (!allValid) _shakeSeed++;
    });
    return allValid;
  }

  /// Sum of prices of every currently-selected addon item across all groups.
  double _addonsTotal() {
    double total = 0;
    for (final group in _currentAddonGroups) {
      final selected = _groupSelections[group.id] ?? const <int>{};
      if (selected.isEmpty) continue;
      for (final item in group.items) {
        if (selected.contains(item.id)) total += item.price;
      }
    }
    return total;
  }

  /// Snapshot of the currently-selected addon items for the active.
  List<CartAddon> _buildSelectedAddonsForCart() {
    if (_currentAddonGroups.isEmpty) return const <CartAddon>[];
    final List<CartAddon> result = [];
    for (final group in _currentAddonGroups) {
      final selectedIds = _groupSelections[group.id] ?? const <int>{};
      if (selectedIds.isEmpty) continue;
      for (final item in group.items) {
        if (!selectedIds.contains(item.id)) continue;
        result.add(CartAddon(
          addonGroupId: group.id,
          addonItemId: item.id,
          title: item.title,
          price: item.price,
        ));
      }
    }
    return result;
  }

  /// Handles the bottom-bar "Add" tap: validates required addon groups.
  void _onAddPressed() {
    if (!_validateRequiredGroups()) return;

    final variant = _currentVariant;
    if (variant == null) return;

    final product = widget.productData;
    final isStoreOpen = product.storeStatus?.isOpen ?? true;

    final productError = CartValidation.validateProductAddToCart(
      context: context,
      requestedQuantity: _qty,
      minQty: product.minimumOrderQuantity,
      maxQty: product.totalAllowedQuantity,
      stock: variant.stock,
      isStoreOpen: isStoreOpen,
    );

    if (productError != null) {
      ToastManager.show(
        context: context,
        message: productError,
        type: ToastType.error,
      );
      return;
    }

    final List<CartAddon> selectedAddons = _buildSelectedAddonsForCart();

    final item = UserCart(
      productId: product.id.toString(),
      variantId: variant.id.toString(),
      variantName: variant.title,
      vendorId: variant.storeId.toString(),
      name: product.title,
      image: product.mainImage,
      price: _resolvedPrice(),
      originalPrice: variant.price.toDouble(),
      quantity: _qty,
      minQty: product.minimumOrderQuantity > 0
          ? product.minimumOrderQuantity
          : 1,
      maxQty: product.totalAllowedQuantity > 0
          ? product.totalAllowedQuantity
          : 100,
      isOutOfStock: variant.stock <= 0,
      isSynced: false,
      serverCartItemId: null,
      syncAction: CartSyncAction.add,
      updatedAt: DateTime.now(),
      addons: selectedAddons,
    );

    widget.parentCartBloc.add(AddToCart(
      item: item,
      context: widget.parentContext,
      addressId: widget.addressId,
      promoCode: widget.promoCode,
      rushDelivery: widget.rushDelivery,
      useWallet: widget.useWallet,
      isFromCartPage: widget.isFromCartPage,
    ));

    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    log('Addon List $_currentAddonGroups');
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Floating dark close button (sits above sheet, like Swiggy)
        Positioned(
          top: -50,
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface
                    : Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: isDark
                    ? Border.all(color: theme.colorScheme.outline, width: 1)
                    : null,
              ),
              child: Icon(
                Icons.close,
                color: isDark ? theme.colorScheme.tertiary : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),

        // Main sheet
        Container(
          constraints: BoxConstraints(
            maxHeight: widget.height! * 0.85,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),

              // Body
              Flexible(
                child: ListView(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 16.h),
                  children: [
                    _buildVariantSection(),
                    _buildAddonsList(_currentAddonGroups),
                  ],
                ),
              ),

              _buildBottomBar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: theme.colorScheme.onPrimary,
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.productImage.isNotEmpty
                ? CustomImageContainer(
                    imagePath: widget.productImage,
                    width: 44.w,
                    height: 44.w,
                    fit: BoxFit.cover,
                    placeholder:
                        const Center(child: CustomCircularProgressIndicator()),
                  )
                : Icon(Icons.image_outlined,
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
                    size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              widget.productTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.tertiary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSection() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectVariant,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context)?.addonHintSelectOne ??
                      'Select any 1',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: _mutedTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 4.h),
              itemCount: widget.variants.length,
              separatorBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              itemBuilder: (context, index) {
                return _buildVariantItem(
                  widget.variants[index],
                  widget.productData.mainImage,
                  widget.productData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    // Stepper bounds sourced from the live product/variant instead of
    final ProductVariants? activeVariant = _currentVariant;
    final int stepSize = widget.productData.quantityStepSize > 0
        ? widget.productData.quantityStepSize
        : 1;
    final int minQty = widget.productData.minimumOrderQuantity > 0
        ? widget.productData.minimumOrderQuantity
        : 1;
    final int maxQty = widget.productData.totalAllowedQuantity > 0
        ? widget.productData.totalAllowedQuantity
        : 100;
    final int stock = activeVariant?.stock ?? 0;
    final bool isStoreOpen =
        widget.productData.storeStatus?.isOpen ?? true;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            // Quantity stepper
            Container(
              width: 110.w,
              height: (isTablet(context) ? 40.h : 48),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
              child: QuantityStepperInner(
                color: AppTheme.primaryColor,
                key: const ValueKey('stepper_inner'),
                quantity: _qty,
                currentLocalQty: _qty,
                stepSize: stepSize,
                isStoreOpen: isStoreOpen,
                stock: stock,
                minQty: minQty,
                totalAllowedQuantity: maxQty,
                onIncrement: () {
                  setState(() {
                    if (_qty + stepSize <= maxQty) _qty += stepSize;
                  });
                },
                onDecrement: () {
                  setState(() {
                    if (_qty - stepSize >= minQty) _qty -= stepSize;
                  });
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                // height: 4.h,
                child: CustomButton(
                  onPressed: _onAddPressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.add,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        height: 18.h,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        '${AppHelpers.currency}${formatPrice(_displayTotal(), locale: AppHelpers.defaultLocalCurrency)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantItem(
      ProductVariants variant, String mainImage, ProductData product) {
    final theme = Theme.of(context);
    final double regular = double.tryParse(variant.price.toString()) ?? 0.0;
    final double special =
        double.tryParse(variant.specialPrice.toString()) ?? 0.0;
    final bool hasDiscount = special > 0 && special < regular;
    final String displayPrice =
        hasDiscount ? special.toStringAsFixed(2) : regular.toStringAsFixed(2);
    final formattedDisplay =
        formatPrice(double.parse(displayPrice),
            locale: AppHelpers.defaultLocalCurrency);

    return RadioGroup<String>(
      groupValue: selectedVariant,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedVariant = value;
            // Each variant ships its own addon groups — reset selections.
            _initSelectionsForCurrentVariant();
          });
        }
      },
      child: InkWell(
        onTap: () {
          setState(() {
            selectedVariant = variant.id.toString();
            _initSelectionsForCurrentVariant();
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              productIndicator('veg'),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  variant.title,
                  style: TextStyle(
                    fontSize: isTablet(context) ? 18 : 14.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${AppHelpers.currency}$formattedDisplay',
                style: TextStyle(
                  fontSize: isTablet(context) ? 18 : 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              if (hasDiscount)
                Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Text(
                    '${AppHelpers.currency}${formatPrice(regular, locale: AppHelpers.defaultLocalCurrency)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _mutedTextColor(context),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              SizedBox(width: 12.w),
              Radio<String>(
                value: variant.id.toString(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddonsList(List<AddonGroup> addonList) {
    if (addonList.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addonList.length,
      itemBuilder: (context, index) {
        final group = addonList[index];
        return CustomAddonSection(
          group: group,
          selectedItemIds: _groupSelections[group.id] ?? const <int>{},
          showError: _groupErrors[group.id] ?? false,
          shakeSeed: _shakeSeed,
          onChanged: (next) => _onGroupSelectionChanged(group, next),
        );
      },
    );
  }

  double _resolvedPrice() {
    if (widget.variants.isEmpty) return 0.0;
    final selected = widget.variants.firstWhere(
      (v) => v.id.toString() == selectedVariant,
      orElse: () => widget.variants.first,
    );
    final regular = double.tryParse(selected.price.toString()) ?? 0.0;
    final special = double.tryParse(selected.specialPrice.toString()) ?? 0.0;
    return (special > 0 && special < regular) ? special : regular;
  }

  /// Total displayed in the Add button.
  double _displayTotal() {
    final perUnit = _resolvedPrice() + _addonsTotal();
    return perUnit * _qty;
  }
}
