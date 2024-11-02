import 'dart:math';

class Utils {

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

  static double calculateCompoundInterest(double principal, double rate, double time) {
    return principal * pow(1 + rate / 100, time) - principal;
  }

  static String formatNumber(dynamic number) {
    if (number == null) return '0';
    if (number is String) number = double.tryParse(number) ?? 0.0;
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match match) => ',',
    );
  }

  static List<Map<String, dynamic>> formatListOfMaps(List<Map<String, double>> list) {
    return list.map((map) {
      return map.map((key, value) => MapEntry(key, formatNumber(value)));
    }).toList();
  }

  static String parseDivideAndFormat(String value) {
    value = value.replaceAll(',', '');
    double parsedValue = parseTextToDouble(value);
    double dividedValue = parsedValue / 12;
    String formattedValue = formatNumber(dividedValue);
    return formattedValue;
  }

}
