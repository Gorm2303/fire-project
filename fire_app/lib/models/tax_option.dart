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

  // Override the == operator to compare instances
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaxOption &&
        other.rate == rate &&
        other.description == description &&
        other.isCustomTaxRule == isCustomTaxRule &&
        other.isNotionallyTaxed == isNotionallyTaxed &&
        other.useTaxExemptionCardAndThreshold == useTaxExemptionCardAndThreshold;
  }

  // Override hashCode to ensure proper comparisons
  @override
  int get hashCode {
    return rate.hashCode ^
        description.hashCode ^
        isCustomTaxRule.hashCode ^
        isNotionallyTaxed.hashCode ^
        useTaxExemptionCardAndThreshold.hashCode;
  }

}
