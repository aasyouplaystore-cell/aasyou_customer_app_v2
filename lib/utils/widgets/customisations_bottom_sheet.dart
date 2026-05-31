import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_bloc.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_event.dart';
import 'package:aasyou/bloc/user_cart_bloc/user_cart_state.dart';
import 'package:aasyou/config/helper.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/model/user_cart_model/user_cart.dart';
import 'package:aasyou/screens/cart_page/bloc/get_user_cart/get_user_cart_bloc.dart';
import 'package:aasyou/screens/cart_page/model/get_cart_model.dart';
import 'package:aasyou/screens/cart_page/widgets/addon_edit_bottom_sheet.dart';
import 'package:aasyou/services/user_cart/cart_validation.dart';
import 'package:aasyou/utils/widgets/custom_button.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/utils/widgets/product_indicator.dart';


Future<void> showCustomisationsBottomSheet({
  required BuildContext context,
  required int productId,
  required int storeId,
  required String productName,
  required String productSlug,
  required String productImage,
  required int quantityStepSize,
  required int minQty,
  required int totalAllowedQuantity,
  required bool isStoreOpen,
  String? indicator,
  required VoidCallback onAddNewCustomisation,
  int? addressId,
  String? promoCode,
  bool? rushDelivery,
  bool? useWallet,
}) {

  final BuildContext parentContext = context;
  final CartBloc parentCartBloc = context.read<CartBloc>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    useRootNavigator: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    builder: (_) {
      return _CustomisationsSheetBody(
        productId: productId,
        storeId: storeId,
        productName: productName,
        productSlug: productSlug,
        productImage: productImage,
        quantityStepSize: quantityStepSize,
        minQty: minQty,
        totalAllowedQuantity: totalAllowedQuantity,
        isStoreOpen: isStoreOpen,
        indicator: indicator,
        parentContext: parentContext,
        parentCartBloc: parentCartBloc,
        onAddNewCustomisation: onAddNewCustomisation,
        addressId: addressId,
        promoCode: promoCode,
        rushDelivery: rushDelivery,
        useWallet: useWallet,
      );
    },
  );
}

class _CustomisationsSheetBody extends StatefulWidget {
  final int productId;
  final int storeId;
  final String productName;
  final String productSlug;
  final String productImage;
  final int quantityStepSize;
  final int minQty;
  final int totalAllowedQuantity;
  final bool isStoreOpen;
  final String? indicator;
  final BuildContext parentContext;
  final CartBloc parentCartBloc;
  final VoidCallback onAddNewCustomisation;
  final int? addressId;
  final String? promoCode;
  final bool? rushDelivery;
  final bool? useWallet;

  const _CustomisationsSheetBody({
    required this.productId,
    required this.storeId,
    required this.productName,
    required this.productSlug,
    required this.productImage,
    required this.quantityStepSize,
    required this.minQty,
    required this.totalAllowedQuantity,
    required this.isStoreOpen,
    required this.indicator,
    required this.parentContext,
    required this.parentCartBloc,
    required this.onAddNewCustomisation,
    required this.addressId,
    required this.promoCode,
    required this.rushDelivery,
    required this.useWallet,
  });

  @override
  State<_CustomisationsSheetBody> createState() =>
      _CustomisationsSheetBodyState();
}

class _CustomisationsSheetBodyState extends State<_CustomisationsSheetBody> {
  final Map<String, int> _drafts = <String, int>{};
  final Map<String, int> _originals = <String, int>{};
  final Map<String, UserCart> _originalRows = <String, UserCart>{};

  void _seedMissing(List<UserCart> rows) {
    for (final r in rows) {
      _originals.putIfAbsent(r.cartKey, () => r.quantity);
      _originalRows.putIfAbsent(r.cartKey, () => r);
    }
  }

  int _displayedQty(UserCart row) => _drafts[row.cartKey] ?? row.quantity;

  bool get _hasChanges {
    if (_drafts.isEmpty) return false;
    for (final e in _drafts.entries) {
      final orig = _originals[e.key];
      if (orig == null) continue;
      if (e.value != orig) return true;
    }
    return false;
  }

  List<UserCart> _rowsForProduct(CartState state) {
    if (state is! CartLoaded) return const <UserCart>[];
    final rows = state.items.where((row) {
      return int.tryParse(row.productId) == widget.productId &&
          int.tryParse(row.vendorId) == widget.storeId;
    }).toList();
    rows.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return rows;
  }

  // ---- Row actions (draft-only, no Bloc dispatch yet) --------------------

