import 'package:fire_app/models/tax_option.dart';
import 'package:flutter/material.dart';

class TaxCalculationResults extends StatelessWidget {
  final double earnings;
  final double earningsPercent;
  final double taxableWithdrawal;
  final double annualTax;
  final double totalAfterBreak;
  final double deposits;
  final double withdrawalPercentage;
  final bool useTaxExemptionCardAndThreshold;
  final TaxOption taxOption;

  const TaxCalculationResults({
    super.key, 
    required this.earnings, 
    required this.earningsPercent, 
    required this.taxableWithdrawal, 
    required this.annualTax,
    required this.totalAfterBreak,
    required this.deposits,
    required this.withdrawalPercentage,
    required this.useTaxExemptionCardAndThreshold,
    required this.taxOption,
  });

@override
Widget build(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,  // Center the column content
    children: [
      const Text(
        'Tax Calculation Results:',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Earnings (Total): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: '${totalAfterBreak.toStringAsFixed(0)} - ${deposits.toStringAsFixed(0)} = '),
            TextSpan(text: earnings.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Earnings (Percent): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: '${earnings.toStringAsFixed(0)} / ${totalAfterBreak.toStringAsFixed(0)} = '),
            TextSpan(text: '${(earningsPercent * 100).toStringAsFixed(2)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Taxable Withdrawal (Yearly): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: useTaxExemptionCardAndThreshold  // Check if useTaxExemptionCardAndThreshold is true 
                ? '${(totalAfterBreak * withdrawalPercentage).toStringAsFixed(0)} × ${earningsPercent.toStringAsFixed(4)} - ${TaxOption.taxExemptionCard} = ' // If condition is true
                : '${(totalAfterBreak * withdrawalPercentage).toStringAsFixed(0)} × ${earningsPercent.toStringAsFixed(4)} = '  // If condition is false
            ),
            TextSpan(text: taxableWithdrawal.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Taxable Withdrawal (Monthly): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: useTaxExemptionCardAndThreshold  // Check if useTaxExemptionCardAndThreshold is true 
                ? '${(totalAfterBreak * withdrawalPercentage/12).toStringAsFixed(0)} × ${earningsPercent.toStringAsFixed(4)} - ${(TaxOption.taxExemptionCard/12).toStringAsFixed(0)} = ' // If condition is true
                : '${(totalAfterBreak * withdrawalPercentage/12).toStringAsFixed(0)} × ${earningsPercent.toStringAsFixed(4)} = '  // If condition is false
            ),
            TextSpan(text: (taxableWithdrawal / 12).toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Tax (Yearly): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: !useTaxExemptionCardAndThreshold || taxOption.ratePercentage < TaxOption.lowerTaxRate  // Check if useTaxExemptionCardAndThreshold is false 
                ? '${taxableWithdrawal.toStringAsFixed(0)} × ${taxOption.ratePercentage/100} = ' // If condition is true
                : taxableWithdrawal < TaxOption.threshold  // Check if taxableWithdrawal is less than the threshold 
                  ? '${taxableWithdrawal.toStringAsFixed(0)} × ${TaxOption.lowerTaxRate/100} = ' // If condition is true
                  : '${TaxOption.threshold.toStringAsFixed(0)} × ${TaxOption.lowerTaxRate/100} + (${taxableWithdrawal.toStringAsFixed(0)} - ${TaxOption.threshold}) × ${(taxOption.ratePercentage/100).toStringAsFixed(2)} = '  // If condition is false
            ),            
            TextSpan(text: annualTax.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Tax (Monthly): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: !useTaxExemptionCardAndThreshold || taxOption.ratePercentage < TaxOption.lowerTaxRate  // Check if useTaxExemptionCardAndThreshold is false 
                ? '${(taxableWithdrawal/12).toStringAsFixed(0)} × ${taxOption.ratePercentage/100} = ' // If condition is true
                : taxableWithdrawal < TaxOption.threshold  // Check if taxableWithdrawal is less than the threshold 
                  ? '${(taxableWithdrawal/12).toStringAsFixed(0)} × ${TaxOption.lowerTaxRate/100} = ' // If condition is true
                  : '${(TaxOption.threshold/12).toStringAsFixed(0)} × ${TaxOption.lowerTaxRate/100} + (${(taxableWithdrawal/12).toStringAsFixed(0)} - ${(TaxOption.threshold/12).toStringAsFixed(0)}) × ${(taxOption.ratePercentage/100).toStringAsFixed(2)} = '  // If condition is false
            ),
            TextSpan(text: (annualTax / 12).toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Actual Tax Rate: ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: useTaxExemptionCardAndThreshold
              ? '${annualTax.toStringAsFixed(0)} / ${(taxableWithdrawal + TaxOption.taxExemptionCard).toStringAsFixed(2)} = '  // If condition is true
              : '${annualTax.toStringAsFixed(0)} / ${(taxableWithdrawal).toStringAsFixed(2)} = ',  // If condition is false
            ),
            TextSpan(text: useTaxExemptionCardAndThreshold
              ? '${(annualTax / (taxableWithdrawal + TaxOption.taxExemptionCard) * 100).toStringAsFixed(2)}%'  // If condition is true
              : '${(annualTax / taxableWithdrawal * 100).toStringAsFixed(2)}%',  // If condition is false
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    ],
  );
}

}
