import 'package:fire_app/services/utils.dart';
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
      height: 600,
      width: 690,
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
          lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    bool isFirst = true; // Track if it’s the first item to display the year
                    return touchedSpots.map((touchedSpot) {
                      final color = touchedSpot.bar.color!;
                      final year = touchedSpot.x.toInt(); // Convert x to an integer year
                      final formattedValue = Utils.formatNumber(touchedSpot.y);

                      if (isFirst) {
                        isFirst = false; // Set isFirst to false after displaying year once
                        
                        // Display the year and value as separate lines in a single item
                        return LineTooltipItem(
                          'Year: $year\n$formattedValue',
                          TextStyle(color: color, fontWeight: FontWeight.bold), // Use bold only for the first item
                        );
                      } else {
                        // Display only the value for subsequent items with the default color
                        return LineTooltipItem(
                          formattedValue,
                          TextStyle(color: color),
                        );
                      }
                    }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
