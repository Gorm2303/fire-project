import 'package:fire_app/models/tax_option.dart';
import 'deposit_plan.dart';
import 'withdrawal_plan.dart';

class InvestmentPlan {
  String name;
  DepositPlan depositPlan;
  WithdrawalPlan withdrawalPlan;

  List<Map<String, double>>? depositValues;
  List<Map<String, double>>? withdrawalValues;

  InvestmentPlan({
    required this.name,
    required double principal,
    required double rate,
    required int depositYears,
    required double additionalAmount,
    required String contributionFrequency,
    required TaxOption selectedTaxOption,
    int breakPeriod = 0,  // Added break period
    double withdrawalPercentage = 4,
    int withdrawalPeriod = 30,
  })  : depositPlan = DepositPlan(
          principal: principal,
          interestRate: rate,
          duration: depositYears,
          additionalContribution: additionalAmount,
          contributionFrequency: contributionFrequency,
          selectedTaxOption: selectedTaxOption,
        ),
        withdrawalPlan = WithdrawalPlan(
          interestRate: rate,
          duration: withdrawalPeriod,
          withdrawalPercentage: withdrawalPercentage,
          selectedTaxOption: selectedTaxOption,
          totalValue: 0,  // Initial value after deposit years, to be updated later
          deposits: 0,    // Initial deposits, to be updated later
          breakPeriod: breakPeriod,  // Pass break period to the WithdrawalPlan
        );

  // Method to calculate the investment
  void calculateInvestment() {
    depositValues = depositPlan.calculateYearlyValues();
    withdrawalPlan.totalValue = depositPlan.totalValue;
    withdrawalPlan.deposits = depositPlan.deposits;

    withdrawalValues = withdrawalPlan.calculateWithdrawalValues(
      depositPlan.totalValue
    );
  }

  // Method to display deposit plan results
  void displayDepositPlanResults() {
    if (depositValues != null) {
      print("Deposit Plan Results:");
      for (var yearData in depositValues!) {
        print("Year ${yearData['year']}: Total Value: ${yearData['totalValue']}, Deposits: ${yearData['totalDeposits']}, Compound Earnings: ${yearData['compoundEarnings']}");
      }
    } else {
      print("No deposit plan results available. Run calculateInvestment() first.");
    }
  }

  // Method to display withdrawal plan results
  void displayWithdrawalPlanResults() {
    if (withdrawalValues != null) {
      print("Withdrawal Plan Results:");
      for (var yearData in withdrawalValues!) {
        print("Year ${yearData['year']}: Total Value: ${yearData['totalValue']}, Withdrawal: ${yearData['withdrawal']}, Tax: ${yearData['tax']}");
      }
    } else {
      print("No withdrawal plan results available. Run calculateInvestment() first.");
    }
  }

  // Method to return final balance after withdrawals
  double getFinalBalance() {
    if (withdrawalValues != null && withdrawalValues!.isNotEmpty) {
      return withdrawalValues!.last['totalValue'] ?? 0;
    } else {
      print("No withdrawal plan results available. Returning initial total value.");
      return depositPlan.totalValue;
    }
  }

  // Method to get total taxes paid during the withdrawal period
  double getTotalTaxesPaid() {
    if (withdrawalValues != null) {
      return withdrawalValues!
          .map((yearData) => yearData['tax'] ?? 0)
          .reduce((a, b) => a + b);
    } else {
      print("No withdrawal plan results available. Returning 0.");
      return 0;
    }
  }

  // Method to get total withdrawals over the withdrawal period
  double getTotalWithdrawals() {
    if (withdrawalValues != null) {
      return withdrawalValues!
          .map((yearData) => yearData['withdrawal'] ?? 0)
          .reduce((a, b) => a + b);
    } else {
      print("No withdrawal plan results available. Returning 0.");
      return 0;
    }
  }
}
