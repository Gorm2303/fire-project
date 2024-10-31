import 'package:fire_app/models/salary.dart';
import 'package:fire_app/widgets/salary_widgets/additional_inputs.dart';
import 'package:fire_app/widgets/salary_widgets/chart_widget.dart';
import 'package:fire_app/widgets/salary_widgets/list_widget.dart';
import 'package:fire_app/widgets/salary_widgets/salary_input_fields.dart';
import 'package:fire_app/widgets/salary_widgets/table_widget.dart';
import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
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

  final TextEditingController monthlySalaryController = TextEditingController(text: '40000');
  final TextEditingController yearlyRaiseController = TextEditingController(text: '2');
  final TextEditingController taxRateController = TextEditingController(text: '40');
  final TextEditingController durationController = TextEditingController(text: '40');
  final TextEditingController inflationRateController = TextEditingController(text: '2');

  final List<Salary> _salaries = [];
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
    final monthlySalary = double.tryParse(monthlySalaryController.text) ?? 0;
    final yearlyRaise = double.tryParse(yearlyRaiseController.text) ?? 0;

    Salary salary = Salary(
      amount: monthlySalary, 
      raiseYearlyPercentage: yearlyRaise
    );
      setState(() {
        _salaries.add(salary);
      });

    calculateAccumulatedSalaries();
  }

  List<double> calculateAccumulatedSalaries() {
    double taxRate = (double.tryParse(taxRateController.text) ?? 0) / 100;
    double inflationRate = (double.tryParse(inflationRateController.text) ?? 0) / 100;
    int duration = int.tryParse(durationController.text) ?? 0;

    // Initialize the accumulated list with zero for each year
    accumulatedAfterTaxAndInflation = List<double>.filled(duration + 1, 0);

    for (Salary salary in _salaries) {
      if (!salary.isSelected) {
        continue;
      }

      double yearlySalary = salary.amount * 12;

      for (int year = 1; year <= duration; year++) {
        // Apply the raise for the current year
        double raise = salary.raiseYearlyPercentage;
        yearlySalary *= (1 + raise / 100); // Compounded salary with the raise

        // Calculate the after-tax amount for this year's salary
        double afterTax = yearlySalary * (1 - taxRate);

        // Adjust this year's after-tax salary for inflation
        double adjustedForInflation = afterTax / pow(1 + inflationRate, year);

        // Add this year's adjusted salary to the accumulated total for this year
        accumulatedAfterTaxAndInflation[year] += accumulatedAfterTaxAndInflation[year - 1] + adjustedForInflation;
      }
    }

    return accumulatedAfterTaxAndInflation;
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
            contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 100, vertical: 0),
            children: [
              SalaryInputField(
                controller: monthlySalaryController,
                yearlyRaiseController: yearlyRaiseController,
                addSalaryCallback: addSalary,
              ),
              SalaryList(
                salaries: _salaries,
                toggleSalaryCallback: (index) {
                  setState(() {
                    _salaries[index].toggleSelection();
                  });
                }, removeSalaryCallback: (integer) { 
                  setState(() {
                    _salaries.removeAt(integer);
                  });
                },
              ),
              const SizedBox(height: 16),
              AdditionalInputs(
                taxRateController: taxRateController,
                durationController: durationController,
                inflationRateController: inflationRateController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SalaryChart(
          accumulatedSalaries: calculateAccumulatedSalaries(),
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
                duration: int.tryParse(durationController.text) ?? 0,
                accumulatedSalaries: calculateAccumulatedSalaries(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
