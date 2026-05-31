import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/user_cart_model/cart_addon.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import 'package:aasyou/screens/cart_page/bloc/cart_addon_edit_bloc/cart_addon_edit_bloc.dart';
import 'package:aasyou/screens/cart_page/bloc/cart_addon_edit_bloc/cart_addon_edit_event.dart';
import 'package:aasyou/screens/cart_page/bloc/cart_addon_edit_bloc/cart_addon_edit_state.dart';
import 'package:aasyou/screens/cart_page/model/get_cart_model.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_detail_page/widgets/product_addons_section.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/quantity_stepper_inner.dart';

Future<void> showAddonEditBottomSheet({
  required BuildContext context,
  required CartItem cartItem,
  int? addressId,
  String? promoCode,
  bool? rushDelivery,
  bool? useWallet,
}) {

  final CartBloc parentCartBloc = context.read<CartBloc>();
  final BuildContext parentContext = context;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    builder: (sheetContext) {
      return BlocProvider<CartAddonEditBloc>(
        create: (_) => CartAddonEditBloc()
          ..add(FetchCartAddonCatalog(
            productSlug: cartItem.product?.slug ?? '',
          )),
        child: _AddonEditSheetBody(
          cartItem: cartItem,
          parentCartBloc: parentCartBloc,
          parentContext: parentContext,
          addressId: addressId,
          promoCode: promoCode,
          rushDelivery: rushDelivery,
          useWallet: useWallet,
        ),
      );
    },
  );
}

class _AddonEditSheetBody extends StatefulWidget {
  final CartItem cartItem;
  final CartBloc parentCartBloc;
  final BuildContext parentContext;
  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;

  const _AddonEditSheetBody({
    required this.cartItem,
    required this.parentCartBloc,
    required this.parentContext,
    this.addressId,
    this.promoCode,
    this.rushDelivery,
    this.useWallet,
  });

  @override
  State<_AddonEditSheetBody> createState() => _AddonEditSheetBodyState();
}

class _AddonEditSheetBodyState extends State<_AddonEditSheetBody> {
  ProductData? _product;

  final Map<int, Set<int>> _selections = <int, Set<int>>{};

  final Map<int, bool> _errors = <int, bool>{};

  int _shakeSeed = 0;

  int _qty = 1;

  /// Change-detection baselines captured at open time.
  late final int _initialQty;
  late final Set<int> _initialSelectedIds;

