import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PieChartComponent extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const PieChartComponent({super.key, required this.transactions});

  @override
  State<StatefulWidget> createState() => PieChartComponentState();
}

class PieChartComponentState extends State<PieChartComponent> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Despesas por categoria",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildIndicators(),
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 1,
                  centerSpaceRadius: 0,
                  sections: showingSections(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIndicators() {
    final categories = _groupByCategory();
    return categories.entries.map((entry) {
      return Indicator(
        color: _getColor(entry.key),
        text: entry.key,
        isSquare: false,
        size: touchedIndex == entry.key.hashCode ? 18 : 16,
        textColor:
            touchedIndex == entry.key.hashCode ? Colors.black : Colors.grey,
      );
    }).toList();
  }

  Map<String, double> _groupByCategory() {
    final categoryMap = <String, double>{};
    for (var transaction in widget.transactions) {
      final category = transaction['category'];
      final amount = transaction['amount'] as double;
      final isExpense = amount < 0;

      if (isExpense) {
        if (categoryMap.containsKey(category)) {
          categoryMap[category] = categoryMap[category]! + amount;
        } else {
          categoryMap[category] = amount;
        }
      }
    }

    final sortedCategoryMap = Map.fromEntries(
      categoryMap.entries.toList()
        ..sort((e1, e2) => e2.value.compareTo(e1.value)),
    );
    return sortedCategoryMap;
  }

  List<PieChartSectionData> showingSections() {
    final categoryMap = _groupByCategory();
    double totalAmount =
        categoryMap.values.fold(0, (prev, amount) => prev + amount);

    return categoryMap.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalAmount) * 100;

      final isTouched = category.hashCode == touchedIndex;

      return PieChartSectionData(
        color: _getColor(category),
        value: percentage,
        showTitle: true,
        title: _formatCurrency(amount),
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        radius: 80,
        titlePositionPercentageOffset: 0.55,
        borderSide: isTouched
            ? BorderSide(color: Colors.white, width: 6)
            : BorderSide(color: Colors.white.withOpacity(0)),
      );
    }).toList();
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 0);
    return format.format(amount.abs()); // Usa o formato "R$ ###,##"
  }

  Color _getColor(String category) {
    // Gerar um valor único para cada categoria usando seu índice
    final index = category.hashCode;

    // Gerar cores distintas com base no índice
    double hue = (index % 360).toDouble(); // Garante um valor entre 0 e 360
    HSVColor hsvColor =
        HSVColor.fromAHSV(1.0, hue, 0.7, 0.8); // Saturação e valor ajustados
    return hsvColor.toColor();
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    required this.size,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(color: textColor),
        )
      ],
    );
  }
}
