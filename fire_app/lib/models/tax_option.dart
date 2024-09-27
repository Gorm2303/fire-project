class TaxOption {
  final double rate;  // The numeric tax rate
  final String description;  // The description for the rate
  final bool isCustomTaxRule;

  TaxOption(
    this.rate, 
    this.description, 
    this.isCustomTaxRule);
}
