import 'package:fire_app/models/tax_option.dart';
import 'package:flutter/material.dart';
import '../widgets/formula_widget.dart';
import '../widgets/tax_widget.dart';
import '../models/investment_plan.dart';
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

  List<Map<String, double>> _yearlyValues = [];
  List<Map<String, double>> _secondTableValues = [];

  String _contributionFrequency = 'Monthly';
  String _selectedTab = 'Investment Calculator';
  bool _isCustomTaxRule = false;
  bool _showTaxNote = false;

  late InvestmentPlan _investmentPlan;
  
  List<TaxOption> taxOptions = [
    TaxOption(15.3, 'Pension PAL-skat', false),
    TaxOption(17.0, 'Aktiesparekonto', false),
    TaxOption(42.0, 'Normal Aktiebeskatning*', false),
  ];

  late TaxOption _selectedTaxOption = taxOptions[2];

  @override
  void initState() {
    super.initState();
    _initializeTabControllers();
    _initializeToggleSwitchWidget();
    _loadPresetValues('High Investment');
    _initializeInvestmentPlan();
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

  void _initializeInvestmentPlan() {
    _investmentPlan = InvestmentPlan(
      name: "Custom Plan",
      principal: Utils.parseTextToDouble(_principalController.text),
      rate: Utils.parseTextToDouble(_rateController.text),
      depositYears: Utils.parseTextToInt(_timeController.text),
      additionalAmount: Utils.parseTextToDouble(_additionalAmountController.text),
      contributionFrequency: _contributionFrequency,
      selectedTaxOption: _selectedTaxOption,
      withdrawalPercentage: Utils.parseTextToDouble(_withdrawalPercentageController.text),
      breakPeriod: Utils.parseTextToInt(_breakController.text),
      withdrawalPeriod: Utils.parseTextToInt(_withdrawalTimeController.text),
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
      _initializeInvestmentPlan(); // Update the investment plan with current values
      _investmentPlan.calculateInvestment();  // Calculate deposit and withdrawal values
      _yearlyValues = _investmentPlan.depositValues!;
      _secondTableValues = _investmentPlan.withdrawalValues!;
    });
  }

  @override
  void dispose() {
    _tableTabController.dispose();
    _mainTabController.dispose();
    super.dispose();
  }

  Widget _buildFormulaWidget() {
    return FormulaWidget(
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
      customWithdrawalRule: _investmentPlan.withdrawalPlan.withdrawalPercentage,
      customWithdrawalTax: _investmentPlan.withdrawalPlan.taxYearly,
      recalculateValues: _recalculateValues,
      breakController: _breakController,
      interestGatheredDuringBreak: _investmentPlan.withdrawalPlan.interestGatheredDuringBreak,
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
        earnings: _investmentPlan.withdrawalPlan.earnings,
        earningsPercent: _investmentPlan.withdrawalPlan.earningsPercent,
        taxableWithdrawal: _investmentPlan.withdrawalPlan.taxableWithdrawalYearly,
        annualTax: _investmentPlan.withdrawalPlan.taxYearly,
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
