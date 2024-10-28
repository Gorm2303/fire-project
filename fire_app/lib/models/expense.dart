
class Expense {
  final double amount;
  final String frequency;
  bool isSelected;

  Expense({required this.amount, required this.frequency, this.isSelected = true});

  double getYearlyAmount(int year) {
    if (frequency == 'One Time') {
      return year == 1 ? amount : 0;
    } else if (frequency == 'Yearly') {
      return amount;
    } else if (frequency == 'Monthly') {
      return amount * 12; // Monthly expense converted to yearly
    }
    return 0;
  }
}