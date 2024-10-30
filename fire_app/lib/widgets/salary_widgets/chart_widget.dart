import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalaryChart extends StatelessWidget {
  final List<double> accumulatedSalaries;

  const SalaryChart({
    super.key,
    required this.accumulatedSalaries,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: accumulatedSalaries
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
