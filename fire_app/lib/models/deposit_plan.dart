import 'dart:math';

import 'package:fire_app/models/tax_option.dart';

class DepositPlan {
  double principal;
  double interestRate;
  int duration;
  double additionalContribution;
  String contributionFrequency;
  TaxOption selectedTaxOption;
  double totalValue = 0;
  double deposits = 0;
  double compoundEarnings = 0;
  double tax = 0;
  double totalInterestFromPrincipal = 0;
  double totalInterestFromContributions = 0;

  DepositPlan({
    required this.principal,
    required this.interestRate,
    required this.duration,
    required this.additionalContribution,
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
      double compoundThisYear = calculateInterest(contributionPeriods);
      
      // Handle tax directly in DepositPlan
      if (selectedTaxOption.isNotionallyTaxed) {
        tax = calculateTaxOnEarnings(compoundThisYear);
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
    calculateTotalInterest();

    return yearlyValues;
  }

  /// Determines the number of contribution periods based on frequency
  int _getContributionPeriods() {
    return (contributionFrequency == 'Monthly') ? 12 : 1;
  }

  /// Calculates compounding for the year based on interest rate and contributions
  double calculateInterest(int contributionPeriods) {
    if (totalValue == 0) { // Ensure totalValue is initialized
      totalValue = principal;
    }

    double compoundThisYear = totalValue * (interestRate / 100); // Compounding on the current total value

    // Now handle contributions and their compounding
    for (int period = 1; period <= contributionPeriods; period++) {
      totalValue += additionalContribution; // Add contributions
      deposits += additionalContribution;

      int periodsLeft = contributionPeriods - period;
      compoundThisYear += additionalContribution * (interestRate / 100) * periodsLeft / contributionPeriods; // Compound contributions for remaining periods
    }

    return compoundThisYear;
  }

  /// Calculates tax on earnings for the year based on the current tax option
  double calculateTaxOnEarnings(double earnings) {
    if (earnings <= 0) return 0;

    if (!selectedTaxOption.useTaxExemptionCardAndThreshold) {
      tax = earnings * selectedTaxOption.ratePercentage / 100;
      return tax < 0 ? 0 : tax;
    }

    double taxableEarnings = earnings - TaxOption.taxExemptionCard;
    if (selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate) {
      tax = earnings * selectedTaxOption.ratePercentage / 100;
      return tax < 0 ? 0 : tax;
    }
    
    if (taxableEarnings <= TaxOption.threshold) {
      tax = taxableEarnings * TaxOption.lowerTaxRate / 100; // Apply lower tax rate for threshold
      return tax < 0 ? 0 : tax;
    } else {
      tax = (TaxOption.threshold * TaxOption.lowerTaxRate / 100) + ((taxableEarnings - TaxOption.threshold) * selectedTaxOption.ratePercentage / 100);
      return tax < 0 ? 0 : tax;
    }
  }

  /// Calculates the total interest from principal and contributions
  void calculateTotalInterest() {
    totalInterestFromPrincipal = principal * pow(1 +(interestRate / 100), duration) - principal;
    totalInterestFromContributions = totalValue - deposits - totalInterestFromPrincipal;

    double taxOnPrincipalInterest = 0;
    if (compoundEarnings != 0) {
      taxOnPrincipalInterest = totalInterestFromPrincipal / compoundEarnings * tax;
    }

    totalInterestFromPrincipal -= taxOnPrincipalInterest;
    totalInterestFromContributions += taxOnPrincipalInterest;
  }
}