  /// True once [_hydrate] has run for the first [CartAddonEditLoaded].
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _initialQty = widget.cartItem.quantity ?? 1;
    _qty = _initialQty;
    _initialSelectedIds = widget.cartItem.addons
        .map((a) => a.addonItemId ?? 0)
        .where((id) => id > 0)
        .toSet();
  }

  void _hydrate(ProductData product) {
    if (product.variants.isEmpty) {
      setState(() {
        _product = product;
        _selections.clear();
        _errors.clear();
        _hydrated = true;
      });
      return;
    }

    final int cartVariantId = widget.cartItem.productVariantId ?? 0;
    final ProductVariants resolvedVariant = product.variants.firstWhere(
      (v) => v.id == cartVariantId,
      orElse: () => product.variants.first,
    );

    final nextSelections = <int, Set<int>>{};
    final nextErrors = <int, bool>{};
    for (final group in resolvedVariant.addonGroups) {
      final preselected = widget.cartItem.addons
          .where((a) => (a.addonGroupId ?? -1) == group.id)
          .map((a) => a.addonItemId ?? 0)
          .where((id) => id > 0)
          .toSet();
      nextSelections[group.id] = preselected;
      nextErrors[group.id] = false;
    }

    setState(() {
      _product = product;
      _selections
        ..clear()
        ..addAll(nextSelections);
      _errors
        ..clear()
        ..addAll(nextErrors);
      _hydrated = true;
    });
  }

  // ---- Derived getters -----------------------------------------------------

  ProductVariants? get _currentVariant {
    final product = _product;
    if (product == null || product.variants.isEmpty) return null;
    final int cartVariantId = widget.cartItem.productVariantId ?? 0;
    return product.variants.firstWhere(
      (v) => v.id == cartVariantId,
      orElse: () => product.variants.first,
    );
  }

  List<AddonGroup> get _currentAddonGroups =>
      _currentVariant?.addonGroups ?? const [];

  bool get _qtyChanged => _qty != _initialQty;

  bool get _addonsChanged {
    final current = <int>{};
    for (final ids in _selections.values) {
      current.addAll(ids);
    }
    if (current.length != _initialSelectedIds.length) return true;
    return !current.containsAll(_initialSelectedIds);
  }

  bool get _anythingChanged => _qtyChanged || _addonsChanged;

  /// Variant price resolved to "special price when it's a real discount.
  double _variantPrice(ProductVariants variant) {
    final regular = variant.price;
    final special = variant.specialPrice;
    return (special > 0 && special < regular) ? special : regular;
  }

  /// Sum of all currently-selected addon unit prices for the current.
  double _addonsTotal() {
    double total = 0;
    for (final group in _currentAddonGroups) {
      final selected = _selections[group.id] ?? const <int>{};
      if (selected.isEmpty) continue;
      for (final item in group.items) {
        if (selected.contains(item.id)) total += item.price;
      }
    }
    return total;
  }

  double _displayTotal() {
    final variant = _currentVariant;
    if (variant == null) return 0;
    return (_variantPrice(variant) + _addonsTotal()) * _qty;
  }

  // ---- Selection / validation handlers ------------------------------------

  void _onGroupSelectionChanged(AddonGroup group, Set<int> next) {
    setState(() {
      _selections[group.id] = next;
      if ((_errors[group.id] ?? false) && next.isNotEmpty) {
        _errors[group.id] = false;
      }
    });
  }

  /// Validates required groups.
  bool _validateRequiredGroups(List<AddonGroup> groups) {
    bool allValid = true;
    final newErrors = <int, bool>{};
    for (final group in groups) {
      final selected = _selections[group.id] ?? const <int>{};
      final invalid = group.isRequired && selected.isEmpty;
      newErrors[group.id] = invalid;
      if (invalid) allValid = false;
    }
    setState(() {
      HapticFeedback.mediumImpact();
      _errors
        ..clear()
        ..addAll(newErrors);
      if (!allValid) _shakeSeed++;
    });
    return allValid;
  }

  // ---- Cart-key / payload builders ----------------------------------------

  /// Recomputes the current Hive cartKey for the row being edited.
  String _originalCartKey() {
    final productId = (widget.cartItem.product?.id ??
            widget.cartItem.productId ??
            0)
        .toString();
    final variantId = (widget.cartItem.productVariantId ?? 0).toString();
    final existing = widget.cartItem.addons
        .map((a) => a.addonItemId ?? 0)
        .where((id) => id > 0)
        .toList()
      ..sort();
    if (existing.isEmpty) return '${productId}_$variantId';
    return '${productId}_${variantId}_${existing.join('-')}';
  }

  /// Builds the [CartAddon] list that matches [_selections] for the.
  List<CartAddon> _buildUpdatedAddons() {
    final List<CartAddon> next = [];
    for (final group in _currentAddonGroups) {
      final selectedIds = _selections[group.id] ?? const <int>{};
      if (selectedIds.isEmpty) continue;
      for (final item in group.items) {
        if (selectedIds.contains(item.id)) {
          next.add(CartAddon(
            addonGroupId: group.id,
            addonItemId: item.id,
            title: item.title,
            price: item.price,
          ));
        }
      }
    }
    return next;
  }

  // ---- Save -------------------------------------------------------------

  /// Validates required groups, then dispatches a single.
  void _onSavePressed() {
    final product = _product;
    final variant = _currentVariant;
    if (product == null || variant == null) return;

    if (!_validateRequiredGroups(_currentAddonGroups)) return;

    if (!_anythingChanged) {
      Navigator.of(context).pop();
      return;
    }

    final updatedAddons = _buildUpdatedAddons();

    widget.parentCartBloc.add(UpdateCartItemAddons(
      cartKey: _originalCartKey(),
      addons: updatedAddons,
      quantity: _qtyChanged ? _qty : null,
      context: widget.parentContext,
      addressId: widget.addressId,
      promoCode: widget.promoCode,
      rushDelivery: widget.rushDelivery,
      useWallet: widget.useWallet,
      isFromCartPage: true,
    ));

    Navigator.of(context).pop();
  }

  // ---- Build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Floating dark close button floats above the sheet — mirrors
        Positioned(
          top: -50,
          child: Semantics(
            button: true,
            label: l10n?.close ?? 'Close',
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surface
                      : Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: isDark
                      ? Border.all(
                          color: theme.colorScheme.outline, width: 1)
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
        ),

        // Main sheet
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(l10n),
              Flexible(
                child: BlocConsumer<CartAddonEditBloc, CartAddonEditState>(
                  // Hydrate state exactly once, on the first Loaded event —
                  listener: (blocContext, state) {
                    if (state is CartAddonEditLoaded && !_hydrated) {
                      _hydrate(state.product);
                    }
                  },
                  builder: (blocContext, state) {
                    if (state is CartAddonEditLoading ||
                        state is CartAddonEditInitial) {
                      return _buildLoading();
                    }
                    if (state is CartAddonEditFailed) {
                      return _buildError(blocContext, l10n);
                    }
                    if (state is CartAddonEditLoaded && _hydrated) {
                      return _buildLoadedBody(l10n);
                    }
                    return _buildLoading();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final String productName = widget.cartItem.product?.name ?? '';
    final String variantTitle = widget.cartItem.variant?.title ?? '';
    final String productImage = widget.cartItem.product?.image ?? '';
    // Variant is fixed on this sheet — present it as a static subtitle
    final String subtitle = variantTitle.isEmpty
        ? productName
        : (productName.isEmpty
            ? variantTitle
            : '$productName · $variantTitle');

    // Header keeps the existing plain-padding treatment — only the
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: theme.colorScheme.onPrimary,
            ),
            clipBehavior: Clip.antiAlias,
            child: productImage.isNotEmpty
                ? CustomImageContainer(
                    imagePath: productImage,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n?.editAddOnsTitle ?? 'Edit Add-ons',
                  style: TextStyle(
                    fontSize: isTablet(context) ? 20 : 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.tertiary,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet(context) ? 14 : 11.sp,
                      color: Colors.grey.shade600,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Center(
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext blocContext, AppLocalizations? l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.alert_circle,
            size: isTablet(context) ? 40 : 32.r,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n?.addOnsLoadError ?? 'Could not load add-ons',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet(context) ? 16 : 13.sp,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () {
              blocContext.read<CartAddonEditBloc>().add(
                    FetchCartAddonCatalog(
                      productSlug: widget.cartItem.product?.slug ?? '',
                    ),
                  );
            },
            child: Text(
              l10n?.retry ?? 'Retry',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: isTablet(context) ? 15 : 13.sp,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedBody(AppLocalizations? l10n) {
    final product = _product;
    if (product == null || product.variants.isEmpty) {
      return _buildNoCatalog(l10n);
    }

    final groups = _currentAddonGroups;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          // Horizontal padding is intentionally zero here so the addon
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (groups.isNotEmpty)
                  ProductAddonsSection(
                    groups: groups,
                    selections: _selections,
                    errors: _errors,
                    shakeSeed: _shakeSeed,
                    onChanged: _onGroupSelectionChanged,
                  )
                else
                  // Only the qty can be changed here — hint the user so an
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 16.h),
                    child: Row(
                      children: [
                        Icon(
                          TablerIcons.info_circle,
                          size: isTablet(context) ? 20 : 16.r,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            l10n?.noAddOnsAvailable ??
                                'No add-ons available for this item',
                            style: TextStyle(
                              fontSize: isTablet(context) ? 14 : 12.sp,
                              color: Colors.grey.shade600,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        _buildFooter(l10n),
      ],
    );
  }

  Widget _buildNoCatalog(AppLocalizations? l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TablerIcons.basket,
            size: isTablet(context) ? 40 : 32.r,
            color: Colors.grey.shade500,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n?.noAddOnsAvailable ??
                'No add-ons available for this item',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet(context) ? 15 : 12.sp,
              color: Colors.grey.shade600,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 20.h),
          CustomButton(
            text: l10n?.close ?? 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final product = _product;
    final variant = _currentVariant;
    if (product == null || variant == null) return const SizedBox.shrink();

    final int stepSize =
        product.quantityStepSize > 0 ? product.quantityStepSize : 1;
    final int minQty = product.minimumOrderQuantity > 0
        ? product.minimumOrderQuantity
        : 1;
    final int maxQty = product.totalAllowedQuantity > 0
        ? product.totalAllowedQuantity
        : 100;

    // Footer styled to mirror the variant sheet's bottom bar: surface
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
            // Quantity stepper — styled to mirror the variant sheet footer.
            Container(
              width: 110.w,
              height: isTablet(context) ? 40.h : 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
              child: QuantityStepperInner(
                key: const ValueKey('edit_sheet_stepper'),
                quantity: _qty,
                currentLocalQty: _qty,
                stepSize: stepSize,
                isStoreOpen: true,
                stock: variant.stock,
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
              child: CustomButton(
                onPressed: _onSavePressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        l10n?.saveChanges ?? 'Save Changes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet(context) ? 16 : 13.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimary,
                          fontFamily: AppTheme.fontFamily,
                        ),
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
                        fontSize: isTablet(context) ? 16 : 13.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimary,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
