import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _principalController = TextEditingController(text: '1000');
  final TextEditingController _rateController = TextEditingController(text: '7');
  final TextEditingController _timeController = TextEditingController(text: '25');
  final TextEditingController _compoundController = TextEditingController(text: '1');
  final TextEditingController _additionalAmountController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _calculateYearlyValues();  // Calculate table when the page is loaded
  }

  String _contributionFrequency = 'Monthly'; // Default contribution frequency

  List<Map<String, double>> _yearlyValues = [];

  // Function to build the dynamic formula text
  Widget _buildFormulaWidget() {
    double principal = double.tryParse(_principalController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double time = double.tryParse(_timeController.text) ?? 0;
    int compoundingFrequency = int.tryParse(_compoundController.text) ?? 1;
    double additionalAmount = double.tryParse(_additionalAmountController.text) ?? 0;

    String fullFormula = '';

    // Step 1: Add principal part if principal > 0
    if (principal > 0) {
      String principalPart = "${principal.toStringAsFixed(2)}";
      String ratePart = "\\frac{${(rate / 100).toStringAsFixed(4)}}{$compoundingFrequency}";
      String exponentPart = "^{$compoundingFrequency \\times $time}";
      String mainFormula = "$principalPart \\times (1 + $ratePart)$exponentPart";
      fullFormula += "A = $mainFormula";
    }

    // Step 2: Add contribution part if additionalAmount > 0
    if (additionalAmount > 0) {
      String contributionText = _contributionFrequency == 'Monthly'
          ? "12 \\times ${additionalAmount.toStringAsFixed(2)}"
          : "${additionalAmount.toStringAsFixed(2)}";
      String ratePart = "\\frac{${(rate / 100).toStringAsFixed(4)}}{$compoundingFrequency}";
      String exponentPart = "^{$compoundingFrequency \\times $time}";
      String contributionFormula = "$contributionText \\times \\frac{\\left( (1 + $ratePart)$exponentPart - 1 \\right)}{$ratePart}";
      if (fullFormula.isNotEmpty) {
        fullFormula += " + ";
      } else {
        fullFormula = "A = ";
      }
      fullFormula += contributionFormula;
    }

    // If both are zero, show nothing
    if (fullFormula.isEmpty) {
      fullFormula = "A = 0";
    }

    // Render the full formula using Math.tex
    return Math.tex(
      fullFormula,
      textStyle: TextStyle(fontSize: 16),
    );
  }

  // Function to calculate the yearly breakdown
  void _calculateYearlyValues() {
    double principal = double.tryParse(_principalController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double time = double.tryParse(_timeController.text) ?? 0;
    int compoundingFrequency = int.tryParse(_compoundController.text) ?? 1;
    double additionalAmount = double.tryParse(_additionalAmountController.text) ?? 0;

    List<Map<String, double>> yearlyValues = [];
    double totalAmount = principal;
    double totalDeposits = principal;

    // Determine if contributions are monthly or yearly
    int contributionFrequency = _contributionFrequency == 'Monthly' ? 12 : 1;

    for (int year = 1; year <= time; year++) {
      totalAmount = totalAmount * pow((1 + (rate / 100) / compoundingFrequency), compoundingFrequency);
      totalDeposits += additionalAmount * contributionFrequency;
      totalAmount += additionalAmount * contributionFrequency;

      // Store the breakdown for the current year
      yearlyValues.add({
        'year': year.toDouble(),
        'totalValue': totalAmount,
        'totalDeposits': totalDeposits,
        'compoundEarnings': totalAmount - totalDeposits,
      });
    }

    setState(() {
      _yearlyValues = yearlyValues;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Compound Interest Calculator')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Input fields that update the formula on change
            TextField(
              controller: _principalController,
              decoration: InputDecoration(labelText: 'Principal Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
                _calculateYearlyValues(); // Recalculate the table on input change
              },
            ),
            TextField(
              controller: _rateController,
              decoration: InputDecoration(labelText: 'Rate of Interest (%)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
                _calculateYearlyValues(); // Recalculate the table on input change
              },
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Time (Years)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
                _calculateYearlyValues(); // Recalculate the table on input change
              },
            ),
            TextField(
              controller: _compoundController,
              decoration: InputDecoration(labelText: 'Compounding Frequency (Times/Year)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
                _calculateYearlyValues(); // Recalculate the table on input change
              },
            ),
            TextField(
              controller: _additionalAmountController,
              decoration: InputDecoration(labelText: 'Additional Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
                _calculateYearlyValues(); // Recalculate the table on input change
              },
            ),
            // Dropdown to select the contribution frequency
            DropdownButton<String>(
              value: _contributionFrequency,
              items: <String>['Monthly', 'Yearly'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _contributionFrequency = newValue!;
                });
                _calculateYearlyValues(); // Recalculate the table on dropdown change
              },
            ),
            SizedBox(height: 20),
            // Dynamically display the formula
            _buildFormulaWidget(),
            SizedBox(height: 20),
            // Displaying the table of yearly investments with breakdown
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Year')),
                      DataColumn(label: Text('Total Value (kr)')),
                      DataColumn(label: Text('Total Deposits (kr)')),
                      DataColumn(label: Text('Compound Earnings (kr)')),
                    ],
                    rows: _yearlyValues.map((value) {
                      return DataRow(cells: [
                        DataCell(Text(value['year']!.toInt().toString())),
                        DataCell(Text(value['totalValue']!.toStringAsFixed(2))),
                        DataCell(Text(value['totalDeposits']!.toStringAsFixed(2))),
                        DataCell(Text(value['compoundEarnings']!.toStringAsFixed(2))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
