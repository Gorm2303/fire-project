import 'package:fire_app/models/tax_option.dart';
import 'package:fire_app/widgets/investment_widgets/investment_compounding_results_widget.dart';
import 'package:fire_app/widgets/investment_widgets/investment_note_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tax_option_manager.dart';
import '../widgets/investment_widgets/formula_widget.dart';
import '../widgets/withdrawal_tax_widgets/tax_note_widget.dart';
import '../models/investment_plan.dart';
import '../widgets/investment_table_widget.dart';
import '../widgets/investment_widgets/input_fields_widget.dart';
import '../widgets/the4percent_widget.dart';
import '../widgets/tab_dropdown_widget.dart';
import '../widgets/withdrawal_tax_widgets/tax_calculation_results_widget.dart';
import '../widgets/withdrawal_tax_widgets/switch_taxrate_widget.dart';
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
  final TextEditingController _interestRateController = TextEditingController(text: '0');
  final TextEditingController _durationController = TextEditingController(text: '0');
  final TextEditingController _additionalAmountController = TextEditingController(text: '0');
  final TextEditingController _withdrawalPercentageController = TextEditingController(text: '0');
  final TextEditingController _breakController = TextEditingController(text: '0');
  final TextEditingController _withdrawalDurationController = TextEditingController(text: '0');
  final TextEditingController _presettingsController = TextEditingController(text: 'None');
  final TextEditingController _customTaxController = TextEditingController(text: '0');

  List<Map<String, double>> _depositYearlyValues = [];
  List<Map<String, double>> _withdrawalYearlyValues = [];

  String _contributionFrequency = 'Monthly';
  String _selectedTab = 'Investment Calculator';
  bool _showTaxNote = false;
  bool showInvestmentNote = false;

  final List<TaxOption> _taxOptions = [
    TaxOption(42.0, 'Tax On Sale', isNotionallyTaxed: false, useTaxExemptionCardAndThreshold: true),
    TaxOption(42.0, 'Tax Every Year', isNotionallyTaxed: true, useTaxExemptionCardAndThreshold: false),
    TaxOption(17.0, 'Aktiesparekonto', isNotionallyTaxed: true, useTaxExemptionCardAndThreshold: false),
    TaxOption(15.3, 'Pension PAL-skat', isNotionallyTaxed: true, useTaxExemptionCardAndThreshold: false),
    TaxOption(42.0, 'Tax On Sale*', isNotionallyTaxed: false, useTaxExemptionCardAndThreshold: false),
  ];

  late InvestmentPlan _investmentPlan;
  late TaxOptionManager _taxOptionManager;

  @override
  void initState() {
    super.initState();

    _initializeTaxOptionManager();
    _initializeTabControllers();
    _initializeInvestmentPlan();  // Call this during initialization to ensure it's set up

    // Optionally load a preset if needed after everything is initialized
    _loadPresetValues('High Investment');
  }

  void _initializeTaxOptionManager() {
    _taxOptionManager = TaxOptionManager(
      initialOption: _taxOptions[0],
      taxOptions: _taxOptions,
    );
  }

  void _initializeTabControllers() {
    _tableTabController = TabController(length: 2, vsync: this);
    _mainTabController = TabController(length: 2, vsync: this);
  }

  void _initializeInvestmentPlan() {
    _investmentPlan = InvestmentPlan(
      name: "Custom Plan",
      principal: Utils.parseTextToDouble(_principalController.text),
      interestRate: Utils.parseTextToDouble(_interestRateController.text),
      depositYears: Utils.parseTextToInt(_durationController.text),
      additionalAmount: Utils.parseTextToDouble(_additionalAmountController.text),
      contributionFrequency: _contributionFrequency,
      selectedTaxOption: _taxOptionManager.currentOption,  // Use manager's current option
      withdrawalPercentage: Utils.parseTextToDouble(_withdrawalPercentageController.text),
      breakPeriod: Utils.parseTextToInt(_breakController.text),
      withdrawalPeriod: Utils.parseTextToInt(_withdrawalDurationController.text),
    );
  }

  // Load preset values using the PresettingService
  void _loadPresetValues(String presetKey) {
    final presetValues = PresettingService.getPreset(presetKey);
    TaxOption? predefinedOption = _taxOptionManager.findOptionByDescription(presetValues['taxOption'] ?? 'None');
    _contributionFrequency = presetValues['contributionFrequency'] ?? 'Monthly';

    setState(() {
      _principalController.text = presetValues['principal'] ?? '5000';  // Default to 5000 if not provided
      _interestRateController.text = presetValues['interestRate'] ?? '7';  // Default to 7% if not provided
      _durationController.text = presetValues['duration'] ?? '25';  // Default to 25 years if not provided
      _additionalAmountController.text = presetValues['additionalAmount'] ?? '5000';  // Default to 5000 if not provided
      _breakController.text = presetValues['breakPeriod'] ?? '0';
      _withdrawalDurationController.text = presetValues['withdrawalPeriod'] ?? '30';
      _withdrawalPercentageController.text = presetValues['withdrawalPercentage'] ?? '4'; // Min 3% and Max 5%

      // Switch to the new predefined option and trigger a rebuild of SwitchAndTaxRate
      _taxOptionManager.switchToPredefined(predefinedOption ?? _taxOptions[0]);
      _presettingsController.text = presetKey;
    });

    _recalculateValues();
  }

  void _recalculateValues() {
    setState(() {
      _initializeInvestmentPlan();  // Initialize the investment plan with updated values
      _investmentPlan.calculateInvestment();  // Trigger calculations based on the current plan
      _depositYearlyValues = _investmentPlan.depositValues ?? [];
      _withdrawalYearlyValues = _investmentPlan.withdrawalValues ?? [];
    });
  }

  @override
  void dispose() {
    _tableTabController.dispose();
    _mainTabController.dispose();
    _principalController.dispose();
    _interestRateController.dispose();
    _durationController.dispose();
    _additionalAmountController.dispose();
    _withdrawalPercentageController.dispose();
    _breakController.dispose();
    _withdrawalDurationController.dispose();
    _presettingsController.dispose();
    _customTaxController.dispose();
    _tableTabController.dispose();
    _mainTabController.dispose();
    super.dispose();
  }

  // Toggle investment note visibility
  void toggleInvestmentNote() {
    setState(() {
      showInvestmentNote = !showInvestmentNote;
    });
  }

  Widget _buildFormulaWidget() {
    return FormulaWidget(
      principal: Utils.parseTextToDouble(_investmentPlan.depositPlan.principal.toString()),
      interestRate: Utils.parseTextToDouble(_investmentPlan.depositPlan.interestRate.toString()),
      duration: Utils.parseTextToDouble(_investmentPlan.depositPlan.duration.toString()),
      additionalAmount: Utils.parseTextToDouble(_additionalAmountController.text),
      contributionFrequency: _contributionFrequency,
    );
  }

  Widget _buildInvestmentNoteWidget() {
    double compoundEarningsOverDeposits = _investmentPlan.depositPlan.deposits != 0 ? (_investmentPlan.depositPlan.compoundEarnings / _investmentPlan.depositPlan.deposits * 100) : 0;

    return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: toggleInvestmentNote,  // Toggle the investment note
                child: const Text(
                  'Investment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' After ${_investmentPlan.depositPlan.duration} Years: ${_investmentPlan.depositPlan.totalValue.toStringAsFixed(0)} kr.-',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Text('Earnings compared to deposits: ${compoundEarningsOverDeposits.toStringAsFixed(2)}%'),
          // Investment note section
          InvestmentNoteWidget(
            showInvestmentNote: showInvestmentNote,
            investmentCompoundingResults: InvestmentCompoundingResults(
              totalDeposits: _investmentPlan.depositPlan.deposits,
              totalValue: _investmentPlan.depositPlan.totalValue,
              totalInterestFromPrincipal: _investmentPlan.depositPlan.totalInterestFromPrincipal,
              totalInterestFromContributions: _investmentPlan.depositPlan.totalInterestFromContributions,
              compoundEarnings: _investmentPlan.depositPlan.compoundEarnings,
              tax: _investmentPlan.depositPlan.totalTax,
            ),
          ),
        ],
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
          _buildInvestmentNoteWidget(),
          _buildSizedBox(20),
          _build4PercentWidget(),
          _buildTaxNoteWidget(),
          _buildTabView(),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return InputFieldsWidget(
      principalController: _principalController,
      interestRateController: _interestRateController,
      durationController: _durationController,
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

  Widget _buildSwitchTaxRateWidget() {
    return SwitchAndTaxRate(
      customTaxController: _customTaxController,
      recalculateValues: _recalculateValues, // Callback for recalculating
    );
  }

  Widget _build4PercentWidget() {
    return The4PercentWidget(
      withdrawalPercentageController: _withdrawalPercentageController,
      withdrawalYearlyAfterBreak: _investmentPlan.withdrawalPlan.withdrawalYearly,
      taxYearlyAfterBreak: _investmentPlan.withdrawalPlan.taxYearlyAfterBreak,
      recalculateValues: _recalculateValues,
      breakController: _breakController,
      interestGatheredDuringBreak: _investmentPlan.withdrawalPlan.interestGatheredDuringBreak,
      withdrawalDurationController: _withdrawalDurationController,
      taxController: _customTaxController,
      toggleSwitchWidget: _buildSwitchTaxRateWidget(),
      totalDeposits: _investmentPlan.depositPlan.deposits,
      totalValue: _investmentPlan.withdrawalPlan.earningsAfterBreak+ _investmentPlan.depositPlan.deposits,
      toggleTaxNote: () {
        setState(() {
          _showTaxNote = !_showTaxNote;
        });
      },
    );
  }

  Widget _buildTaxNoteWidget() {
    return TaxNoteWidget(
      showTaxNote: _showTaxNote,
      earningsWithdrawalRatio: TaxCalculationResults(
        earnings: _investmentPlan.withdrawalPlan.earningsAfterBreak,
        earningsPercent: _investmentPlan.withdrawalPlan.earningsPercentAfterBreak,
        taxableWithdrawal: _investmentPlan.withdrawalPlan.taxableWithdrawalYearlyAfterBreak,
        annualTax: _investmentPlan.withdrawalPlan.taxYearlyAfterBreak,
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
                yearlyValues: _depositYearlyValues,
                isDepositingTable: true,
                isWithdrawingTable: false,
              ),
              InvestmentTableWidget(
                yearlyValues: _withdrawalYearlyValues,
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
    return ChangeNotifierProvider(
      create: (context) => _taxOptionManager,
      child: Scaffold(
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
      ),
    );
  }
}
