import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalaryTab extends StatefulWidget {
  const SalaryTab({Key? key}) : super(key: key);

  @override
  _SalaryTabState createState() => _SalaryTabState();
}

class _SalaryTabState extends State<SalaryTab> {
  final TextEditingController _monthlySalaryController = TextEditingController(text: '40000');
  final TextEditingController _yearlyRaiseController = TextEditingController(text: '2');
  final TextEditingController _taxRateController = TextEditingController(text: '40');
  final TextEditingController _durationController = TextEditingController(text: '40');
  final TextEditingController _inflationRateController = TextEditingController(text: '2');

  final List<Map<String, dynamic>> _salaries = [];

  void _addSalary() {
    final monthlySalary = double.tryParse(_monthlySalaryController.text);
    if (monthlySalary != null) {
      setState(() {
        _salaries.add({'salary': monthlySalary, 'checked': false});
        _monthlySalaryController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid monthly salary')),
      );
    }
  }

  void _toggleSalary(int index) {
    setState(() {
      _salaries[index]['checked'] = !_salaries[index]['checked'];
    });
  }

  void _removeSalary(int index) {
    setState(() {
      _salaries.removeAt(index);
    });
  }

  List<double> _calculateAccumulatedSalaries() {
    double initialYearlySalary = _salaries.fold(0, (acc, salary) => acc + salary['salary'] * 12);
    double raise = double.tryParse(_yearlyRaiseController.text) ?? 0;
    double taxRate = (double.tryParse(_taxRateController.text) ?? 0) / 100;
    double inflationRate = (double.tryParse(_inflationRateController.text) ?? 0) / 100;
    int duration = int.tryParse(_durationController.text) ?? 0;

    List<double> accumulatedAfterTaxAndInflation = [];
    double totalAfterTaxAndInflation = 0;

    for (int year = 0; year <= duration; year++) {
      double annualSalary = initialYearlySalary * pow(1 + raise / 100, year);
      double afterTax = annualSalary * (1 - taxRate);
      double adjustedForInflation = afterTax / pow(1 + inflationRate, year);

      totalAfterTaxAndInflation += adjustedForInflation;
      accumulatedAfterTaxAndInflation.add(totalAfterTaxAndInflation);
    }

    return accumulatedAfterTaxAndInflation;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSalaryInputField(),
          _buildAdditionalInputs(),
          const SizedBox(height: 16),
          _buildSalaryList(),
          const SizedBox(height: 16),
          _buildChart(),
          const SizedBox(height: 16),
          _buildSalariesTable(),
        ],
      ),
    );
  }

  Widget _buildSalaryInputField() {
    return Column(
      children: [
        TextField(
          controller: _monthlySalaryController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monthly Salary'),
        ),
        ElevatedButton(
          onPressed: _addSalary,
          child: const Text('Add Salary'),
        ),
      ],
    );
  }

  Widget _buildAdditionalInputs() {
    return Column(
      children: [
        TextField(
          controller: _yearlyRaiseController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Yearly Pay Raise (%)'),
        ),
        TextField(
          controller: _taxRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
        ),
        TextField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Duration (years)'),
        ),
        TextField(
          controller: _inflationRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Inflation Rate (%)'),
        ),
      ],
    );
  }

  Widget _buildSalaryList() {
    return SizedBox(
      height: 200, // Set a fixed height or adjust as needed
      child: ListView.builder(
        shrinkWrap: true, // Allows the list to take only as much space as it needs
        physics: const NeverScrollableScrollPhysics(), // Prevents inner scrolling
        itemCount: _salaries.length,
        itemBuilder: (context, index) {
          final salary = _salaries[index];
          return ListTile(
            title: Text('Salary ${index + 1}: ${salary['salary']}'),
            leading: Checkbox(
              value: salary['checked'],
              onChanged: (_) => _toggleSalary(index),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeSalary(index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 200, // Sets a fixed height to constrain the LineChart
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _calculateAccumulatedSalaries()
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
            ),
          ],
          titlesData: const FlTitlesData(show: true),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              top: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide(width: 1),
              left: BorderSide(width: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalariesTable() {
    return SizedBox(
      height: 200, // Sets a fixed height to constrain the DataTable
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Year')),
            DataColumn(label: Text('Accumulated After Tax & Inflation')),
          ],
          rows: List<DataRow>.generate(
            (_durationController.text.isNotEmpty ? int.parse(_durationController.text) : 0) + 1,
            (index) => DataRow(
              cells: [
                DataCell(Text('$index')),
                DataCell(Text(_calculateAccumulatedSalaries()[index].toStringAsFixed(2))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
