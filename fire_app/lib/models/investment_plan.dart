import 'package:fire_app/models/tax_option.dart';
import 'package:fire_app/services/utils.dart';

class InvestmentPlan {
  String name;
  double principal;
  double rate;
  int depositYears; // in years
  double additionalAmount; // additional investment each year
  String contributionFrequency; // "Monthly", "Yearly", etc.
  double valueAfterDepositYears = 0;
  int breakPeriod; // years during which investment grows but no withdrawals are made
  int withdrawalPeriod; // duration of withdrawal period
  double compoundGatheredDuringBreak = 0;
  double withdrawalPercentage;
  double withdrawalYearly = 0;
  TaxOption selectedTaxOption;
  double earnings = 0;
  double earningsPercent = 0;
  double taxableWithdrawalYearly = 0;
  double taxYearly = 0;
  double deposits = 0;
  double totalValue = 0;

  InvestmentPlan(
    this.name,{
    required this.principal,
    required this.rate,
    required this.depositYears,
    required this.additionalAmount,
    required this.contributionFrequency,
    required this.selectedTaxOption,
    this.withdrawalPercentage = 4,
    this.breakPeriod = 0,
    this.withdrawalPeriod = 30,

  });

  // Mimicking _resetYearlyValues from the original class
  List<Map<String, double>> resetYearlyValues() {
    return [
      {
        'year': 0.0,
        'totalValue': principal,
        'totalDeposits': principal,
        'compoundEarnings': 0,
        'compoundThisYear': 0,
      }
    ];
  }

  // Mimicking _calculateYearlyValues from the original class
  List<Map<String, double>> calculateYearlyValues() {
    List<Map<String, double>> yearlyValues = resetYearlyValues();
    totalValue = principal;
    deposits = principal;
    double compoundEarnings = 0;
    int contributionPeriods = 1; // Default is yearly contributions

    if (contributionFrequency == 'Monthly') {
      contributionPeriods = 12;
    } 

    for (int year = 1; year <= depositYears; year++) {
      double compoundThisYear = 0;
      compoundThisYear += totalValue * (rate / 100);

      for (int period = 1; period <= contributionPeriods; period++) {
        // Compounding for each period based on frequency
        totalValue += additionalAmount;
        deposits += additionalAmount;

        // Compounding for each period
        int periodsLeft = contributionPeriods - period; 
        compoundThisYear += additionalAmount * (rate / 100) * periodsLeft / contributionPeriods;
      }
      totalValue += compoundThisYear;
      compoundEarnings += compoundThisYear;

      yearlyValues.add({
        'year': year.toDouble(),
        'totalValue': totalValue,
        'totalDeposits': deposits,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': compoundEarnings,
      });
    }

    valueAfterDepositYears = totalValue;
    return yearlyValues;
  }

  // Mimicking _calculateSecondTableValues from the original class
  List<Map<String, double>> calculateSecondTableValues(List<Map<String, double>> yearlyValues) {
    List<Map<String, double>> secondTableValues = [];
    totalValue = valueAfterDepositYears;
    double previousValue;
    compoundGatheredDuringBreak = 0;

    // Handle compounding during the break period
    if (breakPeriod >= 1) {
      for (int year = 1; year <= breakPeriod; year++) {
        totalValue *= (1 + rate / 100);
        previousValue = totalValue;
      }
      compoundGatheredDuringBreak = totalValue - yearlyValues.last['totalValue']!;
    }

    // Add the first entry (for the break period)
    secondTableValues.add({
      'year': 0,
      'totalValue': totalValue,
      'compoundThisYear': 0,
      'compoundEarnings': 0,
      'withdrawal': 0,
      'tax': 0,
    });

    // Custom withdrawal calculation after the break period
    withdrawalYearly = totalValue * (withdrawalPercentage / 100);
    double compoundInWithdrawalYears = 0;

    // Handle the withdrawal period
    for (int year = 1; year <= withdrawalPeriod; year++) {
      previousValue = totalValue;
      totalValue *= (1 + rate / 100);

      double compoundThisYear = totalValue - previousValue;
      compoundInWithdrawalYears += compoundThisYear;

      // Apply withdrawals and calculate tax during the withdrawal period
      totalValue -= withdrawalYearly;
      taxableWithdrawalYearly = calculateTaxableWithdrawal();
      taxYearly = calculateTax();

      secondTableValues.add({
        'year': year.toDouble(),
        'totalValue': totalValue,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': compoundInWithdrawalYears,
        'withdrawal': withdrawalYearly,
        'tax': taxYearly,
      });
    }

    return secondTableValues;
  }

  // Mimicking calculateTaxableWithdrawal from the original class
  double calculateTaxableWithdrawal() {
    earnings = totalValue - deposits;
    earningsPercent = earnings / totalValue;
    return withdrawalYearly * earningsPercent - Utils.taxExemptionCard;
  }

  // Mimicking _yearlyTotalTax from the original class
  double calculateTax() {
    double taxableWithdrawal = calculateTaxableWithdrawal();
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