  /// Running total quantity across every seen row for this product.
  int _totalQtyAcrossRows() {
    int total = 0;
    for (final cartKey in _originals.keys) {
      final int effective =
          _drafts[cartKey] ?? _originals[cartKey] ?? 0;
      total += effective;
    }
    return total;
  }

  void _onIncrement(UserCart row) {
    HapticFeedback.lightImpact();
    final int current = _displayedQty(row);
    final int next = current + widget.quantityStepSize;

    // Product-wide cap check first: sum of effective qtys across all
    if (widget.totalAllowedQuantity > 0 &&
        _totalQtyAcrossRows() + widget.quantityStepSize >
            widget.totalAllowedQuantity) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!
            .maximumQuantityAllowed(widget.totalAllowedQuantity),
        type: ToastType.error,
      );
      return;
    }

    // Per-row validation (min order qty, stock, store-open) on the
    final error = CartValidation.validateProductAddToCart(
      context: context,
      requestedQuantity: next,
      minQty: widget.minQty,
      maxQty: widget.totalAllowedQuantity,
      stock: row.isOutOfStock ? 0 : widget.totalAllowedQuantity,
      isStoreOpen: widget.isStoreOpen,
    );
    if (error != null) {
      ToastManager.show(
        context: context,
        message: error,
        type: ToastType.error,
      );
      return;
    }

    setState(() => _drafts[row.cartKey] = next);
  }

  void _onDecrement(UserCart row) {
    HapticFeedback.lightImpact();
    final int current = _displayedQty(row);
    if (current <= 0) return;
    final int candidateNext = current - widget.quantityStepSize;

    // Minimum-order-qty guard: decrementing below the product's
    final int next;
    if (candidateNext <= 0) {
      next = 0;
    } else if (widget.minQty > 0 && candidateNext < widget.minQty) {
      next = 0;
    } else {
      next = candidateNext;
    }

    setState(() => _drafts[row.cartKey] = next);
  }


  void _onConfirm() {
    for (final e in _drafts.entries) {
      final orig = _originals[e.key];
      if (orig == null || e.value == orig) continue;
      final row = _originalRows[e.key];
      if (row == null) continue;

      if (e.value <= 0) {
        widget.parentCartBloc.add(RemoveFromCart(
          cartKey: e.key,
          context: widget.parentContext,
          addressId: widget.addressId,
          promoCode: widget.promoCode,
          rushDelivery: widget.rushDelivery,
          useWallet: widget.useWallet,
          isFromCartPage: false,
        ));
      } else {
        widget.parentCartBloc.add(UpdateCartQty(
          cartKey: e.key,
          quantity: e.value,
          cartItemId: row.serverCartItemId,
          context: widget.parentContext,
          addressId: widget.addressId,
          promoCode: widget.promoCode,
          rushDelivery: widget.rushDelivery,
          useWallet: widget.useWallet,
          isFromCartPage: false,
        ));
      }
    }
    Navigator.of(context).pop();
  }

  void _onEditRow(UserCart row) {

    final CartItem? serverItem = _lookupServerCartItem(row);
    if (serverItem == null) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)?.addOnsLoadError ??
            'Could not load add-ons',
        type: ToastType.error,
      );
      return;
    }

    // If the user has pending qty drafts, commit them first so they
    if (_hasChanges) {
      _onConfirm();
    } else {
      Navigator.of(context).pop();
    }

    showAddonEditBottomSheet(
      context: widget.parentContext,
      cartItem: serverItem,
      addressId: widget.addressId,
      promoCode: widget.promoCode,
      rushDelivery: widget.rushDelivery,
      useWallet: widget.useWallet,
    );
  }

  /// Finds the server-side [CartItem] whose derived cartKey matches.
  CartItem? _lookupServerCartItem(UserCart row) {
    final state = context.read<GetUserCartBloc>().state;
    List<CartItem> allItems = const [];
    if (state is GetUserCartLoaded) {
      allItems = state.cartData
          .expand((m) => m.data?.items ?? const <CartItem>[])
          .toList();
    } else if (state is GetUserCartUpdating) {
      allItems = state.cartData
          .expand((m) => m.data?.items ?? const <CartItem>[])
          .toList();
    }
    if (allItems.isEmpty) return null;

    for (final item in allItems) {
      if (_cartKeyForServerItem(item) == row.cartKey) return item;
    }
    return null;
  }

  /// Mirrors [UserCart.cartKey] for a server [CartItem].
  String _cartKeyForServerItem(CartItem item) {
    final String productId = (item.product?.id ?? 0).toString();
    final String variantId = (item.productVariantId ?? 0).toString();
    if (item.addons.isEmpty) return '${productId}_$variantId';
    final ids = item.addons
        .map((a) => a.addonItemId ?? 0)
        .where((id) => id > 0)
        .toList()
      ..sort();
    if (ids.isEmpty) return '${productId}_$variantId';
    return '${productId}_${variantId}_${ids.join('-')}';
  }

  // ---- Build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Floating dark close button above the sheet.
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, l10n, theme),
              Flexible(
                child: BlocBuilder<CartBloc, CartState>(
                  builder: (blocContext, state) {
                    final rows = _rowsForProduct(state);
                    // Safe to call inside builder: putIfAbsent is
                    _seedMissing(rows);
                    if (rows.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return _buildCustomisationsCard(
                        context, l10n, theme, rows);
                  },
                ),
              ),
              const SizedBox(height: 10,),
              _buildStickyConfirm(context, l10n, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations? l10n, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet(context) ? 15 : 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            l10n?.yourCustomisations ?? 'Your Customisations',
            style: TextStyle(
              fontSize: isTablet(context) ? 22 : 16.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.tertiary,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomisationsCard(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
    List<UserCart> rows,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: rows.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant,
                  indent: 14.w,
                  endIndent: 14.w,
                ),
                itemBuilder: (_, index) =>
                    _buildCustomisationRow(context, l10n, theme, rows[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomisationRow(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
    UserCart row,
  ) {
    // Per-row unit price includes addon subtotal so the number shown
    final double unitPrice = row.price + row.addonsTotal;
    final String formattedPrice =
        '${AppHelpers.currency}${formatPrice(unitPrice, locale: AppHelpers.defaultLocalCurrency)}';
    final int displayedQty = _displayedQty(row);
    final bool willRemove = displayedQty <= 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.indicator == 'veg' ||
                  widget.indicator == 'non_veg')
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: productIndicator(widget.indicator!),
                ),
              const Spacer(),
              _buildEditButton(context, l10n, theme, row),
            ],
          ),
          const SizedBox(height: 0),
          Text(
            row.variantName.isNotEmpty ? row.variantName : row.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet(context) ? 18 : 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.tertiary,
              fontFamily: AppTheme.fontFamily,
              decoration: willRemove ? TextDecoration.lineThrough : null,
              decorationColor: theme.colorScheme.tertiary
                  .withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formattedPrice,
                style: TextStyle(
                  fontSize: isTablet(context) ? 18 : 15.sp,
                  fontWeight: FontWeight.w700,
                  color: willRemove
                      ? theme.colorScheme.tertiary.withValues(alpha: 0.5)
                      : theme.colorScheme.tertiary,
                  fontFamily: AppTheme.fontFamily,
                  decoration: willRemove ? TextDecoration.lineThrough : null,
                ),
              ),
              const Spacer(),
              _buildRowStepper(context, row, displayedQty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
    UserCart row,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onEditRow(row),
        borderRadius: BorderRadius.circular(4.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.edit ?? 'Edit',
                style: TextStyle(
                  fontSize: isTablet(context) ? 16 : 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: isTablet(context) ? 20 : 16.r,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowStepper(
      BuildContext context, UserCart row, int displayedQty) {
    final bool canDecrement = displayedQty > 0;
    return Container(
      height: isTablet(context) ? 40.h : 38,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperIconButton(
            icon: Icons.remove,
            enabled: canDecrement,
            onTap: () => _onDecrement(row),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: Text(
              displayedQty.toString(),
              style: TextStyle(
                fontSize: isTablet(context) ? 16 : 14.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
          _StepperIconButton(
            icon: Icons.add,
            enabled: true,
            onTap: () => _onIncrement(row),
          ),
        ],
      ),
    );
  }

  /// Sticky Confirm CTA at the bottom of the sheet.
  Widget _buildStickyConfirm(
      BuildContext context, AppLocalizations? l10n, ThemeData theme) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: _hasChanges
          ? Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.3
                            : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: CustomButton(
                  onPressed: _onConfirm,
                  child: Text(
                    l10n?.confirm ?? 'Confirm',
                    style: TextStyle(
                      fontSize: isTablet(context) ? 16 : 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimary,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = enabled
        ? AppTheme.primaryColor
        : AppTheme.primaryColor.withValues(alpha: 0.35);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        child: Icon(
          icon,
          size: isTablet(context) ? 20 : 16.r,
          color: color,
        ),
      ),
    );
  }
}
