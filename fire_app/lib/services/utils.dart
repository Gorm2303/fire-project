import 'dart:math';

class Utils {
  static const double threshold = 61000;  // The threshold for lower tax rate
  static const double taxExemptionCard = 49700;  // The tax-free limit

  // Convert a String to double, returns 0 if the parsing fails
  static double parseTextToDouble(String text) {
    return double.tryParse(text) ?? 0.0;
  }

  // Convert a String to int, returns 0 if the parsing fails
  static int parseTextToInt(String text) {
    return int.tryParse(text) ?? 0;
  }

  // Calculate the percentage based on the total
  static double calculatePercentage(double part, double total) {
    if (total == 0) {
      return 0.0;
    }
    return (part / total) * 100;
  }

  // Calculate earnings from total value and deposits
  static double calculateEarnings(double totalValue, double totalDeposits) {
    return totalValue - totalDeposits;
  }

  // Calculate the earnings percentage
  static double calculateEarningsPercent(double earnings, double totalValue) {
    if (totalValue == 0) {
      return 0.0;
    }
    return earnings / totalValue;
  }

  // Utility function to calculate taxable withdrawal
  static double calculateTaxableWithdrawal(double earningsPercent, double withdrawalAmount, double exemption) {
    double taxableWithdrawal = (earningsPercent * withdrawalAmount) - exemption;
    return taxableWithdrawal > 0 ? taxableWithdrawal : 0.0;
  }

  static double calculateCompoundInterest(double principal, double rate, double time) {
    return principal * pow(1 + rate / 100, time) - principal;
  }
  
}
