import 'package:fire_app/models/tax_option.dart';

class DepositPlan {
  double principal;
  double interestRate;
  int duration;
  double additionalAmount;
  String contributionFrequency;
  TaxOption selectedTaxOption;
  double totalValue = 0;
  double deposits = 0;
  double compoundEarnings = 0;
  double tax = 0;

  DepositPlan({
    required this.principal,
    required this.interestRate,
    required this.duration,
    required this.additionalAmount,
    required this.contributionFrequency,
    required this.selectedTaxOption,
  });

  /// Main method to calculate yearly values including deposits, compounding, and tax
  List<Map<String, double>> calculateYearlyValues() {
    List<Map<String, double>> yearlyValues = [
      {
        'year': 0.0,
        'totalValue': principal,
        'totalDeposits': principal,
        'compoundEarnings': 0,
        'compoundThisYear': 0,
        'tax': 0,
      }
    ];

    totalValue = principal;
    deposits = principal;
    int contributionPeriods = _getContributionPeriods(); // Monthly or Yearly contributions

    for (int year = 1; year <= duration; year++) {
      double compoundThisYear = _calculateCompounding(contributionPeriods);
      
      // Handle tax directly in DepositPlan
      if (selectedTaxOption.isNotionallyTaxed) {
        tax = _calculateTaxOnEarnings(compoundThisYear);
        compoundThisYear -= tax;
      }

      totalValue += compoundThisYear;
      compoundEarnings += compoundThisYear;

      yearlyValues.add({
        'year': year.toDouble(),
        'totalValue': totalValue,
        'totalDeposits': deposits,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': compoundEarnings,
        'tax': tax,
      });
    }

    return yearlyValues;
  }

  /// Determines the number of contribution periods based on frequency
  int _getContributionPeriods() {
    return (contributionFrequency == 'Monthly') ? 12 : 1;
  }

  /// Calculates compounding for the year based on interest rate and contributions
  double _calculateCompounding(int contributionPeriods) {
    double compoundThisYear = totalValue * (interestRate / 100);
    for (int period = 1; period <= contributionPeriods; period++) {
      totalValue += additionalAmount;
      deposits += additionalAmount;

      int periodsLeft = contributionPeriods - period;
      compoundThisYear += additionalAmount * (interestRate / 100) * periodsLeft / contributionPeriods;
    }
    return compoundThisYear;
  }

  /// Calculates tax on earnings for the year based on the current tax option
  double _calculateTaxOnEarnings(double earnings) {
    double tax = 0;
    double taxableEarnings = earnings;

    if (selectedTaxOption.useTaxExemptionCardAndThreshold 
    && taxableEarnings <= TaxOption.threshold 
    && selectedTaxOption.ratePercentage > TaxOption.lowerTaxRate) {
      tax = taxableEarnings * TaxOption.lowerTaxRate / 100; // Apply lower tax rate for threshold
      taxableEarnings -= TaxOption.taxExemptionCard; // Apply exemption card
    } else {
      tax = taxableEarnings * selectedTaxOption.ratePercentage / 100; // Apply regular tax rate
    }

    if (taxableEarnings <= 0) return 0; // No tax if taxable earnings are negative or zero
    return tax;
  }
}
