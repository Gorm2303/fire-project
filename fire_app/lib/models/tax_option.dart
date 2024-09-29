class TaxOption {
  final double rate;  // The numeric tax rate
  final String description;  // The description for the rate
  final bool isCustomTaxRule;
  final bool isNotionallyTaxed;
  final bool useTaxExemptionCardAndThreshold;
  static const double threshold = 61000;  // The threshold for lower tax rate
  static const double taxExemptionCard = 49700;  // The tax-free limit for the year

  TaxOption(
    this.rate, 
    this.description, 
    this.isCustomTaxRule,
    this.isNotionallyTaxed,
    this.useTaxExemptionCardAndThreshold);

  double calculateTaxableWithdrawal(double totalValue, double deposits, double withdrawal) {
    double earnings = totalValue - deposits;
    double earningsPercent = earnings / totalValue;
    double taxableWithdrawal = useTaxExemptionCardAndThreshold ? 
    (withdrawal * earningsPercent - taxExemptionCard) : (withdrawal * earningsPercent);
    return taxableWithdrawal;
  }
  
  double calculateTax(double taxableWithdrawal) {
    if (taxableWithdrawal <= 0 || isNotionallyTaxed) return 0;
  
    double tax = 0;
    if (useTaxExemptionCardAndThreshold) {
      if (taxableWithdrawal <= threshold) {
        tax = taxableWithdrawal * 0.27;
      } else {
        tax = (threshold * 0.27) + ((taxableWithdrawal - threshold) * 0.42);
      }
    } else {
      tax = taxableWithdrawal * rate / 100;
    }
    
    return tax;
  }

  double takeNotionalGainsTax(double totalValue, double deposits) {
    if (!isNotionallyTaxed || totalValue <= 0) return 0;

    double earnings = totalValue - deposits;
    double earningsPercent = earnings / totalValue;
    return totalValue * earningsPercent * rate / 100;
  }
}
