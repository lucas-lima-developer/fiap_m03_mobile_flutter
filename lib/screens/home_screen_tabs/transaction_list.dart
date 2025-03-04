import 'package:fiap_m03_mobile_flutter/components/filter_component.dart';
import 'package:fiap_m03_mobile_flutter/components/transaction_card.dart';
import 'package:fiap_m03_mobile_flutter/types/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiap_m03_mobile_flutter/providers/transaction_provider.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final ScrollController _scrollController = ScrollController();

  String? _categoriaSelecionada;
  DateTimeRange? _dataRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions(context);
    });
  }

  void _loadTransactions(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      await transactionProvider.loadTransactions();
    });
  }

  void _aplicarFiltro(Map<String, dynamic> filtro) {
    final category = filtro['category'] as String?;
    final startDate = filtro['startDate'] as DateTime?;
    final endDate = filtro['endDate'] as DateTime?;
    final reset = filtro['reset'] as bool;

    setState(() {
      _categoriaSelecionada = category;
      _dataRange = filtro['dataRange'] as DateTimeRange?;
    });

    Provider.of<TransactionProvider>(context, listen: false).loadTransactions(
      limit: 5,
      category: category,
      startDate: startDate,
      endDate: endDate,
      reset: reset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Transações"),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilterComponent(
                  onFilterApply: (filtro) {
                    _aplicarFiltro(filtro);
                  },
                ),
              ),
              transactionProvider.transactions.isEmpty
                  ? Text('Não há transações.')
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: transactionProvider.transactions.length + 1,
                        itemBuilder: (context, index) {
                          if (index ==
                              transactionProvider.transactions.length) {
                            return transactionProvider.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : const SizedBox.shrink();
                          }

                          final transaction =
                              transactionProvider.transactions[index];

                          return TransactionCard(transaction: transaction);
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
