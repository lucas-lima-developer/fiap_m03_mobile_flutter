import 'package:fiap_m03_mobile_flutter/components/LineChartComponent.dart';
import 'package:fiap_m03_mobile_flutter/components/PieChartComponent.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: LineChartComponent(),
          ),
          Flexible(
            child: PieChartComponent(),
          ),
        ],
      ),
    );
  }
}
