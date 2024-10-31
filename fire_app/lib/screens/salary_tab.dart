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
import 'dart:math';

class SalaryTab extends StatefulWidget {
  final double maxWidth;
  const SalaryTab({super.key, required this.maxWidth});

  @override
  _SalaryTabState createState() => _SalaryTabState();
}

class _SalaryTabState extends State<SalaryTab> with TickerProviderStateMixin {
  late TabController _tableTabController;

  final TextEditingController _monthlySalaryController = TextEditingController(text: '40000');
  final TextEditingController _raiseYearlyController = TextEditingController(text: '2');
  final TextEditingController _taxRateController = TextEditingController(text: '40');
  final TextEditingController _durationController = TextEditingController(text: '40');
  final TextEditingController _inflationRateController = TextEditingController(text: '2');

  final List<Salary> _salaries = [];
  List<Map<String, dynamic>> _tableData = [];
  List<FlSpot> _graphDataAccumulated = [];
  List<FlSpot> _graphDataAccumulatedAfterTax = [];
  List<FlSpot> _graphDataInflationAdjusted = [];
  List<double> accumulatedAfterTaxAndInflation = [];

  @override
  void initState() {
    super.initState();

    _tableTabController = TabController(length: 1, vsync: this);
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
      amount: monthlySalary, 
      raiseYearlyPercentage: yearlyRaise
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
      _graphDataAccumulated = results['graphDataTotalValue'];
      _graphDataAccumulatedAfterTax = results['graphDataTotalExpenses'];
      _graphDataInflationAdjusted = results['graphDataInflationAdjusted'];
    });
  }

  @override
  Widget build(BuildContext context) {
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
                }, removeSalaryCallback: (integer) { 
                  setState(() {
                    _salaries.removeAt(integer);
                  });
                  _calculateTableData();
                },
              ),
              AdditionalInputs(
                taxRateController: _taxRateController,
                durationController: _durationController,
                inflationRateController: _inflationRateController,
                onParameterChanged: _calculateTableData,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SalaryChart(
          graphDataAccumulated: _graphDataAccumulated,
          graphDataAccumulatedAfterTax: _graphDataAccumulatedAfterTax,
          graphDataInflationAdjusted: _graphDataInflationAdjusted,
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
}
