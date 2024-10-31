import 'dart:math';
import 'package:fire_app/models/salary.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fire_app/services/utils.dart';

class SalaryCalculator {
  final List<Salary> salaries;
  final double raiseYearlyPercentage;
  final double inflationRate;
  final int duration;
  final double taxRate;

  SalaryCalculator({
    required this.salaries,
    required this.raiseYearlyPercentage,
    required this.inflationRate,
    required this.duration,
    required this.taxRate,
  });

  /// Calculates table and graph data for expenses, interest, and inflation adjustments over the years.
  Map<String, dynamic> calculate() {
    List<Map<String, dynamic>> tableData = [];
    List<FlSpot> graphDataAccumulated = [];
    List<FlSpot> graphDataAccumulatedAfterTax = [];
    List<FlSpot> graphDataInflationAdjusted = [];

    double cumulativeTotalSalary = 0.0;
    double cumulativeTotalSalaryAfterTax = 0.0;
    double taxYearly = 0.0;

    // Initial insertion for Year 0
    tableData.add(_createYearData(
      year: 0,
      salaryMonthly: 0,
      cumulativeSalary: 0,
      cumulativeTotalSalaryAfterTax: 0,
      inflationAdjusted: 0,
    ));

    graphDataAccumulatedAfterTax.add(const FlSpot(0, 0));
    graphDataAccumulated.add(const FlSpot(0, 0));
    graphDataInflationAdjusted.add(const FlSpot(0, 0));

    // Loop to calculate data for each year
    for (int year = 1; year <= duration; year++) {
      double totalSalaries = _calculateYearlyAccumulatedSalary(year);

      cumulativeTotalSalary += totalSalaries * 12;
      taxYearly = totalSalaries * (taxRate / 100);
      cumulativeTotalSalaryAfterTax += (totalSalaries - taxYearly) * 12;
      double inflationAdjusted = cumulativeTotalSalaryAfterTax / pow(1 + (inflationRate / 100), year);

      // Add yearly data to table and graph
      tableData.add(_createYearData(
        year: year,
        salaryMonthly: totalSalaries,
        cumulativeSalary: cumulativeTotalSalary,
        cumulativeTotalSalaryAfterTax: cumulativeTotalSalaryAfterTax,
        inflationAdjusted: inflationAdjusted,
      ));

      graphDataAccumulated.add(FlSpot(year.toDouble(), cumulativeTotalSalary.roundToDouble()));
      graphDataAccumulatedAfterTax.add(FlSpot(year.toDouble(), cumulativeTotalSalaryAfterTax.roundToDouble()));
      graphDataInflationAdjusted.add(FlSpot(year.toDouble(), inflationAdjusted.roundToDouble()));
    }

    return {
      'tableData': tableData,
      'graphDataAccumulated': graphDataAccumulated,
      'graphDataAccumulatedAfterTax': graphDataAccumulatedAfterTax,
      'graphDataInflationAdjusted': graphDataInflationAdjusted,
    };
  }

  /// Calculates the total expenses for a given year, considering each expense's frequency.
  double _calculateYearlyAccumulatedSalary(int year) {
    double totalSalary = 0;
    for (Salary salary in salaries) {
      if (salary.isSelected) {
        totalSalary += salary.getYearlyAmount(year);
      }
    }
    return totalSalary;
  }

  /// Creates a map for each year with formatted data for the table.
  Map<String, dynamic> _createYearData({
    required int year,
    required double salaryMonthly,
    required double cumulativeSalary,
    required double cumulativeTotalSalaryAfterTax,
    required double inflationAdjusted,
  }) {
    return {
      'year': year,
      'Salary (Monthly)': Utils.formatNumber(salaryMonthly),
      'Salary (Total)': Utils.formatNumber(cumulativeSalary),
      'After Tax': Utils.formatNumber(cumulativeTotalSalaryAfterTax),
      'Inflation Adjusted': Utils.formatNumber(inflationAdjusted),
    };
  }
}
