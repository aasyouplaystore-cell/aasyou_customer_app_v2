import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/user_cart_model/cart_addon.dart';
import 'package:aasyou/model/user_cart_model/cart_sync_action.dart';
import 'package:aasyou/model/user_cart_model/user_cart.dart';
import 'package:aasyou/screens/product_detail_page/model/product_detail_model.dart';
import 'package:aasyou/screens/product_detail_page/widgets/price_row_widget.dart';
import 'package:aasyou/screens/product_detail_page/widgets/product_addons_section.dart';
import 'package:aasyou/services/user_cart/cart_validation.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_image_container.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';


Future<void> showAddonPickerSheet({
  required BuildContext context,
  required ProductData product,
  required ProductVariants selectedVariant,
}) {
  // Capture the parent's CartBloc + context so the sheet (which lives in
  final CartBloc parentCartBloc = context.read<CartBloc>();
  final BuildContext parentContext = context;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    useRootNavigator: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    builder: (_) => _AddonPickerSheetBody(
      product: product,
      selectedVariant: selectedVariant,
      parentCartBloc: parentCartBloc,
      parentContext: parentContext,
      onClose: () {
        GoRouter.of(context).pop();
      },
    ),
  );
}

class _AddonPickerSheetBody extends StatefulWidget {
  final ProductData product;
  final ProductVariants selectedVariant;
  final CartBloc parentCartBloc;
  final BuildContext parentContext;
  final VoidCallback? onClose;

  const _AddonPickerSheetBody({
    required this.product,
    required this.selectedVariant,
    required this.parentCartBloc,
    required this.parentContext,
    this.onClose,
  });

  @override
  State<_AddonPickerSheetBody> createState() => _AddonPickerSheetBodyState();
}

class _AddonPickerSheetBodyState extends State<_AddonPickerSheetBody> {
  late final Map<int, Set<int>> _selections;

  late final Map<int, bool> _errors;
  int _shakeSeed = 0;

  @override
  void initState() {
    super.initState();
    _selections = {
      for (final group in widget.selectedVariant.addonGroups)
        group.id: <int>{},
    };
    _errors = {
      for (final group in widget.selectedVariant.addonGroups)
        group.id: false,
    };
  }

  // ─── Selection handler ──────────────────────────────────────────────────
  void _onChanged(AddonGroup group, Set<int> next) {
    setState(() {
      _selections[group.id] = next;
      if (_errors[group.id] == true && next.isNotEmpty) {
        _errors[group.id] = false;
      }
    });
  }

  // ─── Validation ─────────────────────────────────────────────────────────

  bool _validateRequired() {
    bool ok = true;
    final newErrors = <int, bool>{};
    for (final group in widget.selectedVariant.addonGroups) {
      final selected = _selections[group.id] ?? const <int>{};
      final isInvalid = group.isRequired && selected.isEmpty;
      newErrors[group.id] = isInvalid;
      if (isInvalid) ok = false;
    }
    if (!ok) HapticFeedback.mediumImpact();
    setState(() {
      _errors
        ..clear()
        ..addAll(newErrors);
      if (!ok) _shakeSeed++;
    });
    return ok;
  }

  // ─── Snapshot selected addons into CartAddon list ───────────────────────
  List<CartAddon> _buildSelectedAddons() {
    final List<CartAddon> result = [];
    for (final group in widget.selectedVariant.addonGroups) {
      final selectedIds = _selections[group.id] ?? const <int>{};
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

  double get _addonsTotal => _buildSelectedAddons()
      .fold<double>(0.0, (sum, addon) => sum + addon.price);

  // ─── Confirm / add to cart ─────────────────────────────────────────────
  void _onAddPressed() {
    if (!_validateRequired()) return;

    final isStoreOpen = widget.product.storeStatus?.isOpen ?? true;
    final qty = widget.product.quantityStepSize;

    final productError = CartValidation.validateProductAddToCart(
      context: widget.parentContext,
      requestedQuantity: qty,
      minQty: widget.product.minimumOrderQuantity,
      maxQty: widget.product.totalAllowedQuantity,
      stock: widget.selectedVariant.stock,
      isStoreOpen: isStoreOpen,
    );

    if (productError != null) {
      ToastManager.show(
        context: widget.parentContext,
        message: productError,
        type: ToastType.error,
      );
      return;
    }

    final item = UserCart(
      productId: widget.product.id.toString(),
      variantId: widget.selectedVariant.id.toString(),
      variantName: widget.selectedVariant.title,
      vendorId: widget.selectedVariant.storeId.toString(),
      name: widget.product.title,
      image: widget.product.mainImage,
      price: widget.selectedVariant.specialPrice.toDouble(),
      originalPrice: widget.selectedVariant.price.toDouble(),
      quantity: qty,
      serverCartItemId: null,
      syncAction: CartSyncAction.add,
      updatedAt: DateTime.now(),
      minQty: widget.product.minimumOrderQuantity,
      maxQty: widget.product.totalAllowedQuantity,
      isOutOfStock: widget.selectedVariant.stock <= 0,
      isSynced: false,
      addons: _buildSelectedAddons(),
    );

    widget.parentCartBloc.add(AddToCart(
      item: item,
      context: widget.parentContext,
    ));

    Navigator.of(context).pop();
  }

  // ─── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final variantSale = widget.selectedVariant.specialPrice.toDouble();
    final variantOrig = widget.selectedVariant.price.toDouble();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(color: colorScheme.outline),
          _SheetHeader(
            product: widget.product,
            colorScheme: colorScheme,
            onClose: () => Navigator.of(context).pop(),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),

          // Scrollable addon groups
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: ProductAddonsSection(
                groups: widget.selectedVariant.addonGroups,
                selections: _selections,
                errors: _errors,
                shakeSeed: _shakeSeed,
                onChanged: _onChanged,
              ),
            ),
          ),

          Divider(height: 1, color: colorScheme.outlineVariant),

          // Footer: live total + Add button
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: PriceRowWidget(
                      originalPrice: variantOrig + _addonsTotal,
                      salePrice: variantSale + _addonsTotal,
                      fontSize: 16.sp,
                      originalFontSize: 11.sp,
                      discountFontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      originalPriceColor: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    width: 140.w,
                    height: 46.h,
                    child: CustomButton(
                      onPressed: _onAddPressed,
                      child: Text(
                        l10n.add,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final Color color;
  const _DragHandle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final ProductData product;
  final ColorScheme colorScheme;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.product,
    required this.colorScheme,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CustomImageContainer(
              imagePath: product.mainImage,
              height: 48.r,
              width: 48.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.customisable,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            iconSize: 20.r,
            color: colorScheme.onSurfaceVariant,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
