import 'package:fire_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalaryChart extends StatefulWidget {
  final List<FlSpot> graphDataAccumulated;
  final List<FlSpot> graphDataAccumulatedAfterTax;
  final List<FlSpot> graphDataAfterTaxNoRaise;
  final List<FlSpot> graphDataInflationAdjusted;
  final List<FlSpot> graphDataNoRaise;

  const SalaryChart({
    super.key,
    required this.graphDataAccumulated,
    required this.graphDataAccumulatedAfterTax,
    required this.graphDataAfterTaxNoRaise,
    required this.graphDataInflationAdjusted,
    required this.graphDataNoRaise,
  });

    @override
  _SalaryChartState createState() => _SalaryChartState();
}

class _SalaryChartState extends State<SalaryChart> {
  bool _showAfterTaxNoRaise = true;
  bool _showNoRaise = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data on startup
  }

  void saveShowAfterTaxNoRaise(bool bool) async {
    setState(() {
      _showAfterTaxNoRaise = bool;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showAfterTaxNoRaise', bool);
  }

  void saveShowNoRaise(bool bool) async {
    setState(() {
      _showNoRaise = bool;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showNoRaise', bool);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showAfterTaxNoRaise = prefs.getBool('showAfterTaxNoRaise') ?? true;
      _showNoRaise = prefs.getBool('showNoRaise') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 10, // Horizontal spacing between elements
          runSpacing: 5, // Vertical spacing between lines
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _showNoRaise,
                  onChanged: (value) {
                    saveShowNoRaise(value ?? true);
                  },
                ),
                const Text('Show No Raise'),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _showAfterTaxNoRaise,
                  onChanged: (value) {
                    saveShowAfterTaxNoRaise(value ?? true);
                  },
                ),
                const Text('Show Future Value Of Current Salaries'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 600,
          width: 690,
          child: LineChart(
            LineChartData(
              titlesData: _buildTitlesData(),
              gridData: _buildGridData(),
              borderData: _buildBorderData(),
              lineBarsData: _buildLineBarsData(),
              lineTouchData: _buildLineTouchData(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: _buildLegend(),  
        ),      
      ],
    );
  }

  FlTitlesData _buildTitlesData() {
    return const FlTitlesData(
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
    );
  }

  FlGridData _buildGridData() {
    return const FlGridData(show: true, drawVerticalLine: true);
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.black12),
    );
  }

  List<LineChartBarData> _buildLineBarsData() {
    List<LineChartBarData> lineBarsData = [
      _buildLineChartBarData(widget.graphDataAccumulated, Colors.blue),
      _buildLineChartBarData(widget.graphDataAccumulatedAfterTax, Colors.lime),
      _buildLineChartBarData(widget.graphDataInflationAdjusted, Colors.green),
    ];

    if (_showAfterTaxNoRaise && widget.graphDataAfterTaxNoRaise.isNotEmpty) {
      lineBarsData.add(_buildLineChartBarData(widget.graphDataAfterTaxNoRaise, Colors.pink[100]!));
    }
    if (_showNoRaise && widget.graphDataNoRaise.isNotEmpty) {
      lineBarsData.add(_buildLineChartBarData(widget.graphDataNoRaise, Colors.orange[400]!));
    }

    return lineBarsData;
  }

  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.3),
      ),
      dotData: const FlDotData(show: false),
    );
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipRoundedRadius: 8,
        getTooltipItems: (touchedSpots) {
          bool isFirst = true;
          return touchedSpots.map((touchedSpot) {
            final color = touchedSpot.bar.color!;
            final year = touchedSpot.x.toInt();
            final formattedValue = Utils.formatNumber(touchedSpot.y);

            if (isFirst) {
              isFirst = false;
              return LineTooltipItem(
                'Year: $year\n$formattedValue',
                TextStyle(color: color, fontWeight: FontWeight.bold),
              );
            } else {
              return LineTooltipItem(
                formattedValue,
                TextStyle(color: color),
              );
            }
          }).toList();
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 10, // Horizontal spacing between elements
      runSpacing: 5, // Vertical spacing between lines
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LegendEntry(color: Colors.blue, label: 'Salaries Cummulated'),
          ],
        ),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LegendEntry(color: Colors.lime, label: 'After Tax'),
          ],
        ),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LegendEntry(color: Colors.green, label: 'Inflation Adjusted (Actual Value)'),
          ],
        ),
        if (_showNoRaise && widget.graphDataNoRaise.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LegendEntry(color: Colors.orange[400]!, label: 'No Raise'),
            ],
          ),
        if (_showAfterTaxNoRaise && widget.graphDataAfterTaxNoRaise.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LegendEntry(color: Colors.pink[100]!, label: 'Future Value Of Current Salaries'),
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
