class DepositPlan {
  double principal;
  double interestRate;
  int duration;
  double additionalAmount;
  String contributionFrequency;
  double totalValue = 0;
  double deposits = 0;
  double compoundEarnings = 0;
  
  DepositPlan({
    required this.principal,
    required this.interestRate,
    required this.duration,
    required this.additionalAmount,
    required this.contributionFrequency,
  });

  List<Map<String, double>> calculateYearlyValues() {
    List<Map<String, double>> yearlyValues = [
      {
        'year': 0.0,
        'totalValue': principal,
        'totalDeposits': principal,
        'compoundEarnings': 0,
        'compoundThisYear': 0,
      }
    ];

    totalValue = principal;
    deposits = principal;
    int contributionPeriods = 1; // Default is yearly contributions

    if (contributionFrequency == 'Monthly') {
      contributionPeriods = 12;
    }

    for (int year = 1; year <= duration; year++) {
      double compoundThisYear = 0;
      compoundThisYear += totalValue * (interestRate / 100);

      for (int period = 1; period <= contributionPeriods; period++) {
        totalValue += additionalAmount;
        deposits += additionalAmount;

        int periodsLeft = contributionPeriods - period;
        compoundThisYear += additionalAmount * (interestRate / 100) * periodsLeft / contributionPeriods;
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

    return yearlyValues;
  }
}
