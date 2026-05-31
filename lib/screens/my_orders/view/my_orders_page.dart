import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aasyou/config/settings_data_instance.dart';
import 'package:aasyou/config/theme.dart';
import 'package:aasyou/router/app_routes.dart';
import 'package:aasyou/screens/my_orders/bloc/get_my_order/get_my_order_bloc.dart';
import 'package:aasyou/screens/my_orders/bloc/get_my_order/get_my_order_event.dart';
import 'package:aasyou/screens/my_orders/bloc/get_my_order/get_my_order_state.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_refresh_indicator.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';
import '../../../config/helper.dart';
import '../../../l10n/app_localizations.dart';
import '../model/order_filter_model.dart';
import '../widgets/my_order_card.dart';
import '../widgets/order_filter_bottom_sheet.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  OrderFilter _filter = const OrderFilter();
  @override
  void initState() {
    super.initState();
    context.read<GetMyOrderBloc>().add(FetchMyOrder());
  }

  void _openFilterSheet() {
    OrderFilterSheet.show(
      context: context,
      dateOptions: SettingsData.instance.system!.dataFilterEnum!,
      sortOptions: SettingsData.instance.system!.orderStatusEnum!,
      currentFilter: _filter,
      onApply: (newFilter) {
        setState(() => _filter = newFilter);
        // Optionally re-fetch with filters:
        context.read<GetMyOrderBloc>().add(FetchMyOrder(
              dateFilter: _filter.selectedDateFilter,
              statusSort: _filter.selectedStatusSort,
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomScaffold(
      showViewCart: false,
      title: l10n?.myOrders,
      showAppBar: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBarActions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: _openFilterSheet,
              tooltip: 'Filters',
            ),
            if (_filter.hasFilters)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_filter.activeCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
      body: BlocBuilder<GetMyOrderBloc, GetMyOrderState>(
        builder: (context, state) {
          if (state is GetMyOrderLoading) {
            return const Center(
              child: CustomCircularProgressIndicator(),
            );
          } else if (state is GetMyOrderLoaded) {
            log('Total Orders ${state.myOrderData.length}');
            if (state.myOrderData.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.noOrdersYet ?? 'No orders yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return CustomRefreshIndicator(
              onRefresh: () async {
                context.read<GetMyOrderBloc>().add(FetchMyOrder(
                    dateFilter: _filter.selectedDateFilter,
                    statusSort: _filter.selectedStatusSort));
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo is ScrollUpdateNotification &&
                      !state.hasReachedMax &&
                      !state.isLoadingMore &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                    log('Selected Date  ${_filter.selectedDateFilter}');
                    log('Selected Sort  ${_filter.selectedStatusSort}');
                    context.read<GetMyOrderBloc>().add(
                          FetchMoreMyOrder(
                              dateFilter: _filter.selectedDateFilter,
                              statusSort: _filter.selectedStatusSort),
                        );
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.hasReachedMax
                      ? state.myOrderData.length
                      : state.myOrderData.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.myOrderData.length) {
                      return state.isLoadingMore
                          ? const SizedBox(
                              height: 80,
                              child: CustomCircularProgressIndicator(),
                            )
                          : const SizedBox.shrink();
                    }
                    final order = state.myOrderData[index];
                    return GestureDetector(
                      onTap: () {
                        if (order.status == 'delivered') {
                          GoRouter.of(context).push(AppRoutes.orderDetail,
                              extra: {'order-slug': order.slug});
                        } else {
                          GoRouter.of(context).push(AppRoutes.deliveryTracking,
                              extra: {'order-slug': order.slug});
                        }
                      },
                      child: OrderDeliveryCard(
                        status: capitalizeFirstLetter(
                            removeUnderscores(order.status ?? 'Pending')),
                        dateTime: formatDateTime(
                            DateTime.tryParse(order.createdAt.toString())),
                        productImages: _extractProductImages(order),
                        orderId: order.id.toString(),
                        onRateOrder: () {
                          final storeMap = {
                            "orderSlug": order.slug,
                            "orderId": order.id,
                          };

                          GoRouter.of(context).push(
                            AppRoutes.rateYourExp,
                            extra: storeMap,
                          );
                        },
                        onTrackOrder: () {
                          GoRouter.of(context).push(AppRoutes.deliveryTracking,
                              extra: {'order-slug': order.slug});
                        },
                        isDelivered: order.status == 'delivered',
                        isDeliveryBoyAssigned: order.deliveryBoyId != null,
                        orderSlug: order.slug!,
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (state is GetMyOrderFailed) {
            return NoOrderPage(
              onRetry: () {
                context.read<GetMyOrderBloc>().add(FetchMyOrder());
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<String> _extractProductImages(dynamic order) {
    List<String> images = [];

    try {
      if (order.items != null && order.items is List) {
        for (var item in order.items) {
          if (item.product?.image != null) {
            images.add(item.product.image);
          } else {
            images.add('');
          }
        }
      }
    } catch (e) {
      // Return empty list if extraction fails
    }

    return images;
  }
}
