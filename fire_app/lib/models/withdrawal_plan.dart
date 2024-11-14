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
  double taxDuringBreak = 0;
  double withdrawalAfterTax = 0;
  double earningsAfterBreak = 0;
  double earningsPercentAfterBreak = 0;
  double withdrawalYearlyAfterBreak = 0;
  double taxableWithdrawalYearlyAfterBreak = 0;
  double taxYearlyAfterBreak = 0;
  double totalValue;
  double deposits;
  List<Map<String, double>> breakValues = [];
  List<Map<String, double>> yearlyValues = [];
  double inflationRate;

  WithdrawalPlan({
    required this.interestRate,
    this.breakPeriod = 0,
    required this.duration,
    required this.withdrawalPercentage,
    required this.selectedTaxOption,
    required this.totalValue,
    required this.deposits,
    required this.inflationRate,
  });

  List<Map<String, double>> calculateYearlyValues(double valueAfterDepositYears) {
    totalValue = valueAfterDepositYears;
    double previousValue;

    // Apply interest growth during the break period
    if (breakPeriod >= 1) {
        breakValues.add({
        'year': 0,
        'compoundThisYear': 0, // Compound earnings for the year
      });
      for (int year = 1; year <= breakPeriod; year++) {
        previousValue = totalValue;
        totalValue *= (1 + interestRate / 100);
        if (selectedTaxOption.isNotionallyTaxed) {
          // Notional gains tax applies only to yearly earnings (not the withdrawal)
          double taxThisYear = _notionalGainsTax(totalValue - previousValue);
          totalValue -= taxThisYear;
          taxDuringBreak += taxThisYear;
        }

      // Store yearly break values for reporting
      breakValues.add({
        'year': year.toDouble(),
        'compoundThisYear': totalValue - previousValue, // Compound earnings for the year
      });
      }
    }

    yearlyValues = [
      {
        'year': 0,
        'totalValue': totalValue,
        'compoundThisYear': 0,
        'compoundEarnings': 0,
        'withdrawal': 0,
        'tax': 0,
      }
    ];

    interestGatheredDuringBreak = totalValue - valueAfterDepositYears;

    // Calculate earnings after break period and withdrawal
    earningsAfterBreak = totalValue - deposits;
    earningsPercentAfterBreak = earningsAfterBreak / totalValue;
    withdrawalYearlyAfterBreak = (totalValue * (withdrawalPercentage / 100)) * (1 + (inflationRate / 100));
    
    // If it's not notionally taxed, apply capital gains tax logic
    if (!selectedTaxOption.isNotionallyTaxed) {
      taxableWithdrawalYearlyAfterBreak = _calculateTaxableWithdrawal(totalValue, deposits, withdrawalYearlyAfterBreak);
      taxYearlyAfterBreak = _capitalGainsTax(taxableWithdrawalYearlyAfterBreak);
    }

    double compoundInWithdrawalYears = 0;

    // Loop through each withdrawal year and apply compound interest, tax, and withdrawals
    for (int year = 1; year <= duration; year++) {
      withdrawalYearly = (totalValue * (withdrawalPercentage / 100)) * (1 + (inflationRate / 100));
    
      previousValue = totalValue;
      totalValue *= (1 + interestRate / 100);  // Apply compound interest for the year
      double compoundThisYear = totalValue - previousValue;

      // Calculate tax and withdrawal based on the selected tax option
      if (selectedTaxOption.isNotionallyTaxed) {
        // Notional gains tax applies only to yearly earnings (not the withdrawal)
        taxYearly = _notionalGainsTax(compoundThisYear);
      } else {
        // Capital gains tax applies to the earnings portion of the withdrawal
        taxableWithdrawalYearly = _calculateTaxableWithdrawal(totalValue, deposits, withdrawalYearly);
        taxYearly = _capitalGainsTax(taxableWithdrawalYearly);
      }

      compoundInWithdrawalYears += compoundThisYear;

      // Subtract yearly withdrawal from total value after tax is applied
      totalValue -= withdrawalYearly;

      // Store yearly values for reporting
      yearlyValues.add({
        'year': year.toDouble(),
        'totalValue': totalValue,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': compoundInWithdrawalYears,
        'withdrawal': withdrawalYearly,
        'tax': taxYearly,
      });
    }

    return yearlyValues;
  }

  // Helper function to calculate taxable withdrawal (portion of the withdrawal that is taxed)
  double _calculateTaxableWithdrawal(double totalValue, double deposits, double withdrawal) {
    double earnings = totalValue - deposits;
    if (earnings <= 0) return 0;
    
    // Calculate the earnings portion of the withdrawal
    double earningsPercent = earnings / totalValue;
    double taxableWithdrawal = withdrawal * earningsPercent;

    // Apply tax exemption if enabled
    if (selectedTaxOption.useTaxExemptionCard) {
      taxableWithdrawal -= TaxOption.taxExemptionCard;
    }

    return taxableWithdrawal < 0 ? 0 : taxableWithdrawal;
  }

  // Helper function to apply capital gains tax
  double _capitalGainsTax(double taxableWithdrawal) {
    if (taxableWithdrawal <= 0 || selectedTaxOption.ratePercentage == 0) return 0;
    double tax = 0;
    
    if (!selectedTaxOption.useTaxProgressionLimit ||
        selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate) {
        return tax < 0 ? 0 : tax = taxableWithdrawal * selectedTaxOption.ratePercentage / 100;
    }

    if (taxableWithdrawal <= TaxOption.taxProgressionLimit) {
      return tax < 0 ? 0 : tax = taxableWithdrawal * TaxOption.lowerTaxRate / 100;  // Apply lower tax rate under the threshold
    } else {
      return tax < 0 ? 0 : tax = (TaxOption.taxProgressionLimit * TaxOption.lowerTaxRate / 100) + ((taxableWithdrawal - TaxOption.taxProgressionLimit) * selectedTaxOption.ratePercentage / 100);
    }
  }

  // Helper function to apply notional gains tax
  double _notionalGainsTax(double earnings) {
    double tax = 0;

    // Apply notional gains tax only on the yearly compound earnings
    if (selectedTaxOption.useTaxExemptionCard) {
      earnings -= TaxOption.taxExemptionCard;
    }

    if (selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate || !selectedTaxOption.useTaxProgressionLimit) {
      return tax < 0 ? 0 : tax = earnings * selectedTaxOption.ratePercentage / 100;
    }

    if (earnings <= TaxOption.taxProgressionLimit) {
      return tax < 0 ? 0 : tax = earnings * TaxOption.lowerTaxRate / 100;
    } else {
      return tax < 0 ? 0 : tax = (TaxOption.taxProgressionLimit * TaxOption.lowerTaxRate / 100) + ((earnings - TaxOption.taxProgressionLimit) * selectedTaxOption.ratePercentage / 100);
    } 
  }
}

