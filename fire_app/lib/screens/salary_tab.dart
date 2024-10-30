import 'package:fire_app/models/salary.dart';
import 'package:fire_app/widgets/salary_widgets/additional_inputs.dart';
import 'package:fire_app/widgets/salary_widgets/chart_widget.dart';
import 'package:fire_app/widgets/salary_widgets/list_widget.dart';
import 'package:fire_app/widgets/salary_widgets/salary_input_fields.dart';
import 'package:fire_app/widgets/salary_widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class SalaryTab extends StatefulWidget {
  const SalaryTab({Key? key}) : super(key: key);

  @override
  _SalaryTabState createState() => _SalaryTabState();
}

class _SalaryTabState extends State<SalaryTab> {
  final TextEditingController monthlySalaryController = TextEditingController(text: '40000');
  final TextEditingController yearlyRaiseController = TextEditingController(text: '2');
  final TextEditingController taxRateController = TextEditingController(text: '40');
  final TextEditingController durationController = TextEditingController(text: '40');
  final TextEditingController inflationRateController = TextEditingController(text: '2');

  final List<Salary> _salaries = [];
  List<double> accumulatedAfterTaxAndInflation = [];

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

    double totalAfterTaxAndInflation = 0;
    accumulatedAfterTaxAndInflation = List<double>.filled(duration + 1, 0);

    for (int year = 1; year <= duration; year++) {
      for (Salary salary in _salaries) {
        if (!salary.isSelected) {
          continue;
        }
          
        double initialYearlySalary = salary.amount * 12;
        double raise = salary.raiseYearlyPercentage;

        double annualSalary = initialYearlySalary * pow(1 + raise / 100, year);
        double afterTax = annualSalary * (1 - taxRate);
        double adjustedForInflation = afterTax / pow(1 + inflationRate, year);

        totalAfterTaxAndInflation += adjustedForInflation;
        accumulatedAfterTaxAndInflation[year] += totalAfterTaxAndInflation;
      }
    }

    return accumulatedAfterTaxAndInflation;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SalaryInputField(
            controller: monthlySalaryController,
            yearlyRaiseController: yearlyRaiseController,
            addSalaryCallback: addSalary,
          ),
          AdditionalInputs(
            taxRateController: taxRateController,
            durationController: durationController,
            inflationRateController: inflationRateController,
          ),
          const SizedBox(height: 16),
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
          SalaryChart(
            accumulatedSalaries: calculateAccumulatedSalaries(),
          ),
          const SizedBox(height: 16),
          SalaryTable(
            duration: int.tryParse(durationController.text) ?? 0,
            accumulatedSalaries: calculateAccumulatedSalaries(),
          ),
        ],
      ),
    );
  }
}
