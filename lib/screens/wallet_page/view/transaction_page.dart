import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aasyou/screens/wallet_page/bloc/wallect_transactions/wallet_transactions_bloc.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_refresh_indicator.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import '../widgets/empty_transaction_widget.dart';
import '../widgets/transaction_card.dart';
import 'package:aasyou/l10n/app_localizations.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
  }
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showViewCart: false,
      title: AppLocalizations.of(context)!.transactions,
      showAppBar: true,
      appBarActions: const [

      ],
      body: BlocBuilder<WalletTransactionsBloc, WalletTransactionsState>(
        builder: (BuildContext context, WalletTransactionsState state) {
          if(state is WalletTransactionsLoaded) {
            if(state.transactions.isEmpty) {
              return EmptyTransactionsState(onRetry: () {
                context.read<WalletTransactionsBloc>().add(
                    FetchWalletTransactions());
              });
            }
            return CustomRefreshIndicator(
              onRefresh: () async {
                context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo){
                  if (scrollInfo is ScrollUpdateNotification &&
                      !state.hasReachedMax &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 50) {
                    context.read<WalletTransactionsBloc>().add(
                      FetchMoreWalletTransactions(),
                    );
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.hasReachedMax ? state.transactions.length : state.transactions.length + 1,
                  itemBuilder: (context, index) {

                    if(index >= state.transactions.length) {
                      return const SizedBox(
                        height: 50,
                        child: CustomCircularProgressIndicator(),
                      );
                    }

                    return TransactionCard(
                      transaction: state.transactions[index],
                    );
                  },
                ),
              ),
            );
          }
          if(state is WalletTransactionsFailure) {
            return EmptyTransactionsState(onRetry: () {
              context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
            },);
          }
          if(state is WalletTransactionsLoading) {
            return const CustomCircularProgressIndicator();
          }
          return EmptyTransactionsState(onRetry: () {
            context.read<WalletTransactionsBloc>().add(FetchWalletTransactions());
          },);
        },
      ),
    );
  }
}