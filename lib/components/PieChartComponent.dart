import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartComponent extends StatefulWidget {
  @override
  PieChartComponentState createState() => PieChartComponentState();
}

class PieChartComponentState extends State<PieChartComponent> {
  List<PieChartSectionData> pieChartSections = [
    PieChartSectionData(
      color: Colors.blue,
      value: 40,
      title: '40%',
      radius: 50,
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      color: Colors.red,
      value: 30,
      title: '30%',
      radius: 50,
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      color: Colors.green,
      value: 20,
      title: '20%',
      radius: 50,
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    PieChartSectionData(
      color: Colors.yellow,
      value: 10,
      title: '10%',
      radius: 50,
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  ];

  void updateChart() {
    setState(() {
      pieChartSections = [
        PieChartSectionData(
          color: Colors.blue,
          value: 50,
          title: '50%',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.red,
          value: 20,
          title: '20%',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.green,
          value: 20,
          title: '20%',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.yellow,
          value: 10,
          title: '10%',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Movimentações bancárias",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Container(
        height: 300,
        child: Center(
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: pieChartSections,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PieChartComponent(),
  ));
}
