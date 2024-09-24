// Function to calculate the yearly investment values with monthly contributions getting interest for remaining months of the year
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
  double previousCompoundEarnings = 0; // To track the compound earnings from the previous year

  // Determine if contributions are monthly or yearly
  int contributionFreq = contributionFrequency == 'Monthly' ? 12 : 1;

  for (int year = 1; year <= time; year++) {
    totalAmount *= (1 + (rate / 100));  // Apply the interest for the year

    // Apply the additional amount (if applicable) at each contribution period
    for (int period = 1; period <= contributionFreq; period++) {
      totalAmount += additionalAmount;  // Add the new deposit
      totalDeposits += additionalAmount;  // Track the total deposits

      if (contributionFreq == 12) {
        // Monthly contributions with remaining months' interest
        int monthsLeft = 12 - (period - 1); // Months remaining in the year
        totalAmount += additionalAmount * (rate / 100) * monthsLeft / 12;
      }
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
