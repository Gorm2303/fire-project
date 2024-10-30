import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:fire_app/models/expense.dart';
import 'package:fire_app/services/utils.dart';

class ExpenseCalculator {
  final List<Expense> expenses;
  final double interestRate;
  final double inflationRate;
  final int duration;

  ExpenseCalculator({
    required this.expenses,
    required this.interestRate,
    required this.inflationRate,
    required this.duration,
  });

  /// Calculates table and graph data for expenses, interest, and inflation adjustments over the years.
  Map<String, dynamic> calculate() {
    List<Map<String, dynamic>> tableData = [];
    List<FlSpot> graphDataTotalValue = [];
    List<FlSpot> graphDataTotalExpenses = [];
    List<FlSpot> graphDataInflationAdjusted = [];

    double cumulativeTotalValue = 0.0;
    double cumulativeTotalExpenses = 0.0;
    double cumulativeTotalInterest = 0.0;

    // Initial calculation for Year 0
    double year0Expenses = _calculateYearlyExpenses(0);
    tableData.add(_createYearData(
      year: 0,
      totalExpenses: year0Expenses,
      yearlyInterest: 0.0,
      totalInterest: 0.0,
      totalValue: year0Expenses,
      inflationAdjusted: year0Expenses,
    ));

    graphDataTotalExpenses.add(FlSpot(0, year0Expenses));
    graphDataTotalValue.add(FlSpot(0, year0Expenses));
    graphDataInflationAdjusted.add(FlSpot(0, year0Expenses));

    cumulativeTotalExpenses += year0Expenses;
    cumulativeTotalValue += year0Expenses;

    // Loop to calculate data for each year
    for (int year = 1; year <= duration; year++) {
      double totalExpenses = _calculateYearlyExpenses(year);
      double yearlyInterest = cumulativeTotalValue * (interestRate / 100);
      cumulativeTotalInterest += yearlyInterest;

      // Update cumulative totals
      cumulativeTotalExpenses += totalExpenses;
      cumulativeTotalValue += totalExpenses + yearlyInterest;

      double inflationAdjustedValue = cumulativeTotalValue / pow(1 + (inflationRate / 100), year);

      // Add yearly data to table and graph
      tableData.add(_createYearData(
        year: year,
        totalExpenses: cumulativeTotalExpenses,
        yearlyInterest: yearlyInterest,
        totalInterest: cumulativeTotalInterest,
        totalValue: cumulativeTotalValue,
        inflationAdjusted: inflationAdjustedValue,
      ));

      graphDataTotalExpenses.add(FlSpot(year.toDouble(), cumulativeTotalExpenses.roundToDouble()));
      graphDataTotalValue.add(FlSpot(year.toDouble(), cumulativeTotalValue.roundToDouble()));
      graphDataInflationAdjusted.add(FlSpot(year.toDouble(), inflationAdjustedValue.roundToDouble()));
    }

    return {
      'tableData': tableData,
      'graphDataTotalExpenses': graphDataTotalExpenses,
      'graphDataTotalValue': graphDataTotalValue,
      'graphDataInflationAdjusted': graphDataInflationAdjusted,
    };
  }

  /// Calculates the total expenses for a given year, considering each expense's frequency.
  double _calculateYearlyExpenses(int year) {
    double totalExpenses = 0;
    for (Expense expense in expenses) {
      if (expense.isSelected) {
        totalExpenses += expense.getYearlyAmount(year);
      }
    }
    return totalExpenses;
  }

  /// Creates a map for each year with formatted data for the table.
  Map<String, dynamic> _createYearData({
    required int year,
    required double totalExpenses,
    required double yearlyInterest,
    required double totalInterest,
    required double totalValue,
    required double inflationAdjusted,
  }) {
    return {
      'year': year,
      'Total Expenses': Utils.formatNumber(totalExpenses),
      'Interest (Yearly)': Utils.formatNumber(yearlyInterest),
      'Interest (Total)': Utils.formatNumber(totalInterest),
      'Total Value': Utils.formatNumber(totalValue),
      'Inflation Adjusted': Utils.formatNumber(inflationAdjusted),
    };
  }
}
