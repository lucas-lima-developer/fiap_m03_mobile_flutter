import 'package:fiap_m03_mobile_flutter/components/BarChartComponent.dart';
import 'package:fiap_m03_mobile_flutter/components/PieChartComponent.dart';
import 'package:fiap_m03_mobile_flutter/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: BarChartComponent(
                transactions: transactionProvider.transactions),
          ),
          Flexible(
            child: PieChartComponent(
              transactions: transactionProvider.transactions,
            ),
          ),
        ],
      ),
    );
  }
}
