import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _expenseController = TextEditingController(text: '10000');
  final TextEditingController _interestRateController = TextEditingController(text: '7');
  final TextEditingController _inflationRateController = TextEditingController(text: '2');

  String _selectedFrequency = 'One Time';
  final List<String> _frequencies = ['One Time', 'Yearly', 'Monthly'];

  List<Expense> _expenses = [];
  List<Map<String, dynamic>> _tableData = [];
  List<FlSpot> _graphDataTotalValue = [];
  List<FlSpot> _graphDataTotalExpenses = [];

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
                ElevatedButton(
                  onPressed: _calculateTableData,
                  child: const Text('Calculate'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Graph implementation using fl_chart
        Container(
          height: 600,
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
                  belowBarData: BarAreaData(show: true, color:
                    Colors.blue.withOpacity(0.3),),
                ),
                LineChartBarData(
                  spots: _graphDataTotalExpenses,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: true, color:
                    Colors.green.withOpacity(0.3),),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Placeholder for Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Total Expenses')),
              DataColumn(label: Text('Total Value')),
            ],
            rows: _tableData.map((data) {
              return DataRow(
                cells: [
                  DataCell(Text(data['year'].toString())),
                  DataCell(Text(data['totalExpenses'].toString())),
                  DataCell(Text(data['totalValue'].toString())),
                ],
              );
            }).toList(),
          ),
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
  }

  void _calculateTableData() {
    double interestRate = double.tryParse(_interestRateController.text) ?? 0;
    double inflationRate = double.tryParse(_inflationRateController.text) ?? 0;

    List<Map<String, dynamic>> tableData = [];
    List<FlSpot> graphDataTotalValue = [];
    List<FlSpot> graphDataTotalExpenses = [];

    double cumulativeTotalValue = 0;
    double cumulativeTotalExpenses = 0;

    for (int year = 1; year <= 50; year++) {
      double totalExpenses = 0;
      for (Expense expense in _expenses) {
        totalExpenses += expense.getYearlyAmount(year);
      }
      cumulativeTotalExpenses += totalExpenses;

      double totalValue = cumulativeTotalExpenses * (1 + interestRate / 100 - inflationRate / 100);
      cumulativeTotalValue = totalValue;

      tableData.add({
        'year': year,
        'totalExpenses': cumulativeTotalExpenses,
        'totalValue': cumulativeTotalValue,
      });
      graphDataTotalExpenses.add(FlSpot(year.toDouble(), cumulativeTotalExpenses));
      graphDataTotalValue.add(FlSpot(year.toDouble(), cumulativeTotalValue));
    }

    setState(() {
      _tableData = tableData;
      _graphDataTotalExpenses = graphDataTotalExpenses;
      _graphDataTotalValue = graphDataTotalValue;
    });
  }
}

class Expense {
  final double amount;
  final String frequency;

  Expense({required this.amount, required this.frequency});

  double getYearlyAmount(int year) {
    if (frequency == 'One Time') {
      return year == 1 ? amount : 0;
    } else if (frequency == 'Yearly') {
      return amount;
    } else if (frequency == 'Monthly') {
      return amount * 12; // Monthly expense converted to yearly
    }
    return 0;
  }
}
