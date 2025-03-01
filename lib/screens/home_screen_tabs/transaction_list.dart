import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'Receita',
      'date': DateTime.now(),
      'description': 'Pagamento de Cliente',
      'value': 1500.00,
      'hasAttachment': true,
    },
    {
      'type': 'Despesa',
      'date': DateTime.now().subtract(Duration(days: 2)),
      'description': 'Compra de Material',
      'value': -250.75,
      'hasAttachment': false,
    },
    {
      'type': 'Receita',
      'date': DateTime.now().subtract(Duration(days: 5)),
      'description': 'Venda de Produto',
      'value': 780.50,
      'hasAttachment': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
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
    final bool isIncome = transaction['value'] > 0;
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
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
          '${DateFormat('dd/MM/yyyy').format(transaction['date'])} • ${transaction['type']}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (transaction['hasAttachment'])
              IconButton(
                icon:
                    Icon(Icons.download, color: Theme.of(context).primaryColor),
                onPressed: () {
                  // Ação de download do anexo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Baixando anexo...')),
                  );
                },
              ),
            Text(
              currencyFormat.format(transaction['value']),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
