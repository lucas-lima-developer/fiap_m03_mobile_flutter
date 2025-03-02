import 'package:fiap_m03_mobile_flutter/providers/transaction_provider.dart';
import 'package:fiap_m03_mobile_flutter/screens/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  Widget build(BuildContext context) {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: transactionProvider.transactions.length,
        itemBuilder: (context, index) {
          final sortedTransactions =
              List.from(transactionProvider.transactions);

          sortedTransactions.sort((a, b) {
            return b['date'].seconds.compareTo(a['date'].seconds);
          });

          final transaction = sortedTransactions[index];

          return TransactionCard(transaction: transaction);
        },
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction['amount'] > 0;
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => TransactionScreen(
              transaction: transaction,
            ),
          ),
        )
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Icon(
            isIncome ? Icons.arrow_circle_up : Icons.arrow_circle_down,
            color: isIncome ? Colors.green : Colors.red,
            size: 32,
          ),
          title: Text(
            transaction['description'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(transaction['date'].seconds * 1000))} • ${transaction['category']}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (transaction['attachmentUrl'] != null)
                IconButton(
                  icon: Icon(Icons.download,
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Baixando anexo...')),
                    );
                  },
                ),
              Text(
                currencyFormat.format(transaction['amount']),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
