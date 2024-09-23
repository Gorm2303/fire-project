import 'dart:math';

// Function to calculate the yearly investment values
List<Map<String, double>> calculateYearlyValues({
  required double principal,
  required double rate,
  required double time,
  required double additionalAmount,
  required String contributionFrequency,
}) {
  List<Map<String, double>> yearlyValues = [];
  double totalAmount = principal;
  double totalDeposits = principal;
  double previousCompoundEarnings = 0;  // To track the compound earnings from the previous year

  // Determine if contributions are monthly or yearly
  int contributionFreq = contributionFrequency == 'Monthly' ? 12 : 1;

  for (int year = 1; year <= time; year++) {
    // Apply the additional amount (if applicable) at each contribution period
    for (int period = 1; period <= contributionFreq; period++) {
      totalAmount += additionalAmount;  // Add the new deposit
      totalDeposits += additionalAmount;  // Track the total deposits

      // Apply interest for the whole year (assuming no compounding frequency)
      totalAmount = totalAmount * (1 + (rate / 100) / contributionFreq);  // Apply the interest rate
    }

    // Calculate the current compound earnings
    double currentCompoundEarnings = totalAmount - totalDeposits;

    // Calculate the compound interest earned during this year
    double compoundThisYear = currentCompoundEarnings - previousCompoundEarnings;

    // Store the breakdown for the current year
    yearlyValues.add({
      'year': year.toDouble(),
      'totalValue': totalAmount,
      'totalDeposits': totalDeposits,
      'compoundEarnings': currentCompoundEarnings,
      'compoundThisYear': compoundThisYear,  // Add the new column for compound interest earned this year
    });

    // Update previousCompoundEarnings for the next iteration
    previousCompoundEarnings = currentCompoundEarnings;
  }
  
  return yearlyValues;
}
