//



// order_transaction_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_refresh_indicator.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/l10n/app_localizations.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';
import '../../wallet_page/widgets/empty_transaction_widget.dart';
import '../bloc/order_transactions/order_transactions_bloc.dart';
import '../widgets/order_transaction_card.dart';

class OrderTransactionPage extends StatefulWidget {
  const OrderTransactionPage({super.key});

  @override
  State<OrderTransactionPage> createState() => _OrderTransactionPageState();
}

class _OrderTransactionPageState extends State<OrderTransactionPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPaymentStatus;

  final List<String> paymentStatuses = [
    '', // All
    'completed',
    'pending',
    'failed',
  ];

  @override
  void initState() {
    super.initState();
    context.read<OrderTransactionsBloc>().add(FetchOrderTransactions());
  }

  void _applyFilter() {
    context.read<OrderTransactionsBloc>().add(UpdateFilter(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      paymentStatus: _selectedPaymentStatus?.isEmpty == true ? null : _selectedPaymentStatus,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showViewCart: false,
      title: AppLocalizations.of(context)!.transactions,
      showAppBar: true,
      appBarActions: [
        DropdownButton<String>(
          value: _selectedPaymentStatus,
          hint: const Text("Status"),
          underline: const SizedBox.shrink(),
          isDense: true,
          alignment: AlignmentGeometry.topRight,
          iconSize: 20,
          items: paymentStatuses.map((status) {
            return DropdownMenuItem(
              value: status.isEmpty ? null : status,
              child: Text(
                status.isEmpty ? "All" : status.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11
                ),
              ),

            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPaymentStatus = value;
            });
            _applyFilter();
          },
        ),
        const SizedBox(width: 16,)
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: CustomTextFormField(
                    controller: _searchController,
                    hintText: 'Search by order ID, payment ID...',
                    prefixIcon: Icons.search,
                    onFieldSubmitted: (_) => _applyFilter(),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: BlocBuilder<OrderTransactionsBloc, OrderTransactionsState>(
              builder: (context, state) {
                if (state is OrderTransactionsLoading) {
                  return const Center(child: CustomCircularProgressIndicator());
                }

                if (state is OrderTransactionsFailure) {
                  return EmptyTransactionsState(
                    onRetry: () => context.read<OrderTransactionsBloc>().add(
                      FetchOrderTransactions(
                        search: _searchController.text.trim(),
                        paymentStatus: _selectedPaymentStatus,
                      ),
                    ),
                  );
                }

                if (state is OrderTransactionsLoaded) {
                  if (state.transactions.isEmpty) {
                    return EmptyTransactionsState(
                      onRetry: _applyFilter,
                    );
                  }

                  return CustomRefreshIndicator(
                    onRefresh: () async => _applyFilter(),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo is ScrollUpdateNotification &&
                            !state.hasReachedMax &&
                            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                          context.read<OrderTransactionsBloc>().add(FetchMoreOrderTransactions());
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.hasReachedMax
                            ? state.transactions.length
                            : state.transactions.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= state.transactions.length) {
                            return const SizedBox(
                              height: 50,
                              child: Center(child: CustomCircularProgressIndicator()),
                            );
                          }

                          return OrderTransactionCard(
                            transaction: state.transactions[index],
                          );
                        },
                      ),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}