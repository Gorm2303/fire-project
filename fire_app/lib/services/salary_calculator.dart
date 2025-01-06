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

    double salariesTotal = 0.0;
    double cumulativeTotalSalaryAfterTax = 0.0;
    double inflationAdjusted = 0.0;

    // Initial insertion for Year 0
    tableData.add(_createYearData(
      year: 0,
      salaryMonthly: 0,
      cumulativeSalary: 0,
      salariesTotalAfterTax: 0,
      inflationAdjusted: 0,
    ));

    graphDataAccumulatedAfterTax.add(const FlSpot(0, 0));
    graphDataAccumulated.add(const FlSpot(0, 0));
    graphDataInflationAdjusted.add(const FlSpot(0, 0));

    // Loop to calculate data for each year
    for (int year = 1; year <= duration; year++) {
      double salariesYearly = _calculateAccumulatedSalary(year);
      salariesTotal += salariesYearly;

      double taxYearly = salariesYearly * (taxRate / 100);
      double salaryAfterTax = salariesYearly - taxYearly;
      cumulativeTotalSalaryAfterTax += salaryAfterTax;
      inflationAdjusted += salaryAfterTax / pow(1 + inflationRate / 100, year);

      // Add yearly data to table and graph
      tableData.add(_createYearData(
        year: year,
        salaryMonthly: salariesYearly/12,
        cumulativeSalary: salariesTotal,
        salariesTotalAfterTax: cumulativeTotalSalaryAfterTax,
        inflationAdjusted: inflationAdjusted,
      ));

      graphDataAccumulated.add(FlSpot(year.toDouble(), salariesTotal.roundToDouble()));
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
  double _calculateAccumulatedSalary(int year) {
    double totalSalary = 0;
    for (Salary salary in salaries) {
      if (salary.isSelected) {
        totalSalary += salary.getTotalAmount(year);
      }
    }
    return totalSalary;
  }

  /// Creates a map for each year with formatted data for the table.
  Map<String, dynamic> _createYearData({
    required int year,
    required double salaryMonthly,
    required double cumulativeSalary,
    required double salariesTotalAfterTax,
    required double inflationAdjusted,
  }) {
    return {
      'year': year,
      'Salary (Monthly)': Utils.formatNumber(salaryMonthly),
      'Salary (Total)': Utils.formatNumber(cumulativeSalary),
      'After Tax': Utils.formatNumber(salariesTotalAfterTax),
      'Inflation Adjusted': Utils.formatNumber(inflationAdjusted),
    };
  }
}
