import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartComponent extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const BarChartComponent({Key? key, required this.transactions})
      : super(key: key);

  @override
  _BarChartComponentState createState() => _BarChartComponentState();
}

class _BarChartComponentState extends State<BarChartComponent> {
  late Map<int, Map<String, double>> groupedData;

  @override
  void initState() {
    super.initState();
    groupedData = _groupTransactionsByMonth(widget.transactions);
  }

  @override
  Widget build(BuildContext context) {
    final monthLabels = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Entrada/Saída",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Container(
        height: 320,
        padding: EdgeInsets.all(8),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.center,
            maxY: groupedData.values.fold(
                0.0,
                (prev, element) => (element["in"] ?? 0) > (prev ?? 0)
                    ? (element["in"] ?? 0)
                    : prev),
            minY: groupedData.values.fold(
                0.0,
                (prev, element) => (element["out"] ?? 0) < (prev ?? 0)
                    ? (element["out"] ?? 0)
                    : prev),
            groupsSpace: 12,
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 100,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      monthLabels[value.toInt() - 1],
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      getTitlesWidget: (value, meta) {
                        return Text("R\$ ${value.toInt().toString()}",
                            style: Theme.of(context).textTheme.bodySmall);
                      })),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            barGroups: groupedData.entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value["in"] ?? 0.0,
                    color: Colors.green,
                    width: 16,
                  ),
                  BarChartRodData(
                    toY: entry.value["out"] ?? 0.0,
                    color: Colors.red,
                    width: 16,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Map<int, Map<String, double>> _groupTransactionsByMonth(
      List<Map<String, dynamic>> transactions) {
    final Map<int, Map<String, double>> groupedData = {};

    for (var transaction in transactions) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
        transaction['date'].seconds * 1000,
      );
      final int month = date.month;
      final double amount = transaction['amount'] as double;
      final bool isIncome = amount > 0;

      groupedData.putIfAbsent(month, () => {"in": 0.0, "out": 0.0});
      if (isIncome) {
        groupedData[month]!['in'] = (groupedData[month]!['in'] ?? 0) + amount;
      } else {
        groupedData[month]!['out'] = (groupedData[month]!['out'] ?? 0) + amount;
      }
    }

    final sortedGroupedData = Map.fromEntries(
      groupedData.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );

    return sortedGroupedData;
  }

}
