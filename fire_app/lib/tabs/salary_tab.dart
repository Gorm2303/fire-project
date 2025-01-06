import 'package:fire_app/models/salary.dart';
import 'package:fire_app/services/salary_calculator.dart';
import 'package:fire_app/widgets/salary_widgets/additional_inputs.dart';
import 'package:fire_app/widgets/salary_widgets/chart_widget.dart';
import 'package:fire_app/widgets/salary_widgets/list_widget.dart';
import 'package:fire_app/widgets/salary_widgets/salary_input_fields.dart';
import 'package:fire_app/widgets/salary_widgets/table_widget.dart';
import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalaryTab extends StatefulWidget {
  final double maxWidth;
  const SalaryTab({super.key, required this.maxWidth});

  @override
  _SalaryTabState createState() => _SalaryTabState();
}

class _SalaryTabState extends State<SalaryTab> with TickerProviderStateMixin {
  late TabController _tableTabController;
  bool _isDataLoaded = false; // Flag to check if data has been loaded

  final TextEditingController _monthlySalaryController = TextEditingController(text: '40000');
  final TextEditingController _raiseYearlyController = TextEditingController(text: '2');
  final TextEditingController _taxRateController = TextEditingController(text: '40');
  final TextEditingController _durationController = TextEditingController(text: '40');
  final TextEditingController _inflationRateController = TextEditingController(text: '2');

  final List<Salary> _salaries = [];
  List<Map<String, dynamic>> _tableData = [];
  List<FlSpot> _graphDataAccumulated = [];
  List<FlSpot> _graphDataAccumulatedAfterTax = [];
  List<FlSpot> _graphDataAccumulatedAfterTaxNoRaise = [];
  List<FlSpot> _graphDataInflationAdjusted = [];
  List<FlSpot> _graphDataInflationAdjustedNoRaise = [];

  @override
  void initState() {
    super.initState();
    _tableTabController = TabController(length: 1, vsync: this);
    _loadData(); // Load data on startup
  }

  // Save salary and input data
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('monthlySalary', _monthlySalaryController.text);
    await prefs.setString('raiseYearly', _raiseYearlyController.text);
    await prefs.setString('taxRate', _taxRateController.text);
    await prefs.setString('duration', _durationController.text);
    await prefs.setString('inflationRate', _inflationRateController.text);

    // Save salaries as a JSON-like string
    List<String> salaryList = _salaries.map((salary) => '${salary.amountMonthly},${salary.raiseYearlyPercentage},${salary.isSelected}').toList();
    await prefs.setStringList('salaries', salaryList);
  }

  @override
  void didUpdateWidget(covariant SalaryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadDataAndRecalculate(); // Load data and recalculate when switching back to this tab
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlySalaryController.text = prefs.getString('monthlySalary') ?? '40000';
      _raiseYearlyController.text = prefs.getString('raiseYearly') ?? '2';
      _taxRateController.text = prefs.getString('taxRate') ?? '40';
      _durationController.text = prefs.getString('duration') ?? '40';
      _inflationRateController.text = prefs.getString('inflationRate') ?? '2';

      // Load salaries
      final savedSalaries = prefs.getStringList('salaries') ?? [];
      _salaries.clear();
      for (String salaryString in savedSalaries) {
        final parts = salaryString.split(',');
        if (parts.length == 3) {
          final amount = double.tryParse(parts[0]) ?? 0.0;
          final raise = double.tryParse(parts[1]) ?? 0.0;
          final isSelected = parts[2] == 'true';
          _salaries.add(Salary(amountMonthly: amount, raiseYearlyPercentage: raise, isSelected: isSelected));
        }
      }
    });
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  _calculateTableData(); // Recalculate data when switching back to this tab
}

  @override
  void dispose() {
    _tableTabController.dispose();
    super.dispose();
  }

  void addSalary() {
    final monthlySalary = double.tryParse(_monthlySalaryController.text) ?? 0;
    final yearlyRaise = double.tryParse(_raiseYearlyController.text) ?? 0;

    Salary salary = Salary(
      amountMonthly: monthlySalary,
      raiseYearlyPercentage: yearlyRaise,
    );
    setState(() {
      _salaries.add(salary);
    });

    _calculateTableData();
  }

  void _calculateTableData() {
    SalaryCalculator calculator = SalaryCalculator(
      salaries: _salaries,
      raiseYearlyPercentage: double.tryParse(_raiseYearlyController.text) ?? 0,
      inflationRate: double.tryParse(_inflationRateController.text) ?? 0,
      duration: int.tryParse(_durationController.text) ?? 50,
      taxRate: double.tryParse(_taxRateController.text) ?? 0,
    );

    final results = calculator.calculate();

    setState(() {
      _tableData = results['tableData'];
      _graphDataAccumulated = results['graphDataAccumulated'];
      _graphDataAccumulatedAfterTax = results['graphDataAccumulatedAfterTax'];
      _graphDataAccumulatedAfterTaxNoRaise = results['graphDataAccumulatedAfterTaxNoRaise'];
      _graphDataInflationAdjusted = results['graphDataInflationAdjusted'];
      _graphDataInflationAdjustedNoRaise = results['graphDataInflationAdjustedNoRaise'];
    });

    _saveData(); // Save data after calculations
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoaded) {
      _loadDataAndRecalculate(); // Load data and calculate once when tab is shown
      _isDataLoaded = true; // Set the flag to true after loading
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.maxWidth,
          child: CardWrapper(
            title: 'Salary Information',
            darkColor: Colors.green.shade900,
            lightColor: Colors.green.shade100,
            contentPadding: MediaQuery.of(context).size.width > widget.maxWidth
                ? const EdgeInsetsDirectional.symmetric(horizontal: 100, vertical: 0)
                : MediaQuery.of(context).size.width > widget.maxWidth - 100
                    ? const EdgeInsetsDirectional.symmetric(horizontal: 75, vertical: 0)
                    : MediaQuery.of(context).size.width > widget.maxWidth - 200
                        ? const EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 0)
                        : const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 0),
            children: [
              SalaryInputField(
                controller: _monthlySalaryController,
                yearlyRaiseController: _raiseYearlyController,
                addSalaryCallback: addSalary,
              ),
              SalaryList(
                salaries: _salaries,
                toggleSalaryCallback: (index) {
                  setState(() {
                    _salaries[index].toggleSelection();
                  });
                  _calculateTableData();
                  _saveData();
                },
                removeSalaryCallback: (index) {
                  setState(() {
                    _salaries.removeAt(index);
                  });
                  _calculateTableData();
                  _saveData();
                },
              ),
              AdditionalInputs(
                taxRateController: _taxRateController,
                durationController: _durationController,
                inflationRateController: _inflationRateController,
                onParameterChanged: () {
                  _calculateTableData();
                  _saveData();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SalaryChart(
          graphDataAccumulated: _graphDataAccumulated,
          graphDataAccumulatedAfterTax: _graphDataAccumulatedAfterTax,
          graphDataAfterTaxNoRaise: _graphDataAccumulatedAfterTaxNoRaise,
          graphDataInflationAdjusted: _graphDataInflationAdjusted,
          graphDataNoRaise: _graphDataInflationAdjustedNoRaise,
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tableTabController,
          tabs: const [
            Tab(text: 'Salaries'),
          ],
        ),
        SizedBox(
          height: 475,
          child: TabBarView(
            controller: _tableTabController,
            children: [
              SalaryTable(
                tableData: _tableData,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadDataAndRecalculate() async {
    await _loadData();
    _calculateTableData();
  }
}