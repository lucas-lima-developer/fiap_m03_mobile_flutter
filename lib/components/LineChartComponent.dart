import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartComponent extends StatefulWidget {
  @override
  _LineChartComponentState createState() => _LineChartComponentState();
}

class _LineChartComponentState extends State<LineChartComponent> {
  final _monthLabels = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Evolução Patrimonial",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: Container(
          height: 320,
          padding: EdgeInsets.all(8),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(value.toString(),
                                style: Theme.of(context).textTheme.bodySmall);
                          })),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 100,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _monthLabels[value.toInt() - 1],
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false))),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black12, width: 0.5),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                  aboveBarData: BarAreaData(show: false),
                  belowBarData: BarAreaData(
                      show: true, color: Colors.blue.withOpacity(0.2)),
                  spots: [
                    FlSpot(1, 1),
                    FlSpot(2, 2.5),
                    FlSpot(3, 1.8),
                    FlSpot(4, 3.4),
                    FlSpot(5, 2),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

void main() {
  runApp(MaterialApp(
    home: LineChartComponent(),
  ));
}
