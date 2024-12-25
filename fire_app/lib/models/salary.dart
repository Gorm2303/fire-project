import 'dart:math';

class Salary {
  final double amountMonthly;
  final double raiseYearlyPercentage;
  bool isSelected;

  Salary({required this.amountMonthly, required this.raiseYearlyPercentage, this.isSelected = true});

  // Calculates compounded yearly amount after raises
  double getTotalAmount(int year) {
    return amountMonthly * 12 * pow(1 + raiseYearlyPercentage / 100, year - 1);
  }

  // Toggle selection state
  void toggleSelection() {
    isSelected = !isSelected;
  }
}
