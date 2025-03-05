import 'package:fiap_m03_mobile_flutter/components/filter_component.dart';
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
  final PagingController<int, TransactionType> _pagingController =
      PagingController(firstPageKey: 0);
  Map<String, dynamic> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _loadTransactions(pageKey);
    });
  }

  Future<void> _loadTransactions(int pageKey) async {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    try {
      final newTransactions = await transactionProvider.loadTransactions(
        limit: 10,
        reset: pageKey == 0,
        category: _currentFilters['category'],
        startDate: _currentFilters['startDate'],
        endDate: _currentFilters['endDate'],
      );

      if (newTransactions.isNotEmpty) {
        if (transactionProvider.hasMore) {
          _pagingController.appendPage(newTransactions, pageKey + 1);
        } else {
          _pagingController.appendLastPage(newTransactions);
        }
      } else {
        _pagingController.appendLastPage(newTransactions);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _onFilterApply(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
      _pagingController.refresh();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Transações'),
      ),
      body: Column(
        children: [
          FilterComponent(onFilterApply: _onFilterApply),
          Expanded(
            child: PagedListView<int, TransactionType>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<TransactionType>(
                itemBuilder: (context, item, index) =>
                    TransactionCard(transaction: item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
