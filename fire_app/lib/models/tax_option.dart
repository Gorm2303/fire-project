class TaxOption {
  final double ratePercentage;  // The numeric tax rate
  final String description;  // The description for the rate
  final bool isNotionallyTaxed;
  final bool useTaxExemptionCard;  // New field for tax exemption card
  final bool useTaxProgressionLimit;  // New field for progression limit
  static const double threshold = 61000;  // The threshold for lower tax rate
  static const double taxExemptionCard = 49700;  // The tax-free limit for the year
  static const double lowerTaxRate = 27;  // The lower tax rate for threshold

  TaxOption(
    this.ratePercentage, 
    this.description, 
    {
      required this.isNotionallyTaxed, 
      required this.useTaxExemptionCard,  // Updated field
      required this.useTaxProgressionLimit,  // New field
    }
  );

  // Override the == operator to compare instances
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaxOption &&
        other.ratePercentage == ratePercentage &&
        other.description == description &&
        other.isNotionallyTaxed == isNotionallyTaxed &&
        other.useTaxExemptionCard == useTaxExemptionCard &&  // Updated comparison
        other.useTaxProgressionLimit == useTaxProgressionLimit;    // New comparison
  }

  // Override hashCode to ensure proper comparisons
  @override
  int get hashCode {
    return ratePercentage.hashCode ^
        description.hashCode ^
        isNotionallyTaxed.hashCode ^
        useTaxExemptionCard.hashCode ^  // Updated hash
        useTaxProgressionLimit.hashCode;   // New hash
  }
}
