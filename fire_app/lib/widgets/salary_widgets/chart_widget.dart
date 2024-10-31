import 'package:fire_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalaryChart extends StatelessWidget {
  final List<FlSpot> graphDataAccumulated;
  final List<FlSpot> graphDataAccumulatedAfterTax;
  final List<FlSpot> graphDataInflationAdjusted;

  const SalaryChart({
    super.key,
    required this.graphDataAccumulated,
    required this.graphDataAccumulatedAfterTax,
    required this.graphDataInflationAdjusted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 600,
          width: 690,
          child: LineChart(
            LineChartData(
              titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 60),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 60),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black12),
                  ),
              lineBarsData: [
                LineChartBarData(
                  spots: graphDataAccumulated,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.3),
                  ),
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: graphDataAccumulatedAfterTax,
                  isCurved: true,
                  color: Colors.lime,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.lime.withOpacity(0.3),
                  ),
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: graphDataInflationAdjusted,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.3),
                  ),
                  dotData: const FlDotData(show: false),
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
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LegendEntry(color: Colors.blue, label: 'Salary'),
            SizedBox(width: 16),
            LegendEntry(color: Colors.lime, label: 'After Tax'),
            SizedBox(width: 16),
            LegendEntry(color: Colors.green, label: 'Inflation Adjusted'),
          ],
        ),
      ],
    );
  }
}

class LegendEntry extends StatelessWidget {
  final Color color;
  final String label;

  const LegendEntry({
    super.key, 
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
