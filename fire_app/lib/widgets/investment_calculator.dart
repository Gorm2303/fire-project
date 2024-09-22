import 'dart:math';

// Function to calculate the yearly investment values
List<Map<String, double>> calculateYearlyValues({
  required double principal,
  required double rate,
  required double time,
  required int compoundingFrequency,
  required double additionalAmount,
  required String contributionFrequency,
}) {
  List<Map<String, double>> yearlyValues = [];
  double totalAmount = principal;
  double totalDeposits = principal;

  // Determine if contributions are monthly or yearly
  int contributionFreq = contributionFrequency == 'Monthly' ? 12 : 1;

  for (int year = 1; year <= time; year++) {
    // Apply compound interest for the current year
    totalAmount = totalAmount * pow(1 + (rate / 100) / compoundingFrequency, compoundingFrequency);
    totalDeposits += additionalAmount * contributionFreq;
    totalAmount += additionalAmount * contributionFreq;

    // Store the breakdown for the current year
    yearlyValues.add({
      'year': year.toDouble(),
      'totalValue': totalAmount,
      'totalDeposits': totalDeposits,
      'compoundEarnings': totalAmount - totalDeposits,
    });
  }

  return yearlyValues;
}
