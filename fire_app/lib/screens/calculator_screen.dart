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
  final TextEditingController _additionalAmountController = TextEditingController(text: '1000');
  final TextEditingController _withdrawalPercentageController = TextEditingController(text: '4');  // Default 4%
  final TextEditingController _breakController = TextEditingController(text: '0');

  List<Map<String, double>> _yearlyValues = [];  // Initialize the list to store yearly values
  List<Map<String, double>> _secondTableValues = [];
  String _contributionFrequency = 'Monthly'; // Default contribution frequency
  double _customWithdrawalRule = 0;  // Store the custom withdrawal amount
  double _customWithdrawalTax = 0;  // Store the calculated tax
  bool _showTaxNote = false;  // Initially, the tax note is hidden
  double compoundGatheredDuringBreak = 0; 

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

    // Apply tax only if withdrawals occur (i.e., after the break period)
    if (earningsWithdrawal > 0) {
      if (earningsWithdrawal <= threshold) {
        tax = earningsWithdrawal * 0.27;
      } else {
        tax = threshold * 0.27 + (earningsWithdrawal - threshold) * 0.42;
      }
    } else {
      tax = 0;  // No tax if there are no earnings to withdraw
    }

    return tax;
  }

  List<Map<String, double>> _calculateYearlyValues() {
    // Calculate the yearly values based on the input fields
    return calculateYearlyValues(
      principal: double.tryParse(_principalController.text) ?? 0,
      rate: double.tryParse(_rateController.text) ?? 0,
      time: double.tryParse(_timeController.text) ?? 0,
      additionalAmount: double.tryParse(_additionalAmountController.text) ?? 0,
      contributionFrequency: _contributionFrequency,
    );
  }

  void _recalculateValues() {
    setState(() {
      // Calculate the first investment table (with deposits)
      _yearlyValues = calculateYearlyValues(
        principal: double.tryParse(_principalController.text) ?? 0,
        rate: double.tryParse(_rateController.text) ?? 0,
        time: double.tryParse(_timeController.text) ?? 0,
        additionalAmount: double.tryParse(_additionalAmountController.text) ?? 0,
        contributionFrequency: _contributionFrequency,
      );

      if (_yearlyValues.isNotEmpty) {
        double totalAmount = _yearlyValues.last['totalValue'] ?? 0;
        double withdrawalPercentage = double.tryParse(_withdrawalPercentageController.text) ?? 4;
        int breakPeriod = int.tryParse(_breakController.text) ?? 0;

        _customWithdrawalRule = totalAmount * (withdrawalPercentage / 100);

        // Track the compound interest during the break period
        compoundGatheredDuringBreak = 0;
        double previousValue = totalAmount;
        for (int i = 0; i < breakPeriod; i++) {
          totalAmount = totalAmount * (1 + (_rateController.text.isNotEmpty ? double.parse(_rateController.text) : 0) / 100);
          compoundGatheredDuringBreak += totalAmount - previousValue;
          previousValue = totalAmount;
        }

        _secondTableValues = _calculateSecondTableValues(totalAmount);
      } else {
        _secondTableValues.clear();
      }
    });
  }

  List<Map<String, double>> _calculateSecondTableValues(double initialValue) {
    List<Map<String, double>> secondTableValues = [];
    double totalAmount = initialValue;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double previousValue = totalAmount;  // Track the total value from the previous year
    int breakPeriod = int.tryParse(_breakController.text) ?? 0;  // Get break period input
    double time = double.tryParse(_timeController.text) ?? 0;

    // Apply interest for the break period or at least one year before withdrawals start
    for (int year = 1; year <= (time + breakPeriod); year++) {
      if (breakPeriod == 0 && year == 1) {
        // If no break period, compound for at least 1 year before starting withdrawals
        totalAmount = totalAmount * (1 + rate / 100);
      } else if (year > breakPeriod) {
        // Apply withdrawals after the break period
        totalAmount -= _customWithdrawalRule * 12;
      }

      // Apply interest for the year (even after withdrawal)
      totalAmount = totalAmount * (1 + rate / 100);

      // Calculate compound interest earned this year
      double compoundThisYear = totalAmount - previousValue;

      secondTableValues.add({
        'year': year.toDouble(),
        'totalValue': totalAmount,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': totalAmount - initialValue,
      });

      // Update previous value for the next iteration
      previousValue = totalAmount;
    }

    return secondTableValues;
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
              breakController: _breakController,
              compoundGatheredDuringBreak: compoundGatheredDuringBreak,
              onInputChanged: _recalculateValues,  // Trigger recalculation on input change
              toggleTaxNote: () {
                setState(() {
                  _showTaxNote = !_showTaxNote;
                });
              },
            ), // Conditionally render the note if _showTaxNote is true
            TaxWidget(
              showTaxNote: _showTaxNote,  // Pass the value to control the note visibility
            ),
            const SizedBox(height: 20),
            // Displaying the table of yearly investments with breakdown
            // Tabbed table view for switching between two investment tables
            TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Depositing Years'),
            Tab(text: 'Withdrawal Years'),
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
                        showTotalDeposits: true,  // Show total deposits in the first table
                      ),
                    ),
                  ),
                  // Second investment table: Evolution without additional deposits
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,  // Allow vertical scrolling
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,  // Allow horizontal scrolling
                      child: InvestmentTableWidget(
                        yearlyValues: _secondTableValues,  // Pass the calculated values for table 2
                        showTotalDeposits: false,  // Hide total deposits in the second table
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