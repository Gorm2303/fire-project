import 'package:fire_app/models/tax_option.dart';
import 'package:fl_chart/fl_chart.dart';

class BreakPeriodPlan {
  double interestRate;
  int duration;
  TaxOption selectedTaxOption;
  double taxTotal = 0;
  double earnings = 0;
  double totalValue;
  List<Map<String, double>> yearlyValues = [];

  BreakPeriodPlan({
    required this.interestRate,
    required this.duration,
    required this.selectedTaxOption,
    required this.totalValue,
  });

  // Calculate yearly values for break period with and without contributions
  List<Map<String, double>> calculateYearlyValues(double valueBeforeBreakYears, double annualDeposit) {
    totalValue = valueBeforeBreakYears;
    double previousValue;
    double ifDepositsContinued = annualDeposit; // Track value if deposits continue

    if (duration >= 1) {
      yearlyValues.add({
        'year': 0,
        'totalValue': totalValue,
        'compoundThisYear': 0,
        'compoundEarnings': 0,
        'ifDepositsContinued': ifDepositsContinued,
      });

      for (int year = 1; year <= duration; year++) {
        // Growth without additional deposits
        previousValue = totalValue;
        totalValue *= (1 + interestRate / 100);
        double compoundThisYear = totalValue - previousValue;

        // Growth with continued deposits
        ifDepositsContinued += annualDeposit;
        double previousValueWithDeposits = ifDepositsContinued;
        ifDepositsContinued *= (1 + interestRate / 100);
        double compoundWithDeposits = ifDepositsContinued - previousValueWithDeposits;

        if (selectedTaxOption.isNotionallyTaxed) {
          // Apply tax for break growth
          double taxThisYear = _notionalGainsTax(compoundThisYear);
          totalValue -= taxThisYear;
          taxTotal += taxThisYear;
          compoundThisYear -= taxThisYear;

          // Apply tax for growth with deposits
          double taxWithDeposits = _notionalGainsTax(compoundWithDeposits);
          ifDepositsContinued -= taxWithDeposits;
        }

        earnings += compoundThisYear;
        ifDepositsContinued += compoundThisYear;

        yearlyValues.add({
          'year': year.toDouble(),
          'totalValue': totalValue,
          'compoundThisYear': compoundThisYear,
          'compoundEarnings': earnings,
          'ifDepositsContinued': ifDepositsContinued,
        });
      }
    }
    return yearlyValues;
  }

  // Helper function to apply notional gains tax
  double _notionalGainsTax(double earnings) {
    if (selectedTaxOption.useTaxExemptionCard) {
      earnings -= TaxOption.taxExemptionCard;
    }

    if (selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate || !selectedTaxOption.useTaxProgressionLimit) {
      return earnings < 0 ? 0 : earnings * selectedTaxOption.ratePercentage / 100;
    }

    if (earnings <= TaxOption.taxProgressionLimit) {
      return earnings < 0 ? 0 : earnings * TaxOption.lowerTaxRate / 100;
    } else {
      return earnings < 0
          ? 0
          : (TaxOption.taxProgressionLimit * TaxOption.lowerTaxRate / 100) +
              ((earnings - TaxOption.taxProgressionLimit) * selectedTaxOption.ratePercentage / 100);
    }
  }

}
