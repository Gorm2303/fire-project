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
import '../services/presetting_service.dart';
import '../services/utils.dart';
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
  
  final List<Map<String, double>> _yearlyValues = [];
  final List<Map<String, double>> _secondTableValues = [];

  String _contributionFrequency = 'Monthly';
  double _customWithdrawalRule = 0;
  double _customWithdrawalTax = 0;
  double _taxableWithdrawal = 0;
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

  // Load preset values using the PresettingService
  void _loadPresetValues(String presetKey) {
    final presetValues = PresettingService.getPreset(presetKey);

    setState(() {
      _principalController.text = presetValues['principal']!;
      _rateController.text = presetValues['rate']!;
      _timeController.text = presetValues['time']!;
      _additionalAmountController.text = presetValues['additionalAmount']!;
      _breakController.text = presetValues['breakPeriod']!;
      _presettingsController.text = presetKey;  // Update the dropdown text to the new selection
    });

    _recalculateValues();  // Recalculate the values after updating the controllers
  }

  void _recalculateValues() {
    setState(() {
      _resetYearlyValues();
      _calculateYearlyValues();
      _calculateSecondTableValues();
    });
  }

  void _resetYearlyValues() {
    _yearlyValues.add(
      {
        'year': 0.0,
        'totalValue': Utils.parseTextToDouble(_principalController.text),
        'totalDeposits': Utils.parseTextToDouble(_principalController.text),
        'compoundEarnings': 0,
        'compoundThisYear': 0,
      },
    );
  }

  void _calculateYearlyValues() {
    List<Map<String, double>> calculatedValues = _getYearlyValues();
    _yearlyValues.addAll(calculatedValues);
  }


  List<Map<String, double>> _getYearlyValues() {
    return calculateYearlyValues(
      principal: Utils.parseTextToDouble(_principalController.text),
      rate: Utils.parseTextToDouble(_rateController.text),
      time: Utils.parseTextToDouble(_timeController.text),
      additionalAmount: Utils.parseTextToDouble(_additionalAmountController.text),
      contributionFrequency: _contributionFrequency,
    );
  }

  List<Map<String, double>> _calculateSecondTableValues() {
    double initialValue = _yearlyValues.last['totalValue']!;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double previousValue;  // Track the total value from the previous year
    int breakPeriod = int.tryParse(_breakController.text) ?? 0;  // Get break period input
    double withdrawalTime = double.tryParse(_withdrawalTimeController.text) ?? 30;  // Withdrawal time in years
    double totalCompound = 0;  // Track total compound interest during withdrawal years
    double withdrawal = 0;  // Initialize withdrawal amount to 0
    double tax = 0;  // Initialize tax amount to 0
    compoundGatheredDuringBreak = 0;  // Reset compound gathered during break
    double totalAmount = initialValue;  // Initialize total amount to the initial value
    
    // Handle compounding during the break period without adding rows to the table
    if (breakPeriod >= 1) {
      for (int year = 1; year <= breakPeriod; year++) {
        totalAmount *= (1 + rate / 100);  // Apply interest
        previousValue = totalAmount;  // Update previous value after applying interest
      }
      compoundGatheredDuringBreak = totalAmount - initialValue;  // Track compound interest during the break period
    }

    // Add the current year (within break period) to the table
    _secondTableValues.add({
      'year': 0,
      'totalValue': totalAmount,
      'compoundThisYear': 0,
      'compoundEarnings': 0,
      'withdrawal': 0,  // No withdrawals during break period
      'tax': 0,  // No tax during break period
    });

    // Calculate CustomWithdrawalRule only after the break period
    _customWithdrawalRule = totalAmount * (double.tryParse(_withdrawalPercentageController.text) ?? 4) / 100;
    _taxableWithdrawal = calculateTaxableWithdrawal(totalAmount, _customWithdrawalRule);
    _customWithdrawalTax = _yearlyTotalTax(totalAmount, _customWithdrawalRule);

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
      tax = _yearlyTotalTax(totalAmount, withdrawal);  // Calculate tax on the withdrawal

      _secondTableValues.add({
        'year': year.toDouble(),  // Keep the year count starting from 1
        'totalValue': totalAmount,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': totalCompound,  // Track only compound interest from the withdrawal years
        'withdrawal': withdrawal,  // Show yearly withdrawal
        'tax': tax,  // Show tax for the year
      });
    }

    return _secondTableValues;
  }

  double calculateTaxableWithdrawal(double total, double withdrawal) {
    double deposits = _yearlyValues.last['totalDeposits']!;
    double earnings = Utils.calculateEarnings(total, deposits);
    double earningsPercent = Utils.calculateEarningsPercent(earnings, total);
    double taxableWithdrawal = Utils.calculateTaxableWithdrawal(earningsPercent, withdrawal, Utils.taxExemptionCard);
    return taxableWithdrawal;
  }

  double _yearlyTotalTax(double total, double withdrawal) {
    double tax;
    double taxableWithdrawal = calculateTaxableWithdrawal(total, withdrawal);

    // Step 4: Calculate Tax
    if (taxableWithdrawal <= 0) {
      return 0;  // No tax if taxableWithdrawal is less than or equal to 0
    }

    double parsedTax = double.tryParse(_customTaxController.text) ?? 0;

    if (_isCustomTaxRule) {
      // If the custom tax rule is active, calculate tax based on the custom tax rate
      tax = taxableWithdrawal * parsedTax / 100;
    } else if (_selectedTaxOption.rate == 42.0) {
      if (taxableWithdrawal <= Utils.threshold) {
        // If earningsWithdrawal is less than or equal to the threshold, apply 27% tax
        tax = taxableWithdrawal * 0.27;
      } else {
        // If earningsWithdrawal is above the threshold, apply 27% on the first 61,000 kr,
        // and 42% on the remaining amount
        tax = Utils.threshold * 0.27 + (taxableWithdrawal - Utils.threshold) * 0.42;
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

  Widget _buildFormulaWidget() {
    return 
    // Replace _parseTextToDouble calls with Utils.parseTextToDouble
      FormulaWidget(
        principal: Utils.parseTextToDouble(_principalController.text),
        rate: Utils.parseTextToDouble(_rateController.text),
        time: Utils.parseTextToDouble(_timeController.text),
        additionalAmount: Utils.parseTextToDouble(_additionalAmountController.text),
        contributionFrequency: _contributionFrequency,
      );
  }

  Widget _buildInvestmentTotalText() {
    return Text(
      'Investment After ${_timeController.text} Years: ${_yearlyValues.last['totalValue']!.toStringAsFixed(0)} kr.-',
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildSizedBox(double height) {
    return SizedBox(height: height);
  }

  Widget investmentCalculatorContent() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildInputFields(),
          _buildSizedBox(20),
          _buildFormulaWidget(),
          _buildSizedBox(20),
          _buildInvestmentTotalText(),
          _buildSizedBox(15),
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
      presetValues: PresettingService.getPresetKeys(),
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
        taxableWithdrawal: _taxableWithdrawal,
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
