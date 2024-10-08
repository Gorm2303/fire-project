
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
  double totalTax = 0;
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
      double tax = 0;

      // Handle tax directly in DepositPlan
      if (selectedTaxOption.isNotionallyTaxed) {
        totalTax += tax = calculateTaxOnEarnings(compoundThisYear);
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
    double tax = 0;

    if (!selectedTaxOption.useTaxExemptionCardAndThreshold) {
      tax = earnings * selectedTaxOption.ratePercentage / 100;
      return tax < 0 ? 0 : tax;
    }

    double taxableEarnings = earnings - TaxOption.taxExemptionCard;

    if (taxableEarnings <= 0) {
      return 0; // No tax if taxable earnings are below or equal to 0
    }

    if (selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate) {
      tax = taxableEarnings * selectedTaxOption.ratePercentage / 100;
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

  /// Calculates the total interest from principal and contributions, and applies tax on each part
  void calculateTotalInterest() {
  totalInterestFromPrincipal = 0;
  totalInterestFromContributions = 0;

  double previousPrincipalInterest = 0;
  double previousContributionInterest = 0;

  double contributions = 0;
  int contributionPeriods = _getContributionPeriods();

  for (int year = 1; year <= duration; year++) {
    // Calculate principal interest
    double principalInterest = (principal + previousPrincipalInterest) * (interestRate / 100);
    totalInterestFromPrincipal += principalInterest;

    // Calculate contribution interest
    double contributionsInterest = (previousContributionInterest + contributions) * (interestRate / 100);
    
    // Handle contributions compounding
    for (int period = 1; period <= contributionPeriods; period++) {
      contributions += additionalContribution; // Add contributions
      int periodsLeft = contributionPeriods - period;
      contributionsInterest += additionalContribution * (interestRate / 100) * periodsLeft / contributionPeriods;
    }

    totalInterestFromContributions += contributionsInterest;

    // Apply tax if notionally taxed
    if (selectedTaxOption.isNotionallyTaxed) {
      // Step 1: Calculate total taxable earnings (principal + contributions)
      double totalEarnings = principalInterest + contributionsInterest;

      // Step 2: Apply the tax calculation on total earnings
      double totalTax = calculateTaxOnEarnings(totalEarnings);

      // Step 3: Calculate the ratio of principal to total earnings and contributions to total earnings
      double principalRatio = (principalInterest / totalEarnings).clamp(0, 1);
      double contributionRatio = (contributionsInterest / totalEarnings).clamp(0, 1);

      // Step 4: Proportionally allocate tax between principal and contributions
      double principalTax = totalTax * principalRatio;
      double contributionsTax = totalTax * contributionRatio;

      // Step 5: Subtract the respective tax amounts from principal and contributions interest
      totalInterestFromPrincipal = (totalInterestFromPrincipal - principalTax).clamp(0, double.infinity);
      totalInterestFromContributions = (totalInterestFromContributions - contributionsTax).clamp(0, double.infinity);
    }


    previousPrincipalInterest = totalInterestFromPrincipal;
    previousContributionInterest = totalInterestFromContributions;
  }
}

  void prettyPrint() {
    // Format the main details
    print('--- Deposit Plan Summary ---');
    print('Principal: ${principal.toStringAsFixed(2)}');
    print('Interest Rate: ${interestRate.toStringAsFixed(2)}%');
    print('Duration: $duration years');
    print('Contribution Frequency: $contributionFrequency');
    print('Additional Contribution: ${additionalContribution.toStringAsFixed(2)}');
    print('Selected Tax Option: ${selectedTaxOption.description}');
    print('Total Deposits: ${deposits.toStringAsFixed(2)}');
    
    // Format the interest and total value
    print('Total Value (after $duration years): ${totalValue.toStringAsFixed(2)}');
    print('Total Compound Earnings: ${compoundEarnings.toStringAsFixed(2)}');
    
    // Interest breakdown
    print('Total Interest from Principal: ${totalInterestFromPrincipal.toStringAsFixed(2)}');
    print('Total Interest from Contributions: ${totalInterestFromContributions.toStringAsFixed(2)}');
    
    // Tax information if applicable
    if (totalTax > 0) {
      print('Total Tax Paid: ${totalTax.toStringAsFixed(2)}');
    } else {
      print('No Tax Applied');
    }
    
    print('---------------------------');
  }

}
