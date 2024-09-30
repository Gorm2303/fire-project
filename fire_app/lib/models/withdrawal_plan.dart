import 'package:fire_app/models/tax_option.dart';

class WithdrawalPlan {
  double interestRate;
  int breakPeriod; // Years during which investment grows but no withdrawals are made
  int duration;
  double interestGatheredDuringBreak = 0;
  double withdrawalPercentage;
  double withdrawalYearly = 0;
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
      taxableWithdrawalYearlyAfterBreak = selectedTaxOption.calculateTaxableWithdrawal(totalValue, deposits, withdrawalYearly);
      taxYearlyAfterBreak = selectedTaxOption.calculateTaxWithdrawalYears(taxableWithdrawalYearlyAfterBreak);
    }

    double compoundInWithdrawalYears = 0;

    // Loop through each withdrawal year and apply compound interest, tax, and withdrawals
    for (int year = 1; year <= duration; year++) {
      previousValue = totalValue;
      totalValue *= (1 + interestRate / 100);  // Apply compound interest for the year
      double compoundThisYear = totalValue - previousValue;

      if (selectedTaxOption.isNotionallyTaxed) {
        // For notional gains tax, apply tax on compounded earnings
        double earnings = compoundThisYear * (1 - selectedTaxOption.rate / 100);
        taxYearly = compoundThisYear - earnings;  // Tax on notional gains
        compoundThisYear = earnings;
      } else {
        // For capital gains tax, calculate taxable withdrawal and apply tax
        double taxableWithdrawalYearly = selectedTaxOption.calculateTaxableWithdrawal(totalValue, deposits, withdrawalYearly);
        taxYearly = selectedTaxOption.calculateTaxWithdrawalYears(taxableWithdrawalYearly);
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
}


