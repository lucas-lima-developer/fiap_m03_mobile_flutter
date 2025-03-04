import 'package:fiap_m03_mobile_flutter/components/transaction_card.dart';
import 'package:fiap_m03_mobile_flutter/providers/transaction_provider.dart';
import 'package:fiap_m03_mobile_flutter/types/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  late final _pagingController = PagingController<int, TransactionType>(
    getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
    fetchPage: _loadTransactions,
  );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<TransactionType>> _loadTransactions(int pageKey) async {
    try {
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      await transactionProvider.loadTransactions(limit: 5);

      return transactionProvider.transactions;
    } catch (error) {
      print('Erro ao carregar transações: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) => PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, TransactionType>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) =>
                TransactionCard(transaction: item),
          ),
        ),
      );
}
