import 'package:fire_app/models/tax_option.dart';

class WithdrawalPlan {
  double interestRate;
  int breakPeriod; // years during which investment grows but no withdrawals are made
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

    if (breakPeriod >= 1) {
      for (int year = 1; year <= breakPeriod; year++) {
        totalValue *= (1 + interestRate / 100);
      }
      interestGatheredDuringBreak = totalValue - valueAfterDepositYears;
    }

    earningsAfterBreak = totalValue - deposits;
    earningsPercentAfterBreak = earningsAfterBreak / totalValue;
    withdrawalYearly = totalValue * (withdrawalPercentage / 100);
    taxableWithdrawalYearlyAfterBreak = selectedTaxOption.calculateTaxableWithdrawal(totalValue, deposits, withdrawalYearly);
    taxYearlyAfterBreak = selectedTaxOption.calculateTax(taxableWithdrawalYearlyAfterBreak);
    double compoundInWithdrawalYears = 0;

    for (int year = 1; year <= duration; year++) {
      previousValue = totalValue;
      totalValue *= (1 + interestRate / 100);

      double compoundThisYear = totalValue - previousValue;
      compoundInWithdrawalYears += compoundThisYear;

      double taxableWithdrawalYearly = selectedTaxOption.calculateTaxableWithdrawal(totalValue, deposits, withdrawalYearly);
      taxYearly = selectedTaxOption.calculateTax(taxableWithdrawalYearly);
      totalValue -= withdrawalYearly;

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
