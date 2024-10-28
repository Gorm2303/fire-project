import 'dart:math';

import 'package:fire_app/models/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _expenseController = TextEditingController(text: '10000');
  final TextEditingController _interestRateController = TextEditingController(text: '7');
  final TextEditingController _inflationRateController = TextEditingController(text: '2');
  final TextEditingController _durationController = TextEditingController(text: '50');
  late final TabController _tableTabController = TabController(length: 1, vsync: this);

  String _selectedFrequency = 'One Time';
  final List<String> _frequencies = ['One Time', 'Yearly', 'Monthly'];

  final List<Expense> _expenses = [];
  List<Map<String, dynamic>> _tableData = [];
  List<FlSpot> _graphDataTotalValue = [];
  List<FlSpot> _graphDataTotalExpenses = [];
  List<FlSpot> _graphDataInflationAdjusted = [];

  @override
  @override
  void dispose() {
    _tableTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = 520;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                TextField(
                  controller: _expenseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Expense',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  items: _frequencies.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFrequency = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: const Text('Add Expense'),
                ),
                const SizedBox(height: 16),
                // List of added expenses with checkboxes
                // Add remove button to each item in the list of expenses.
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${_expenses[index].amount} - ${_expenses[index].frequency}'),
                      leading: Checkbox(
                        value: _expenses[index].isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            _expenses[index].isSelected = value ?? false;
                          });
                          _calculateTableData(); // Recalculate when selection changes
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            _expenses.removeAt(index);
                          });
                          _calculateTableData(); // Recalculate when expense is removed
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _interestRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    _calculateTableData(); // Recalculate when interest rate changes
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _inflationRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Inflation Rate',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    _calculateTableData(); // Recalculate when interest rate changes
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    _calculateTableData(); // Recalculate when interest rate changes
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Graph implementation using fl_chart
        Container(
          height: 600,
          width: 600,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(show: true),
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: _graphDataTotalValue,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                ),
                LineChartBarData(
                  spots: _graphDataTotalExpenses,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.3)),
                ),
                LineChartBarData(
                  spots: _graphDataInflationAdjusted,  // Adding inflation-adjusted values to the graph
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.3)),
                ),
              ],
              // Tooltip settings to show formatted values
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      final formattedValue = formatNumber(touchedSpot.y); // Format with commas and no decimals
                      final lineColor = touchedSpot.bar.color; // Get the color of the line

                      return LineTooltipItem(
                        '$formattedValue',
                        TextStyle(color: lineColor, fontWeight: FontWeight.bold), // Use the line color
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        Column(
          children: [
            TabBar(
              controller: _tableTabController,
              tabs: const [
                Tab(text: 'Expenses Yearly'),
              ],
            ),
            SizedBox(
              height: 475,
              child: TabBarView(
                controller: _tableTabController,
                children: [ SingleChildScrollView(
                  child:
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Year')),
                        DataColumn(label: Text('Total Expenses')),
                        DataColumn(label: Text('Interest (Yearly)')),
                        DataColumn(label: Text('Interest (Total)')),
                        DataColumn(label: Text('Total Value')),
                        DataColumn(label: Text('Inflation Adjusted')),
                      ],
                      rows: _tableData.map((data) {
                        return DataRow(cells: [
                          DataCell(Text(data['year'].toString())),
                          DataCell(Text(data['Total Expenses'])),
                          DataCell(Text(data['Interest (Yearly)'])),
                          DataCell(Text(data['Interest (Total)'])),
                          DataCell(Text(data['Total Value'])),
                          DataCell(Text(data['Inflation Adjusted'])),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addExpense() {
    double expenseAmount = double.tryParse(_expenseController.text) ?? 0;
    Expense newExpense = Expense(
      amount: expenseAmount,
      frequency: _selectedFrequency,
    );
    
    setState(() {
      _expenses.add(newExpense);
    });

    // Dynamically recalculate the table and graph when an item is added
    _calculateTableData();
  }


  // Update _calculateTableData to compute compound interest annually and the total.
  void _calculateTableData() {
    double interestRate = double.tryParse(_interestRateController.text) ?? 0;
    double inflationRate = double.tryParse(_inflationRateController.text) ?? 0;
    int duration =  _durationController.text.isNotEmpty ? int.parse(_durationController.text) : 50;

    List<Map<String, dynamic>> tableData = [];
    List<FlSpot> graphDataTotalValue = [];
    List<FlSpot> graphDataTotalExpenses = [];
    List<FlSpot> graphDataInflationAdjusted = [];

    double cumulativeTotalValue = 0.0;
    double cumulativeTotalExpenses = 0.0;
    double cumulativeTotalInterest = 0.0;

    // Calculate total expenses for Year 0 (no interest yet, total value = total expenses)
    double year0Expenses = 0;
    for (Expense expense in _expenses) {
      if (expense.isSelected) {
        year0Expenses += expense.getYearlyAmount(1);  // Expenses for the first year (used in Year 0)
      }
    }

    // Year 0 data: no interest, total value equals total expenses
    tableData.add({
      'year': 0,
      'Total Expenses': year0Expenses,
      'Interest (Yearly)': 0.0,
      'Interest (Total)': 0.0,
      'Total Value': year0Expenses,
      'Inflation Adjusted': year0Expenses, // No inflation adjustment yet
    });

    // Add data points for Year 0 in the graph
    graphDataTotalExpenses.add(FlSpot(0, year0Expenses));
    graphDataTotalValue.add(FlSpot(0, year0Expenses));
    graphDataInflationAdjusted.add(FlSpot(0, year0Expenses));

    cumulativeTotalExpenses += year0Expenses;
    cumulativeTotalValue += year0Expenses;

    // Loop for years 1 to 50, adding interest and inflation adjustments
    for (int year = 1; year <= duration; year++) {
      double totalExpenses = 0;
      double yearlyInterest = 0;

      // Create a map to store expense values for each year
      Map<String, dynamic> yearData = {
        'year': year,
        'Total Expenses': 0.0,
        'Interest (Yearly)': 0.0,
        'Interest (Total)': 0.0,
        'Total Value': 0.0,
        'Inflation Adjusted': 0.0
      };

      // Calculate total expenses for the year, skipping Year 1 if it's already accounted in Year 0
      for (Expense expense in _expenses) {
        if (expense.isSelected) {
          double yearlyAmount = expense.getYearlyAmount(year == 1 ? 2 : year);  // Start from year 2 to avoid duplicate for year 1
          totalExpenses += yearlyAmount;
        }
      }

      // Calculate interest for the year
      yearlyInterest = cumulativeTotalValue * (interestRate / 100);
      cumulativeTotalInterest += yearlyInterest;

      // Update the cumulative totals
      cumulativeTotalExpenses += totalExpenses;
      cumulativeTotalValue += totalExpenses + yearlyInterest;

      // Calculate inflation-adjusted value
      double inflationAdjustedValue = cumulativeTotalValue / pow(1 + (inflationRate / 100), year);

      // Add the calculated values to the yearData
      yearData['Total Expenses'] = cumulativeTotalExpenses;
      yearData['Interest (Yearly)'] = yearlyInterest;
      yearData['Interest (Total)'] = cumulativeTotalInterest;
      yearData['Total Value'] = cumulativeTotalValue;
      yearData['Inflation Adjusted'] = inflationAdjustedValue;

      tableData.add(yearData);

      // Add data points for the graph
      graphDataTotalExpenses.add(FlSpot(year.toDouble(), cumulativeTotalExpenses.roundToDouble()));
      graphDataTotalValue.add(FlSpot(year.toDouble(), cumulativeTotalValue.roundToDouble()));
      graphDataInflationAdjusted.add(FlSpot(year.toDouble(), inflationAdjustedValue.roundToDouble()));
    }

    // Update the table data with formatted numbers
    tableData = tableData.map((data) {
      return {
        'year': data['year'],
        'Total Expenses': formatNumber(data['Total Expenses']),
        'Interest (Yearly)': formatNumber(data['Interest (Yearly)']),
        'Interest (Total)': formatNumber(data['Interest (Total)']),
        'Total Value': formatNumber(data['Total Value']),
        'Inflation Adjusted': formatNumber(data['Inflation Adjusted']),
      };
    }).toList();
    setState(() {
      _tableData = tableData;
      _graphDataTotalExpenses = graphDataTotalExpenses;
      _graphDataTotalValue = graphDataTotalValue;
      _graphDataInflationAdjusted = graphDataInflationAdjusted;  // Added the inflation-adjusted data series
    });
  }

  // Format numbers with thousand separators
  String formatNumber(dynamic number) {
    // Ensure number is a double or return '0' if null or non-numeric
    if (number == null) return '0';
    if (number is String) number = double.tryParse(number) ?? 0.0;
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match match) => ',');
  }
}