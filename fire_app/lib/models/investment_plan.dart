import 'package:fire_app/models/tax_option.dart';
import 'package:fire_app/services/utils.dart';

class InvestmentPlan {
  String name;
  double principal;
  double rate;
  int duration; // in years
  double additionalAmount; // additional investment each year
  String contributionFrequency; // "Monthly", "Yearly", etc.
  double withdrawalPercentage;
  int withdrawalTime; // duration of withdrawal period
  int breakPeriod; // years during which investment grows but no withdrawals are made
  TaxOption selectedTaxOption;
  double compoundGatheredDuringBreak = 0;
  double taxableWithdrawal = 0;
  double tax = 0;

  InvestmentPlan(
    this.name,{
    required this.principal,
    required this.rate,
    required this.duration,
    required this.additionalAmount,
    required this.contributionFrequency,
    required this.selectedTaxOption,
    this.withdrawalPercentage = 4,
    this.breakPeriod = 0,
    this.withdrawalTime = 30,

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
    double totalValue = principal;
    double totalDeposits = principal;
    double compoundEarnings = 0;

    for (int year = 1; year <= duration; year++) {
      double compoundThisYear = (totalValue + (additionalAmount * year)) * (rate / 100);
      totalValue += compoundThisYear;
      totalDeposits += additionalAmount;

      yearlyValues.add({
        'year': year.toDouble(),
        'totalValue': totalValue,
        'totalDeposits': totalDeposits,
        'compoundEarnings': compoundEarnings += compoundThisYear,
        'compoundThisYear': compoundThisYear,
      });
    }

    return yearlyValues;
  }

  // Mimicking _calculateSecondTableValues from the original class
  List<Map<String, double>> calculateSecondTableValues(List<Map<String, double>> yearlyValues) {
    List<Map<String, double>> secondTableValues = [];
    double totalAmount = yearlyValues.last['totalValue']!;
    double previousValue;
    double withdrawal = totalAmount * (withdrawalPercentage / 100);
    compoundGatheredDuringBreak = 0;

    // Handle compounding during the break period
    if (breakPeriod >= 1) {
      for (int year = 1; year <= breakPeriod; year++) {
        totalAmount *= (1 + rate / 100);
        previousValue = totalAmount;
      }
      compoundGatheredDuringBreak = totalAmount - yearlyValues.last['totalValue']!;
    }

    // Add the first entry (for the break period)
    secondTableValues.add({
      'year': 0,
      'totalValue': totalAmount,
      'compoundThisYear': 0,
      'compoundEarnings': 0,
      'withdrawal': 0,
      'tax': 0,
    });

    // Custom withdrawal calculation after the break period
    double compoundInWithdrawalYears = 0;

    // Handle the withdrawal period
    for (int year = 1; year <= withdrawalTime; year++) {
      previousValue = totalAmount;
      totalAmount *= (1 + rate / 100);

      double compoundThisYear = totalAmount - previousValue;
      compoundInWithdrawalYears += compoundThisYear;

      // Apply withdrawals and calculate tax during the withdrawal period
      totalAmount -= withdrawal;
      taxableWithdrawal = calculateTaxableWithdrawal(totalAmount, withdrawal);
      tax = calculateTax(totalAmount, taxableWithdrawal);

      secondTableValues.add({
        'year': year.toDouble(),
        'totalValue': totalAmount,
        'compoundThisYear': compoundThisYear,
        'compoundEarnings': compoundInWithdrawalYears,
        'withdrawal': withdrawal,
        'tax': tax,
      });
    }

    return secondTableValues;
  }

  // Mimicking calculateTaxableWithdrawal from the original class
  double calculateTaxableWithdrawal(double total, double withdrawal) {
    double deposits = total - principal;
    double earnings = total - deposits;
    double earningsPercent = earnings / total;
    return withdrawal * earningsPercent - Utils.taxExemptionCard;
  }

  // Mimicking _yearlyTotalTax from the original class
  double calculateTax(double total, double withdrawal) {
    double taxableWithdrawal = calculateTaxableWithdrawal(total, withdrawal);
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
