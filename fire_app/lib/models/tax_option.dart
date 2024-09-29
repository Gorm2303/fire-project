class TaxOption {
  final double rate;  // The numeric tax rate
  final String description;  // The description for the rate
  final bool isCustomTaxRule;
  static const double threshold = 61000;  // The threshold for lower tax rate
  static const double taxExemptionCard = 49700;  // The tax-free limit

  TaxOption(
    this.rate, 
    this.description, 
    this.isCustomTaxRule);


  double calculateTaxableWithdrawal(double totalValue, double deposits, double withdrawal) {
    double earnings = totalValue - deposits;
    double earningsPercent = earnings / totalValue;
    return withdrawal * earningsPercent - taxExemptionCard;
  }
  
  double calculateTax(double taxableWithdrawal) {
    if (taxableWithdrawal <= 0) return 0;

    if (rate == 42.0) {
      if (taxableWithdrawal <= threshold) {
        return taxableWithdrawal * 0.27;
      } else {
        return (threshold * 0.27) + ((taxableWithdrawal - threshold) * 0.42);
      }
    } else {
      return taxableWithdrawal * rate / 100;
    }
  }
}
