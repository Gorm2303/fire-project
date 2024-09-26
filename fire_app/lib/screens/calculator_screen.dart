import 'package:fire_app/models/tax_option.dart';
import 'package:flutter/material.dart';
import '../widgets/formula_widget.dart';
import '../widgets/tax_widget.dart';
import '../widgets/investment_calculator.dart';
import '../widgets/investment_table_widget.dart';
import '../widgets/input_fields_widget.dart';
import '../widgets/the4percent_widget.dart';
import '../widgets/tab_dropdown_widget.dart';
import '../widgets/earnings_withdrawal_ratio.dart';
import '../widgets/switch_taxrate_widget.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with TickerProviderStateMixin {
  late TabController _tableTabController;
  late TabController _mainTabController;

  final TextEditingController _principalController = TextEditingController(text: '0');
  final TextEditingController _rateController = TextEditingController(text: '0');
  final TextEditingController _timeController = TextEditingController(text: '0');
  final TextEditingController _additionalAmountController = TextEditingController(text: '0');
  final TextEditingController _withdrawalPercentageController = TextEditingController(text: '4');
  final TextEditingController _breakController = TextEditingController(text: '0');
  final TextEditingController _withdrawalTimeController = TextEditingController(text: '30');
  final TextEditingController _presettingsController = TextEditingController(text: 'None');
  final TextEditingController _customTaxController = TextEditingController(text: '0');

  late SwitchAndTaxRate _toggleSwitchWidget;
  
  List<Map<String, double>> _yearlyValues = [];
  List<Map<String, double>> _secondTableValues = [];

  String _contributionFrequency = 'Monthly';
  double _customWithdrawalRule = 0;
  double _customWithdrawalTax = 0;
  double _totalAfterBreak = 0;
  double _earningsAfterBreak = 0;
  double _earningsPercentAfterBreak = 0;

  bool _isCustomTaxRule = false;
  bool _showTaxNote = false;

  double compoundGatheredDuringBreak = 0;
  String _selectedTab = 'Investment Calculator';

  List<TaxOption> taxOptions = [
    TaxOption(15.3, 'Pension PAL-skat'),
    TaxOption(17.0, 'Aktiesparekonto'),
    TaxOption(42.0, 'Normal Aktiebeskatning*'),
  ];

  late TaxOption _selectedTaxOption = taxOptions[2];

    final Map<String, Map<String, String>> presettings = {
  'None': {
    'principal': '0',
    'rate': '0',
    'time': '0',
    'additionalAmount': '0',
    'breakPeriod': '0',
  },
  'Medium Investment': {
    'principal': '5000',
    'rate': '7',
    'time': '25',
    'additionalAmount': '5000',
    'breakPeriod': '0',
  },
  'Long Light Investment': {
    'principal': '2000',
    'rate': '7',
    'time': '40',
    'additionalAmount': '2000',
    'breakPeriod': '0',
  }, 
  'High Investment': {
    'principal': '10000',
    'rate': '7',
    'time': '25',
    'additionalAmount': '10000',
    'breakPeriod': '0',
  },
  'Slightly Extreme Investment': {
    'principal': '15000',
    'rate': '7',
    'time': '25',
    'additionalAmount': '15000',
    'breakPeriod': '0',
  },
  'Extreme Investment': {
    'principal': '20000',
    'rate': '7',
    'time': '20',
    'additionalAmount': '20000',
    'breakPeriod': '0',
  },
  'High Investment with Break': {
    'principal': '10000',
    'rate': '7',
    'time': '20',
    'additionalAmount': '10000',
    'breakPeriod': '10',
  },
    'Long Medium Investment': {
    'principal': '5000',
    'rate': '7',
    'time': '40',
    'additionalAmount': '5000',
    'breakPeriod': '0',
  },
  'Child Savings': {
    'principal': '5000',
    'rate': '7',
    'time': '21',
    'additionalAmount': '100',
    'breakPeriod': '0',
  },
  'Pension': {
    'principal': '2000',
    'rate': '7',
    'time': '40',
    'additionalAmount': '2000',
    'breakPeriod': '0',
  },
  'Child Pension Savings': {
    'principal': '5000',
    'rate': '7',
    'time': '10',
    'additionalAmount': '1000',
    'breakPeriod': '50',
  },
};

  @override
  void initState() {
    super.initState();
    _initializeTabControllers();
    _initializeToggleSwitchWidget();
    _loadPresetValues('High Investment');
  }

  void _initializeTabControllers() {
    _tableTabController = TabController(length: 2, vsync: this);
    _mainTabController = TabController(length: 2, vsync: this);
  }

  void _initializeToggleSwitchWidget() {
    _toggleSwitchWidget = SwitchAndTaxRate(
      customTaxController: _customTaxController,
      selectedTaxOption: _selectedTaxOption,
      taxOptions: taxOptions,
      recalculateValues: _recalculateValues,
      isCustom: _isCustomTaxRule,
      onSwitchChanged: (bool value) {
        setState(() {
          _isCustomTaxRule = value;
          _recalculateValues();
        });
      },
      onTaxOptionChanged: (TaxOption newOption) {
        setState(() {
          _selectedTaxOption = newOption;
        });
        _recalculateValues();
      },
    );
  }

  void _loadPresetValues(String presetKey) {
    if (presettings.containsKey(presetKey)) {
      setState(() {
        _principalController.text = presettings[presetKey]!['principal']!;
        _rateController.text = presettings[presetKey]!['rate']!;
        _timeController.text = presettings[presetKey]!['time']!;
        _additionalAmountController.text = presettings[presetKey]!['additionalAmount']!;
        _breakController.text = presettings[presetKey]!['breakPeriod']!;
        _presettingsController.text = presetKey;
      });
      _recalculateValues();
    }
  }

  void _recalculateValues() {
    // Reset yearly values
    _yearlyValues = [
      {
        'year': 0.0,
        'totalValue': _parseTextToDouble(_principalController.text),
        'totalDeposits': _parseTextToDouble(_principalController.text),
        'compoundEarnings': 0,
        'compoundThisYear': 0,
      }
    ];

    _yearlyValues.addAll(_calculateYearlyValues());

    if (_yearlyValues.isNotEmpty) {
      double totalAmount = _yearlyValues.last['totalValue'] ?? 0;
      _secondTableValues = _calculateSecondTableValues(totalAmount);
    } else {
      _secondTableValues.clear();
    }
  }

  double _parseTextToDouble(String text) {
    return double.tryParse(text) ?? 0;
  }

  List<Map<String, double>> _calculateYearlyValues() {
    // Extracted the logic for calculating yearly values.
    return calculateYearlyValues(
      principal: _parseTextToDouble(_principalController.text),
      rate: _parseTextToDouble(_rateController.text),
      time: _parseTextToDouble(_timeController.text),
      additionalAmount: _parseTextToDouble(_additionalAmountController.text),
      contributionFrequency: _contributionFrequency,
    );
  }

    List<Map<String, double>> _calculateSecondTableValues(double initialValue) {
    List<Map<String, double>> secondTableValues = [];
    double totalAmount = initialValue;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double previousValue = totalAmount;  // Track the total value from the previous year
    int breakPeriod = int.tryParse(_breakController.text) ?? 0;  // Get break period input
    double withdrawalTime = double.tryParse(_withdrawalTimeController.text) ?? 30;  // Withdrawal time in years
    double totalCompound = 0;  // Track total compound interest during withdrawal years
    double withdrawal = 0;  // Initialize withdrawal amount to 0
    double tax = 0;  // Initialize tax amount to 0
    compoundGatheredDuringBreak = 0;  // Reset compound gathered during break

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
    _customWithdrawalTax = _yearlyTotalTax(totalAmount, _yearlyValues.last['totalDeposits']!, _customWithdrawalRule);

    // Store the total amount after the break period
    _totalAfterBreak = totalAmount;
    _earningsAfterBreak = _totalAfterBreak - _yearlyValues.last['totalDeposits']!;
    _earningsPercentAfterBreak = _earningsAfterBreak / _totalAfterBreak;

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
      tax = _yearlyTotalTax(totalAmount, _yearlyValues.last['totalDeposits']!, withdrawal);  // Calculate tax on the withdrawal

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

    double _yearlyTotalTax(double total, double deposits, double withdrawal) {
    const double threshold = 61000;  // The threshold for lower tax rate
    const double taxExemptionCard = 49700;  // The tax-free limit
    double tax;

    // Step 1: Calculate Earnings
    double earnings = total - deposits;

    if (total <= 0) {
      return 0;  // No tax if total is less than or equal to 0
    }
    // Step 2: Calculate Earnings Percent
    double earningsPercent = earnings / total;

    // Step 3: Calculate Taxable Withdrawal
    double taxableWithdrawal = earningsPercent * withdrawal - taxExemptionCard;

    // Step 4: Calculate Tax
    if (taxableWithdrawal <= 0) {
      return 0;  // No tax if taxableWithdrawal is less than or equal to 0
    }

    double parsedTax = double.tryParse(_customTaxController.text) ?? 0;

    if (_isCustomTaxRule) {
      // If the custom tax rule is active, calculate tax based on the custom tax rate
      tax = taxableWithdrawal * parsedTax / 100;
    } else if (_selectedTaxOption.rate == 42.0) {
      if (taxableWithdrawal <= threshold) {
        // If earningsWithdrawal is less than or equal to the threshold, apply 27% tax
        tax = taxableWithdrawal * 0.27;
      } else {
        // If earningsWithdrawal is above the threshold, apply 27% on the first 61,000 kr,
        // and 42% on the remaining amount
        tax = threshold * 0.27 + (taxableWithdrawal - threshold) * 0.42;
      }
    } else {
      // If the selected tax option is not 15.3, apply the tax rate from the selected option
      tax = taxableWithdrawal * _selectedTaxOption.rate / 100;
    }

    return tax;
  }

  @override
  void dispose() {
    _tableTabController.dispose();
    _mainTabController.dispose();
    super.dispose();
  }

  Widget investmentCalculatorContent() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildInputFields(),
          const SizedBox(height: 30),
          FormulaWidget(
            principal: _parseTextToDouble(_principalController.text),
            rate: _parseTextToDouble(_rateController.text),
            time: _parseTextToDouble(_timeController.text),
            additionalAmount: _parseTextToDouble(_additionalAmountController.text),
            contributionFrequency: _contributionFrequency,
          ),
          const SizedBox(height: 20),
          Text(
            'Investment After ${_timeController.text} Years: ${_yearlyValues.last['totalValue']!.toStringAsFixed(0)} kr.-',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 15),
          _build4PercentWidget(),
          _buildTaxWidget(),
          _buildTabView(),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return InputFieldsWidget(
      principalController: _principalController,
      rateController: _rateController,
      timeController: _timeController,
      additionalAmountController: _additionalAmountController,
      presettingsController: _presettingsController,
      contributionFrequency: _contributionFrequency,
      presetValues: presettings,
      onPresetSelected: _loadPresetValues,
      onInputChanged: _recalculateValues,
      onContributionFrequencyChanged: (String newFrequency) {
        setState(() {
          _contributionFrequency = newFrequency;
          _recalculateValues();
        });
      },
    );
  }

  Widget _build4PercentWidget() {
    return The4PercentWidget(
      withdrawalPercentageController: _withdrawalPercentageController,
      customWithdrawalRule: _customWithdrawalRule,
      customWithdrawalTax: _customWithdrawalTax,
      recalculateValues: _recalculateValues,
      breakController: _breakController,
      compoundGatheredDuringBreak: compoundGatheredDuringBreak,
      withdrawalTimeController: _withdrawalTimeController,
      taxController: _customTaxController,
      toggleSwitchWidget: _toggleSwitchWidget,
      toggleTaxNote: () {
        setState(() {
          _showTaxNote = !_showTaxNote;
        });
      },
    );
  }

  Widget _buildTaxWidget() {
    return TaxWidget(
      showTaxNote: _showTaxNote,
      earningsWithdrawalRatio: EarningsWithdrawalRatio(
        earnings: _earningsAfterBreak,
        earningsPercent: _earningsPercentAfterBreak,
        taxableWithdrawal: _customWithdrawalRule,
        annualTax: _customWithdrawalTax,
      ),
    );
  }

  Widget _buildTabView() {
    return Column(
      children: [
        TabBar(
          controller: _tableTabController,
          tabs: const [
            Tab(text: 'Depositing Years'),
            Tab(text: 'Withdrawal Years'),
          ],
        ),
        SizedBox(
          height: 475,
          child: TabBarView(
            controller: _tableTabController,
            children: [
              InvestmentTableWidget(
                yearlyValues: _yearlyValues,
                isDepositingTable: true,
                isWithdrawingTable: false,
              ),
              InvestmentTableWidget(
                yearlyValues: _secondTableValues,
                isDepositingTable: false,
                isWithdrawingTable: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget expensesCalculatorContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.money_off_csred_rounded, size: 100),
          Text('Expenses Calculator Coming Soon!', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compound Interest Calculators'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: TabDropdownWidget(
            selectedOption: _selectedTab,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTab = newValue!;
              });
            },
          ),
        ),
      ),
      body: _selectedTab == 'Investment Calculator'
          ? investmentCalculatorContent()
          : expensesCalculatorContent(),
    );
  }
}
