import 'package:fire_app/models/tax_option.dart';
import 'package:fire_app/services/utils.dart';

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
    taxableWithdrawalYearlyAfterBreak = calculateTaxableWithdrawal(totalValue, withdrawalYearly);
    double compoundInWithdrawalYears = 0;

    for (int year = 1; year <= duration; year++) {
      previousValue = totalValue;
      totalValue *= (1 + interestRate / 100);

      double compoundThisYear = totalValue - previousValue;
      compoundInWithdrawalYears += compoundThisYear;

      double taxableWithdrawalYearly = calculateTaxableWithdrawal(totalValue, withdrawalYearly);
      taxYearly = calculateTax(totalValue, taxableWithdrawalYearly);
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

  double calculateTaxableWithdrawal(double totalValue, double withdrawal) {
    double earnings = totalValue - deposits;
    double earningsPercent = earnings / totalValue;
    return withdrawal * earningsPercent - Utils.taxExemptionCard;
  }

  double calculateTax(double totalValue, double withdrawal) {
    double taxableWithdrawal = calculateTaxableWithdrawal(totalValue, withdrawal);
    if (taxableWithdrawal <= 0) return 0;

    if (selectedTaxOption.isCustomTaxRule) {
      return taxableWithdrawal * selectedTaxOption.rate / 100;
    } else if (selectedTaxOption.rate == 42.0) {
      if (taxableWithdrawal <= Utils.threshold) {
        return taxableWithdrawal * 0.27;
      } else {
        return (Utils.threshold * 0.27) + ((taxableWithdrawal - Utils.threshold) * 0.42);
      }
    } else {
      return taxableWithdrawal * selectedTaxOption.rate / 100;
    }
  }
}
