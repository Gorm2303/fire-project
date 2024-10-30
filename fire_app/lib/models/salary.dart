import 'dart:math';

class Salary {
  final double amount;
  final double raiseYearlyPercentage;
  bool isSelected;

  Salary({required this.amount, required this.raiseYearlyPercentage, this.isSelected = true});

  // Calculates compounded yearly amount after raises
  double getYearlyAmount(int year) {
    return amount * pow(1 + raiseYearlyPercentage / 100, year - 1);
  }

  // Toggle selection state
  void toggleSelection() {
    isSelected = !isSelected;
  }
}
