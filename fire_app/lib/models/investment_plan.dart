import 'package:fire_app/models/tax_option.dart';
import 'deposit_plan.dart';
import 'withdrawal_plan.dart';
import 'package:flutter/foundation.dart'; 

class InvestmentPlan extends ChangeNotifier {
  String name;
  DepositPlan depositPlan;
  WithdrawalPlan withdrawalPlan;

  InvestmentPlan({
    required this.name,
    required double principal,
    required double interestRate,
    required int depositYears,
    required double additionalAmount,
    required String contributionFrequency,
    required TaxOption selectedTaxOption,
    int breakPeriod = 0,  // Added break period
    double withdrawalPercentage = 4,
    int withdrawalPeriod = 30,
  })  : depositPlan = DepositPlan(
          principal: principal,
          interestRate: interestRate,
          duration: depositYears,
          additionalContribution: additionalAmount,
          contributionFrequency: contributionFrequency,
          selectedTaxOption: selectedTaxOption,
        ),
        withdrawalPlan = WithdrawalPlan(
          interestRate: interestRate,
          duration: withdrawalPeriod,
          withdrawalPercentage: withdrawalPercentage,
          selectedTaxOption: selectedTaxOption,
          totalValue: 0,  // Initial value after deposit years, to be updated later
          deposits: 0,    // Initial deposits, to be updated later
          breakPeriod: breakPeriod,  // Pass break period to the WithdrawalPlan
        );

  // Method to calculate the investment
  void calculateInvestment() {
    depositPlan.calculateYearlyValues();
    withdrawalPlan.totalValue = depositPlan.totalValue;
    withdrawalPlan.deposits = depositPlan.deposits;
    withdrawalPlan.calculateYearlyValues(depositPlan.totalValue);
    notifyListeners();  // Notify listeners after calculation
  }
}
