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

  /// Calculates taxable withdrawal, accounting for the tax exemption card and threshold
  double calculateTaxableWithdrawal(double totalValue, double deposits, double withdrawal) {
    double earnings = totalValue - deposits;
    if (earnings <= 0) return 0;

    // The percentage of withdrawal that is considered earnings
    double earningsPercent = earnings / totalValue;

    // Calculate taxable withdrawal amount
    double taxableWithdrawal = withdrawal * earningsPercent;

    // Apply tax exemption card if applicable
    if (useTaxExemptionCardAndThreshold) {
      taxableWithdrawal -= taxExemptionCard;
    }

    // Ensure taxable withdrawal is not negative
    if (taxableWithdrawal < 0) {
      taxableWithdrawal = 0;
    }

    return taxableWithdrawal;
  }
  
  double calculateTaxWithdrawalYears(double earnings) {
    if (earnings <= 0) return 0;

    double tax = 0;
    if (useTaxExemptionCardAndThreshold) {
      if (isNotionallyTaxed) {
        if (earnings <= threshold) {
          tax = (earnings - taxExemptionCard) * 0.27;
        } else {
          tax = (earnings - taxExemptionCard) * rate / 100;
        } 
      } else {
        if (earnings <= threshold) {
          tax = earnings * 0.27;
        } else {
          tax = (threshold * 0.27) + ((earnings - threshold) * rate / 100);
        }
      }
    } else {
      tax = earnings * rate / 100;
    }
    if (tax < 0) return 0;
    return tax;
  }

  double calculateTaxDepositingYears(double earnings) {
    if (earnings <= 0) return 0;

    double tax = 0;
    tax = earnings * rate / 100;
    if (tax < 0) return 0;
    
    return tax;
  }

}
