import 'package:fire_app/models/tax_option.dart';
import 'package:fire_app/widgets/investment_widgets/investment_calculation_widget.dart';
import 'package:fire_app/widgets/investment_widgets/break_period_widget.dart';
import 'package:fire_app/widgets/investment_widgets/investment_note_widget.dart';
import 'package:fire_app/widgets/withdrawal_tax_widgets/withdrawal_widget.dart';
import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tax_option_manager.dart';
import '../widgets/investment_widgets/formula_widget.dart';
import '../widgets/withdrawal_tax_widgets/tax_note_widget.dart';
import '../models/investment_plan.dart';
import '../widgets/investment_table_widget.dart';
import '../widgets/investment_widgets/input_fields_widget.dart';
import '../widgets/tab_dropdown_widget.dart';
import '../widgets/withdrawal_tax_widgets/tax_calculation_results_widget.dart';
import '../widgets/withdrawal_tax_widgets/tax_rate_widget.dart';
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
    _createInvestmentPlan();  // Call this during initialization to ensure it's set up

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

  InvestmentPlan _createInvestmentPlan() {
    return _investmentPlan = InvestmentPlan(
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
      _createInvestmentPlan();  // Initialize the investment plan with updated values
      _investmentPlan.calculateInvestment();  // Trigger calculations based on the current plan
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

  Widget _buildInvestmentCalculationWidget() {
    return InvestmentCalculationWidget(
      showInvestmentNote: showInvestmentNote, 
      totalDeposits: _investmentPlan.depositPlan.deposits, 
      totalValue: _investmentPlan.depositPlan.totalValue, 
      totalInterestFromPrincipal: _investmentPlan.depositPlan.totalInterestFromPrincipal, 
      totalInterestFromContributions: _investmentPlan.depositPlan.totalInterestFromContributions, 
      compoundEarnings: _investmentPlan.depositPlan.compoundEarnings, 
      tax: _investmentPlan.depositPlan.totalTax, 
      duration: _investmentPlan.depositPlan.duration, 
      toggleInvestmentNote: toggleInvestmentNote,
      formulaWidget: FormulaWidget(
        principal: Utils.parseTextToDouble(_investmentPlan.depositPlan.principal.toString()),
        interestRate: Utils.parseTextToDouble(_investmentPlan.depositPlan.interestRate.toString()),
        duration: Utils.parseTextToDouble(_investmentPlan.depositPlan.duration.toString()),
        additionalAmount: Utils.parseTextToDouble(_additionalAmountController.text),
        contributionFrequency: _contributionFrequency,
      ),
    );
  }

  Widget investmentCalculatorContent() {
    double width = 520;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            width: width,
            child: Column(
              children: [
                _buildInputFields(),
                _buildInvestmentCalculationWidget(),
              ],
            ),
          ),
          showInvestmentNote ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CardWrapper(
            title: 'Investment Note', 
            children: [_buildInvestmentNoteWidget()]
            )
          ) : Container(),
          SizedBox(
            width: width,
            child: Column(
              children: <Widget>[
                _buildBreakPeriodWidget(),
                _buildTaxRateWidget(),
                _buildWithdrawalWidget(),
              ],
            ), 
          ),
          _showTaxNote ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CardWrapper(
            title: 'Tax Note', 
            children: [_buildTaxNoteWidget()]
            )
          ) : Container(),
          _buildTabView(),
        ],
      ),
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

  Widget _buildInvestmentNoteWidget() {
    return InvestmentNoteWidget(
      totalDeposits: _investmentPlan.depositPlan.deposits,
      totalValue: _investmentPlan.depositPlan.totalValue,
      totalInterestFromPrincipal: _investmentPlan.depositPlan.totalInterestFromPrincipal,
      totalInterestFromContributions: _investmentPlan.depositPlan.totalInterestFromContributions,
      compoundEarnings: _investmentPlan.depositPlan.compoundEarnings,
      tax: _investmentPlan.depositPlan.totalTax,
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

  Widget _buildBreakPeriodWidget() {
    return BreakPeriodWidget(
      breakController: _breakController,
      interestGatheredDuringBreak: _investmentPlan.withdrawalPlan.interestGatheredDuringBreak,
      totalDeposits: _investmentPlan.depositPlan.deposits,
      totalValue: _investmentPlan.withdrawalPlan.earningsAfterBreak + _investmentPlan.depositPlan.deposits,
      recalculateValues: _recalculateValues,
    );
  }

  Widget _buildTaxRateWidget() {
    return TaxRateWidget(
      customTaxController: _customTaxController,
      recalculateValues: _recalculateValues, // Callback for recalculating
    );
  }

  Widget _buildWithdrawalWidget() {
    return WithdrawalWidget(
        withdrawalPercentageController: _withdrawalPercentageController,
        withdrawalYearlyAfterBreak: _investmentPlan.withdrawalPlan.withdrawalYearly,
        taxYearlyAfterBreak: _investmentPlan.withdrawalPlan.taxYearlyAfterBreak,
        recalculateValues: _recalculateValues,
        toggleTaxNote: () {
          setState(() {
            _showTaxNote = !_showTaxNote;
          });
        },
        withdrawalDurationController: _withdrawalDurationController,
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
                yearlyValues: _investmentPlan.depositPlan.yearlyValues,
                isDepositingTable: true,
                isWithdrawingTable: false,
              ),
              InvestmentTableWidget(
                yearlyValues: _investmentPlan.withdrawalPlan.yearlyValues,
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
