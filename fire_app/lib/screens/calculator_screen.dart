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
  final TextEditingController _withdrawalTimeController = TextEditingController(text: '30'); // Add this controller

  List<Map<String, double>> _yearlyValues = [];  // Initialize the list to store yearly values
  List<Map<String, double>> _secondTableValues = [];
  String _contributionFrequency = 'Monthly'; // Default contribution frequency
  double _customWithdrawalRule = 0;  // Store the custom withdrawal amount
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
      const double threshold = 61000;  // The threshold for lower tax rate
      double tax;

      // Apply tax only if withdrawals occur (i.e., earningsWithdrawal > 0)
      if (earningsWithdrawal > 0) {
          if (earningsWithdrawal <= threshold) {
              // If earningsWithdrawal is less than or equal to the threshold, apply 27% tax
              tax = earningsWithdrawal * 0.27;
          } else {
              // If earningsWithdrawal is above the threshold, apply 27% on the first 61,000 kr,
              // and 42% on the remaining amount
              tax = threshold * 0.27 + (earningsWithdrawal - threshold) * 0.42;
          }
      } else {
          tax = 0;  // No tax if there are no earnings to withdraw
      }

      return tax;
  }

  void _recalculateValues() {
    setState(() {
      // Use calculateYearlyValues for the depositing years
      _yearlyValues = [
        {
          'year': 0.0,  // Year 0
          'totalValue': double.tryParse(_principalController.text) ?? 0,
          'totalDeposits': double.tryParse(_principalController.text) ?? 0,
          'compoundEarnings': 0,  // No compound earnings at Year 0
          'compoundThisYear': 0,  // No compound this year for Year 0
        }
      ];

      // Calculate the values for the first table (depositing years)
      _yearlyValues.addAll(calculateYearlyValues(
        principal: double.tryParse(_principalController.text) ?? 0,
        rate: double.tryParse(_rateController.text) ?? 0,
        time: double.tryParse(_timeController.text) ?? 0,
        additionalAmount: double.tryParse(_additionalAmountController.text) ?? 0,
        contributionFrequency: _contributionFrequency,
      ));

      if (_yearlyValues.isNotEmpty) {
        double totalAmount = _yearlyValues.last['totalValue'] ?? 0;

        // Calculate the second table values starting after the break period
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
    double withdrawalTime = double.tryParse(_withdrawalTimeController.text) ?? 10;  // Withdrawal time in years
    double totalCompound = 0;  // Track total compound interest during withdrawal years
    double withdrawal = 0;  // Initialize withdrawal amount to 0
    double tax = 0;  // Initialize tax amount to 0

    // Handle compounding during the break period without adding rows to the table
    if (breakPeriod >= 1) {
      for (int year = 1; year <= breakPeriod; year++) {
        totalAmount *= (1 + rate / 100);  // Apply interest
        previousValue = totalAmount;  // Update previous value after applying interest
        compoundGatheredDuringBreak = totalAmount - initialValue;  // Track compound interest during the break period
      }
    }

    // Add the current year (within break period) to the table
    secondTableValues.add({
      'year': 0,
      'totalValue': totalAmount,
      'compoundThisYear': 0,
      'compoundEarnings': 0,
      'withdrawal': 0,  // No withdrawals during break period
      'tax': 0,  // No tax during break period
    });

    // Calculate CustomWithdrawalRule only after the break period
    _customWithdrawalRule = totalAmount * (double.tryParse(_withdrawalPercentageController.text) ?? 4) / 100;

    // Now handle the withdrawal period and create table rows
    for (int year = 1; year <= withdrawalTime; year++) {
      // Before applying interest, store the previous year's total value
      previousValue = totalAmount;

      // Apply interest for the year
      totalAmount *= (1 + rate / 100);

      // Calculate compound interest earned this year
      double compoundThisYear = totalAmount - previousValue;
      totalCompound += compoundThisYear;  // Accumulate only the interest from the withdrawal years

      // Apply withdrawals and calculate tax during the withdrawal period
      withdrawal = _customWithdrawalRule;
      totalAmount -= withdrawal;  // Subtract yearly withdrawal
      tax = _calculateTax(withdrawal);  // Calculate tax on the withdrawal

      secondTableValues.add({
        'year': year.toDouble(),  // Keep the year count starting from 1
        'totalValue': totalAmount,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': totalCompound,  // Track only compound interest from the withdrawal years
        'withdrawal': withdrawal,  // Show yearly withdrawal
        'tax': tax,  // Show tax for the year
      });
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
            // Other widgets like FormulaWidget, Table, etc.,
            const SizedBox(height: 30),
            // Dynamically display the formula
            FormulaWidget(
              principal: double.tryParse(_principalController.text) ?? 0,
              rate: double.tryParse(_rateController.text) ?? 0,
              time: double.tryParse(_timeController.text) ?? 0,
              additionalAmount: double.tryParse(_additionalAmountController.text) ?? 0,
              contributionFrequency: _contributionFrequency,
            ),
            const SizedBox(height: 20),
            // Display the total investment after the given time
            Text(
              'Investment After ${_timeController.text} Years: ${_yearlyValues.last['totalValue']!.toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),  // Spacing between rows
            The4PercentWidget(
              withdrawalPercentageController: _withdrawalPercentageController,
              customWithdrawalRule: _customWithdrawalRule,
              customWithdrawalTax: _calculateTax(_customWithdrawalRule),
              recalculateValues: _recalculateValues,
              showTaxNote: _showTaxNote,
              breakController: _breakController,
              compoundGatheredDuringBreak: compoundGatheredDuringBreak,
              onInputChanged: _recalculateValues,  // Trigger recalculation on input change
              withdrawalTimeController: _withdrawalTimeController,
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
            ), 
            SizedBox(
              height: 475,  // Define a height for the table
              child: TabBarView(
                controller: _tabController,
                children: [
                  // First investment table
                  InvestmentTableWidget(
                    yearlyValues: _yearlyValues,  // Pass the calculated values for table 1
                    isDepositingTable: true,  // Show total deposits in the first table
                    isWithdrawingTable: false,  // Hide withdrawal and tax columns in the first table
                  ),
                  // Second investment table: Evolution without additional deposits
                  InvestmentTableWidget(
                    yearlyValues: _secondTableValues,  // Pass the calculated values for table 2
                    isDepositingTable: false,  // Hide total deposits in the second table
                    isWithdrawingTable: true,  // Show withdrawal and tax columns in the second table
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}