import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/cart_page/widgets/bill_summary_widget.dart';
import 'package:aasyou/screens/my_orders/bloc/download_invoice/download_invoice_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/get_my_order/get_my_order_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/get_my_order/get_my_order_event.dart';
import 'package:aasyou/screens/my_orders/bloc/re_order/re_order_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/return_order_item/return_order_item_bloc.dart';
import 'package:aasyou/screens/my_orders/model/order_detail_model.dart';
import 'package:aasyou/screens/my_orders/model/order_status.dart';
import 'package:aasyou/screens/my_orders/widgets/order_action_bar.dart';
import 'package:aasyou/screens/my_orders/widgets/order_address_card.dart';
import 'package:aasyou/screens/my_orders/widgets/order_below_hero_section.dart';
import 'package:aasyou/screens/my_orders/widgets/order_cancel_tile.dart';
import 'package:aasyou/screens/my_orders/widgets/order_help_link.dart';
import 'package:aasyou/screens/my_orders/widgets/order_items_preview_card.dart';
import 'package:aasyou/screens/my_orders/widgets/order_meta_card.dart';
import 'package:aasyou/screens/my_orders/widgets/order_status_hero_card.dart';
import 'package:aasyou/screens/my_orders/widgets/return_dialog.dart';
import 'package:aasyou/screens/product_detail_page/bloc/product_feedback/product_feedback_bloc.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_refresh_indicator.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/custom_toast.dart';
import 'package:aasyou/utils/widgets/whole_page_progress.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/widgets/dialog_box_animation.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/order_detail/order_detail_bloc.dart';
import '../widgets/order_note_display_widget.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderSlug;
  const OrderDetailPage({super.key, required this.orderSlug});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    if (!mounted) return;
    context
        .read<OrderDetailBloc>()
        .add(FetchOrderDetail(orderSlug: widget.orderSlug));
  }

  Future<void> _onRated() async {
    if (!mounted) return;
    context.read<ProductFeedbackBloc>().add(ResetProductFeedback());
    await _fetchOrder();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ToastManager.show(
      context: context,
      message: l10n?.orderDetailsRefreshed ?? 'Order details refreshed',
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _launchInvoice(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      log('Cannot launch URL: $uri');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showReturnDialog(OrderDetailData order) {
    openSlideUpDialog(
      context,
      ReturnItemsDialog(
        items: order.items,
        orderSlug: order.slug ?? widget.orderSlug,
        isDelivered: order.status == 'delivered',
        orderStatus: order.status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ReturnOrderItemBloc, ReturnOrderItemState>(
          listener: _onReturnState,
        ),
        BlocListener<ReOrderBloc, ReOrderState>(listener: _onReOrderState),
      ],
      child: Stack(
        children: [
          BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              return CustomScaffold(
                showViewCart: false,
                title: AppLocalizations.of(context)?.orderSummary ??
                    'Order Summary',
                showAppBar: true,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainer,
                body: CustomRefreshIndicator(
                  onRefresh: _fetchOrder,
                  child: _buildBody(context, state),
                ),
                bottomNavigationBar: _buildBottomBar(state),
              );
            },
          ),
          BlocSelector<DownloadInvoiceBloc, DownloadInvoiceState, bool>(
            selector: (s) => s is DownloadInvoiceLoading,
            builder: (context, downloading) {
              return BlocSelector<ReOrderBloc, ReOrderState, bool>(
                selector: (s) => s is ReOrderInProgress,
                builder: (context, reOrdering) {
                  final showOverlay = downloading || reOrdering;
                  return AnimatedOpacity(
                    opacity: showOverlay ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: showOverlay
                        ? const WholePageProgress()
                        : const SizedBox.shrink(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderDetailState state) {
    if (state is OrderDetailLoading || state is OrderDetailInitial) {
      return const CustomCircularProgressIndicator();
    }
    if (state is OrderDetailFailed) {
      return _ErrorView(message: state.error, onRetry: _fetchOrder);
    }
    if (state is! OrderDetailLoaded) return const SizedBox.shrink();
    final order = state.cartData.first.data;
    if (order == null) {
      return _ErrorView(
        message: AppLocalizations.of(context)?.errorLoadingOrder ??
            "Couldn't load order details",
        onRetry: _fetchOrder,
      );
    }
    final status = OrderStatusX.fromString(order.status);
    return _LoadedBody(
      order: order,
      status: status,
      onRated: _onRated,
      onReturnTap: () => _showReturnDialog(order),
      onDownloadInvoice: () => _launchInvoice(order.invoice),
    );
  }

  Widget? _buildBottomBar(OrderDetailState state) {
    if (state is! OrderDetailLoaded) return null;
    final order = state.cartData.first.data;
    if (order == null) return null;
    final status = OrderStatusX.fromString(order.status);
    return OrderActionBar(
      order: order,
      status: status,
      onReturnTap: () => _showReturnDialog(order),
    );
  }

  void _onReturnState(BuildContext context, ReturnOrderItemState state) {
    if (state is ReturnOrderItemSuccess) {
      ToastManager.show(context: context, message: state.message);
      _fetchOrder();
      context.read<GetMyOrderBloc>().add(RefreshMyOrders());
    } else if (state is ReturnOrderItemFailed) {
      ToastManager.show(
        context: context,
        message: state.error,
        type: ToastType.error,
      );
    }
  }

  void _onReOrderState(BuildContext context, ReOrderState state) {
    if (state is ReOrderedSuccess) {
      context.go(AppRoutes.home);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push(AppRoutes.cart);
      });
    } else if (state is ReOrderedFailed) {
      ToastManager.show(
        context: context,
        message: state.errorList.join('\n\n'),
        type: ToastType.error,
        duration: const Duration(seconds: 5),
      );
    }
  }
}

class _LoadedBody extends StatelessWidget {
  final OrderDetailData order;
  final OrderStatus status;
  final Future<void> Function() onRated;
  final VoidCallback onReturnTap;
  final VoidCallback onDownloadInvoice;

  const _LoadedBody({
    required this.order,
    required this.status,
    required this.onRated,
    required this.onReturnTap,
    required this.onDownloadInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final children = <Widget>[
      OrderStatusHeroCard(order: order, status: status),
      OrderBelowHeroSection(
        order: order,
        status: status,
        onRated: onRated,
        avgRating: avgRatingCalculation(),
      ),
      SizedBox(height: 10.h),
      OrderItemsPreviewCard(
        items: order.items,
        subtotal: order.subtotal,
      ),
      if (status.allowsCancel) ...[
        SizedBox(height: 10.h),
        OrderCancelTile(
          status: status,
          onCancelTap: onReturnTap,
        ),
      ],
      SizedBox(height: 10.h),
      OrderAddressCard(
        label: status == OrderStatus.delivered
            ? (l10n?.deliveredTo ?? 'Delivered to')
            : (l10n?.deliveryAddress ?? 'Delivery address'),
        address: order.shippingAddress1 ?? '',
        addressType: order.shippingAddressType,
      ),
      if ((order.orderNote ?? '').trim().isNotEmpty) ...[
        SizedBox(height: 10.h),
        OrderNoteDisplayWidget(orderNote: order.orderNote ?? ''),
      ],
      SizedBox(height: 10.h),
      _BillSummaryGuard(
        order: order,
        onDownloadInvoice: onDownloadInvoice,
      ),
      SizedBox(height: 10.h),
      OrderMetaCard(
        orderId: order.id?.toString() ?? '',
        paymentMethod: order.paymentMethod ?? '',
        createdAt: order.createdAt,
        invoiceUrl: order.invoice,
        onDownloadInvoice: onDownloadInvoice,
      ),
      SizedBox(height: 8.h),
      const OrderHelpLink(),
      SizedBox(height: 12.h),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Column(children: children),
    );
  }

  double avgRatingCalculation() {
    final ratings = order.items
        .map((data) => data.userReview?.rating?.toDouble() ?? 0.0)
        .toList();

    if (ratings.isEmpty) return 0.0;

    final total = ratings.reduce((a, b) => a + b);
    return total / ratings.length;
  }
}

class _BillSummaryGuard extends StatelessWidget {
  final OrderDetailData order;
  final VoidCallback onDownloadInvoice;

  const _BillSummaryGuard({
    required this.order,
    required this.onDownloadInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final totalPayable = double.tryParse(order.totalPayable ?? '');
    final subtotal = double.tryParse(order.subtotal ?? '');
    final deliveryCharge = double.tryParse(order.deliveryCharge ?? '');
    final handling = double.tryParse(order.handlingCharges ?? '');
    final perStore = double.tryParse(order.perStoreDropOffFee ?? '');
    final finalTotal = double.tryParse(order.finalTotal ?? '');
    final promoDiscount = double.tryParse(order.promoDiscount ?? '0.0') ?? 0.0;

    if (totalPayable == null ||
        subtotal == null ||
        deliveryCharge == null ||
        handling == null ||
        perStore == null ||
        finalTotal == null) {
      return const SizedBox.shrink();
    }

    return BillSummaryWidget(
      itemsOriginalPrice: totalPayable,
      itemsDiscountedPrice: subtotal,
      itemsSavings: 0,
      deliveryChargeOriginal: deliveryCharge,
      handlingCharge: handling,
      perStoreDropOffFees: perStore,
      grandTotal: finalTotal,
      totalSavings: 0,
      isFromOrderDetail: true,
      downloadInvoice: onDownloadInvoice,
      promoCode: order.promoCode,
      promoDiscount: promoDiscount,
      totalPayable: totalPayable,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 36.sp, color: scheme.onSurfaceVariant),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(l10n?.retryLabel ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
