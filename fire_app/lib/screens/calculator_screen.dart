import 'package:flutter/material.dart';
import '../widgets/formula_widget.dart';
import '../widgets/tax_widget.dart';
import '../widgets/investment_calculator.dart';
import '../widgets/investment_table_widget.dart';
import '../widgets/input_fields_widget.dart';
import '../widgets/the4percent_widget.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _principalController = TextEditingController(text: '1000');
  final TextEditingController _rateController = TextEditingController(text: '7');
  final TextEditingController _timeController = TextEditingController(text: '25');
  final TextEditingController _compoundController = TextEditingController(text: '1');
  final TextEditingController _additionalAmountController = TextEditingController(text: '100');
  final TextEditingController _withdrawalPercentageController = TextEditingController(text: '4');  // Default 4%

  List<Map<String, double>> _yearlyValues = [];  // Initialize the list to store yearly values
  String _contributionFrequency = 'Monthly'; // Default contribution frequency
  double _customWithdrawalRule = 0;  // Store the custom withdrawal amount
  double _customWithdrawalTax = 0;  // Store the calculated tax
  bool _showTaxNote = false;  // Initially, the tax note is hidden

  @override
  void initState() {
    super.initState();
    // Calculate table when the page is loaded
    _tabController = TabController(length: 2, vsync: this);  // Initialize the TabController with two tabs
    setState(() {
      _recalculateValues();
    });  
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _calculateTax(double earningsWithdrawal) {
  const double threshold = 61000;
  double tax;

  if (earningsWithdrawal <= threshold) {
    // Apply 27% tax if the earnings withdrawal is less than or equal to 61,000 kr
    tax = earningsWithdrawal * 0.27;
  } else {
    // Apply 27% on the first 61,000 kr and 42% on the remaining amount
    tax = threshold * 0.27 + (earningsWithdrawal - threshold) * 0.42;
  }

  return tax;
}

  List<Map<String, double>> _calculateYearlyValues() {
    // Calculate the yearly values based on the input fields
    List<Map<String, double>> yearlyValues = calculateYearlyValues(
      principal: double.tryParse(_principalController.text) ?? 0,
      rate: double.tryParse(_rateController.text) ?? 0,
      time: double.tryParse(_timeController.text) ?? 0,
      compoundingFrequency: int.tryParse(_compoundController.text) ?? 1,
      additionalAmount: double.tryParse(_additionalAmountController.text) ?? 0,
      contributionFrequency: _contributionFrequency,
    );
    return yearlyValues;
  }

  void _recalculateValues() {
    setState(() {
      _yearlyValues = _calculateYearlyValues();
      // Additional calculation logic for withdrawal and tax
      if (_yearlyValues.isNotEmpty) {
        double totalAmount = _yearlyValues.last['totalValue']!;
        double withdrawalPercentage = double.tryParse(_withdrawalPercentageController.text) ?? 4;

        _customWithdrawalRule = totalAmount * (withdrawalPercentage / 100);
        double earningsRatio = (totalAmount - _yearlyValues.last['totalDeposits']!) / totalAmount;
        double earningsWithdrawal = _customWithdrawalRule * earningsRatio;
        _customWithdrawalTax = _calculateTax(earningsWithdrawal);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Compound Interest Calculator')), // Set the title
      body: SingleChildScrollView(  // Wrap the whole content in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Input fields that update the formula on change
            InputFieldsWidget(
              principalController: _principalController,
              rateController: _rateController,
              timeController: _timeController,
              compoundController: _compoundController,
              additionalAmountController: _additionalAmountController,
              contributionFrequency: _contributionFrequency,
              onInputChanged: _recalculateValues,  // Trigger recalculation on input change
              onContributionFrequencyChanged: (String newFrequency) {
                setState(() {
                  _contributionFrequency = newFrequency;
                  _recalculateValues();
                });
              },
            ),
            const SizedBox(height: 20),
            // Other widgets like FormulaWidget, Table, etc.,
            const SizedBox(height: 20),
            // Dynamically display the formula
            FormulaWidget(
              principal: double.tryParse(_principalController.text) ?? 0,
              rate: double.tryParse(_rateController.text) ?? 0,
              time: double.tryParse(_timeController.text) ?? 0,
              compoundingFrequency: int.tryParse(_compoundController.text) ?? 1,
              additionalAmount: double.tryParse(_additionalAmountController.text) ?? 0,
              contributionFrequency: _contributionFrequency,
            ),
            const SizedBox(height: 20),
            The4PercentWidget(
              withdrawalPercentageController: _withdrawalPercentageController,
              customWithdrawalRule: _customWithdrawalRule,
              customWithdrawalTax: _customWithdrawalTax,
              recalculateValues: _recalculateValues,
              showTaxNote: _showTaxNote,
              toggleTaxNote: () {
                setState(() {
                  _showTaxNote = !_showTaxNote;
                });
              },
            ),                // Conditionally render the note if _showTaxNote is true
            TaxWidget(
              showTaxNote: _showTaxNote,  // Pass the value to control the note visibility
            ),
            const SizedBox(height: 20),
            // Displaying the table of yearly investments with breakdown
            // Tabbed table view for switching between two investment tables
            TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Investment Table 1'),
            Tab(text: 'Investment Table 2'),
          ],
        ), SizedBox(
              height: 400,  // Define a height for the table
              child: TabBarView(
                controller: _tabController,
                children: [
                  // First investment table
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,  // Allow vertical scrolling
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,  // Allow horizontal scrolling
                      child: InvestmentTableWidget(
                        yearlyValues: _yearlyValues,  // Pass the calculated values for table 1
                      ),
                    ),
                  ),
                  // Second investment table
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,  // Allow vertical scrolling
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,  // Allow horizontal scrolling
                      child: InvestmentTableWidget(
                        yearlyValues: _yearlyValues,  // Pass the calculated values for table 2
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}