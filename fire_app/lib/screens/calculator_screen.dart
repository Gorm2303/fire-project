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
  final TextEditingController _withdrawalPercentageController = TextEditingController(text: '4');  // Default 4%

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
      String principalPart = "${principal.toStringAsFixed(0)}";
      String ratePart = "\\frac{${(rate / 100).toStringAsFixed(3)}}{$compoundingFrequency}";
      String exponentPart = "^{$compoundingFrequency \\times $time}";
      String mainFormula = "$principalPart \\times (1 + $ratePart)$exponentPart";
      fullFormula += "A = $mainFormula";
    }

    // Step 2: Add contribution part if additionalAmount > 0
    if (additionalAmount > 0) {
      String contributionText = _contributionFrequency == 'Monthly'
          ? "12 \\times ${additionalAmount.toStringAsFixed(0)}"
          : "${additionalAmount.toStringAsFixed(0)}";
      String ratePart = "\\frac{${(rate / 100).toStringAsFixed(3)}}{$compoundingFrequency}";
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

  double _customWithdrawalRule = 0;  // Store the custom withdrawal amount
  double _customWithdrawalTax = 0;  // Store the calculated tax

  /// Function to calculate the yearly breakdown and custom withdrawal rule
  void _calculateYearlyValues() {
    double principal = double.tryParse(_principalController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double time = double.tryParse(_timeController.text) ?? 0;
    int compoundingFrequency = int.tryParse(_compoundController.text) ?? 1;
    double additionalAmount = double.tryParse(_additionalAmountController.text) ?? 0;
    double withdrawalPercentage = double.tryParse(_withdrawalPercentageController.text) ?? 4;  // Get custom percentage

    List<Map<String, double>> yearlyValues = [];
    double totalAmount = principal;
    double totalDeposits = principal;

    // Determine if contributions are monthly or yearly
    int contributionFrequency = _contributionFrequency == 'Monthly' ? 12 : 1;

    for (int year = 1; year <= time; year++) {
      // Apply compound interest for the current year
      totalAmount = totalAmount * pow(1 + (rate / 100) / compoundingFrequency, compoundingFrequency);
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

    // Calculate custom withdrawal based on the input percentage (yearly)
    _customWithdrawalRule = totalAmount * (withdrawalPercentage / 100);

    // Calculate the tax for the withdrawal amount based only on earnings
    double earningsRatio = (totalAmount - totalDeposits) / totalAmount;  // Ratio of earnings to total value
    double earningsWithdrawal = _customWithdrawalRule * earningsRatio;  // Annual earnings-based withdrawal
    double annualTax = _calculateTax(earningsWithdrawal);  // Annual tax based on earnings

    // Add this to the state so it can be displayed
    setState(() {
      _yearlyValues = yearlyValues;
      _customWithdrawalRule = totalAmount * (withdrawalPercentage / 100);  // Yearly withdrawal amount
      _customWithdrawalTax = annualTax;  // Yearly tax on earnings
    });
  }

  bool _showTaxNote = false;  // Initially, the tax note is hidden

  // Function to calculate the tax based on the progressive tax rates (applied to earnings only)
  double _calculateTax(double earningsWithdrawal) {
    double tax = 0;
    double threshold = 61000;

    if (earningsWithdrawal <= threshold) {
      // Apply 27% tax if the earnings withdrawal is less than or equal to 61,000 kr
      tax = earningsWithdrawal * 0.27;
    } else {
      // Apply 27% on the first 61,000 kr and 42% on the remaining amount
      tax = threshold * 0.27 + (earningsWithdrawal - threshold) * 0.42;
    }

    return tax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Compound Interest Calculator')),
      body: SingleChildScrollView(  // Wrap the whole content in SingleChildScrollView
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
            Text(
              'Investment After ${_timeController.text} Years: ${_yearlyValues.last['totalValue']!.toStringAsFixed(0)} kr.-',
              style: TextStyle(fontSize: 16),
            ),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButton<String>(
                      value: _withdrawalPercentageController.text,
                      items: ['3', '4', '5'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value + '%'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _withdrawalPercentageController.text = newValue!;
                          _calculateYearlyValues();  // Recalculate the values based on the selected percentage
                        });
                      },
                    ),
                    SizedBox(width: 16),
                    // Display the monthly withdrawal amount (divide yearly by 12)
                    Text(
                      'Withdrawal Each Month: ${( _customWithdrawalRule / 12).toStringAsFixed(0)} kr.-',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GestureDetector to make "Tax" clickable
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showTaxNote = !_showTaxNote;  // Toggle the visibility of the tax note
                        });
                      },
                      child: Text(
                        'Tax',  // Make "Tax" clickable
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,  // Indicate it's clickable
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      ' on Monthly Withdrawal: ${(_customWithdrawalTax / 12).toStringAsFixed(0)} kr.-',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                // Conditionally render the note if _showTaxNote is true
                if (_showTaxNote)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the tax note
                        Text(
                          'Note: The tax is calculated annually. The first earned 61,000 kr is taxed at 27%, and any amount above that is taxed at 42%. The displayed amount is the monthly tax, calculated based on the following: Tax Ratio = Total portfolio value - Total deposits.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),

                        // The LaTeX formulas for earnings and tax
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Math.tex(
                                r"""
                                \text{Earnings Percent} = \frac{\text{Total Value} - \text{Total Deposits}}{\text{Total Value}}
                                """,
                                textStyle: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Math.tex(
                                r"""
                                \text{Taxable Withdrawal} = \text{Earnings Percent} \times \text{Withdrawal Amount}
                                """,
                                textStyle: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Math.tex(
                                r"""
                                \text{Annual Tax} = 
                                \begin{cases} 
                                0.27 \times \text{Taxable Withdrawal}, & \text{if } \text{Taxable Withdrawal} \leq 61,000 \text{ kr} \\
                                0.27 \times 61,000 + 0.42 \times (\text{Taxable Withdrawal} - 61,000), & \text{if } \text{Taxable Withdrawal} > 61,000 \text{ kr}
                                \end{cases}
                                """,
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
              ],
            ),
            // Displaying the table of yearly investments with breakdown
            SingleChildScrollView(
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
                    DataCell(Text(value['totalValue']!.toStringAsFixed(0))),
                    DataCell(Text(value['totalDeposits']!.toStringAsFixed(0))),
                    DataCell(Text(value['compoundEarnings']!.toStringAsFixed(0))),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}