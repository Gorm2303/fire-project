import 'package:fire_app/models/tax_option.dart';

class WithdrawalPlan {
  double interestRate;
  int breakPeriod; // Years during which investment grows but no withdrawals are made
  int duration;
  double interestGatheredDuringBreak = 0;
  double withdrawalPercentage;
  double withdrawalYearly = 0;
  double taxableWithdrawalYearly = 0;
  TaxOption selectedTaxOption;
  double taxYearly = 0;
  double withdrawalAfterTax = 0;
  double earningsAfterBreak = 0;
  double earningsPercentAfterBreak = 0;
  double taxableWithdrawalYearlyAfterBreak = 0;
  double taxYearlyAfterBreak = 0;
  double totalValue;
  double deposits;

  WithdrawalPlan({
    required this.interestRate,
    this.breakPeriod = 0,
    required this.duration,
    required this.withdrawalPercentage,
    required this.selectedTaxOption,
    required this.totalValue,
    required this.deposits,
  });

  List<Map<String, double>> calculateWithdrawalValues(double valueAfterDepositYears) {
    List<Map<String, double>> withdrawalValues = [
      {
        'year': 0.0,
        'totalValue': valueAfterDepositYears,
        'compoundThisYear': 0,
        'compoundEarnings': 0,
        'withdrawal': 0,
        'tax': 0,
      }
    ];
    totalValue = valueAfterDepositYears;
    double previousValue;
    interestGatheredDuringBreak = 0;

    // Apply interest growth during the break period
    if (breakPeriod >= 1) {
      for (int year = 1; year <= breakPeriod; year++) {
        totalValue *= (1 + interestRate / 100);
      }
      interestGatheredDuringBreak = totalValue - valueAfterDepositYears;
    }

    // Calculate earnings and withdrawal details after the break
    earningsAfterBreak = totalValue - deposits;
    earningsPercentAfterBreak = earningsAfterBreak / totalValue;
    withdrawalYearly = totalValue * (withdrawalPercentage / 100);

        // If it's not notionally taxed, apply capital gains tax logic
    if (!selectedTaxOption.isNotionallyTaxed) {
      taxableWithdrawalYearlyAfterBreak = _calculateTaxableWithdrawal(totalValue, deposits, withdrawalYearly);
      taxYearlyAfterBreak = _applyCapitalGainsTax(taxableWithdrawalYearlyAfterBreak);
    }

    double compoundInWithdrawalYears = 0;

    // Loop through each withdrawal year and apply compound interest, tax, and withdrawals
    for (int year = 1; year <= duration; year++) {
      previousValue = totalValue;
      totalValue *= (1 + interestRate / 100);  // Apply compound interest for the year
      double compoundThisYear = totalValue - previousValue;

      // Calculate tax and withdrawal based on the selected tax option
      if (selectedTaxOption.isNotionallyTaxed) {
        // Notional gains tax applies only to yearly earnings (not the withdrawal)
        taxYearly = _applyNotionalGainsTax(compoundThisYear);
      } else {
        // Capital gains tax applies to the earnings portion of the withdrawal
        taxableWithdrawalYearly = _calculateTaxableWithdrawal(totalValue, deposits, withdrawalYearly);
        taxYearly = _applyCapitalGainsTax(taxableWithdrawalYearly);
      }

      compoundInWithdrawalYears += compoundThisYear;

      // Subtract yearly withdrawal from total value after tax is applied
      totalValue -= withdrawalYearly;

      // Store yearly values for reporting
      withdrawalValues.add({
        'year': year.toDouble(),
        'totalValue': totalValue,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': compoundInWithdrawalYears,
        'withdrawal': withdrawalYearly,
        'tax': taxYearly,
      });
    }

    return withdrawalValues;
  }

  // Helper function to calculate taxable withdrawal (portion of the withdrawal that is taxed)
  double _calculateTaxableWithdrawal(double totalValue, double deposits, double withdrawal) {
    double earnings = totalValue - deposits;
    if (earnings <= 0) return 0;
    
    // Calculate the earnings portion of the withdrawal
    double earningsPercent = earnings / totalValue;
    double taxableWithdrawal = withdrawal * earningsPercent;

    // Apply tax exemption if enabled
    if (selectedTaxOption.useTaxExemptionCardAndThreshold) {
      taxableWithdrawal -= TaxOption.taxExemptionCard;
    }

    return taxableWithdrawal < 0 ? 0 : taxableWithdrawal;
  }

  // Helper function to apply capital gains tax
  double _applyCapitalGainsTax(double taxableWithdrawal) {
    if (taxableWithdrawal <= 0) return 0;

    double tax = 0;
    // Apply the capital gains tax rate, with consideration for the threshold and exemption
    if (selectedTaxOption.useTaxExemptionCardAndThreshold) {
      if (taxableWithdrawal <= TaxOption.threshold) {
        tax = taxableWithdrawal * 0.27;  // Apply lower tax rate under the threshold
      } else {
        tax = (TaxOption.threshold * 0.27) + ((taxableWithdrawal - TaxOption.threshold) * selectedTaxOption.rate / 100);
      }
    } else {
      tax = taxableWithdrawal * selectedTaxOption.rate / 100;
    }

    return tax < 0 ? 0 : tax;
  }

  // Helper function to apply notional gains tax
  double _applyNotionalGainsTax(double earnings) {
    double tax = 0;

    // Apply notional gains tax only on the yearly compound earnings
    if (earnings <= TaxOption.threshold) {
      tax = (earnings - TaxOption.taxExemptionCard) * 0.27;
    } else {
      tax = (earnings - TaxOption.taxExemptionCard) * selectedTaxOption.rate / 100;
    }

    return tax < 0 ? 0 : tax;
  }
}

