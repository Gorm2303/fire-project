import 'package:fire_app/models/tax_option.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaxCalculationResults extends StatelessWidget {
  final double earnings;
  final double earningsPercent;
  final double taxableWithdrawal;
  final double annualTax;
  final double totalAfterBreak;
  final double deposits;
  final double withdrawalPercentage;
  final bool useTaxExemptionCard;
  final bool useTaxProgressionLimit;
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
    required this.useTaxExemptionCard,
    required this.useTaxProgressionLimit,
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
            TextSpan(
              text: '${NumberFormat('###,###').format(totalAfterBreak)} - ${NumberFormat('###,###').format(deposits)} = ',
            ),
            TextSpan(
              text: NumberFormat('###,###').format(earnings),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Earnings (Percent): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: '${NumberFormat('###,###').format(earnings)} / ${NumberFormat('###,###').format(totalAfterBreak)} = ',
            ),
            TextSpan(
              text: '${(earningsPercent * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Taxable Withdrawal (Yearly): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: useTaxExemptionCard
                // If useTaxExemptionCard is true
                ? '${NumberFormat('###,###').format(taxOption.isNotionallyTaxed ? 0 : totalAfterBreak * withdrawalPercentage)} × ${earningsPercent.toStringAsFixed(4)} - ${NumberFormat('###,###').format(TaxOption.taxExemptionCard)} = '
                // If useTaxExemptionCard is false
                : '${NumberFormat('###,###').format(taxOption.isNotionallyTaxed ? 0 : totalAfterBreak * withdrawalPercentage)} × ${earningsPercent.toStringAsFixed(4)} = ',
            ),
            TextSpan(
              text: NumberFormat('###,###').format(taxableWithdrawal),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Taxable Withdrawal (Monthly): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: useTaxExemptionCard
                // If useTaxExemptionCard is true
                ? '${NumberFormat('###,###').format(taxOption.isNotionallyTaxed ? 0 : totalAfterBreak * withdrawalPercentage / 12)} × ${earningsPercent.toStringAsFixed(4)} - ${NumberFormat('###,###').format(TaxOption.taxExemptionCard / 12)} = '
                // If useTaxExemptionCard is false
                : '${NumberFormat('###,###').format(taxOption.isNotionallyTaxed ? 0 : totalAfterBreak * withdrawalPercentage / 12)} × ${earningsPercent.toStringAsFixed(4)} = ',
            ),
            TextSpan(
              text: NumberFormat('###,###').format(taxableWithdrawal / 12),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Tax (Yearly): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: !useTaxProgressionLimit || taxOption.ratePercentage < TaxOption.lowerTaxRate
                // If useTaxProgressionLimit is false or taxOption rate is lower than the lowerTaxRate
                ? '${NumberFormat('###,###').format(taxableWithdrawal)} × ${(taxOption.ratePercentage / 100).toStringAsFixed(2)} = '
                // If taxableWithdrawal is less than the tax progression limit
                : taxableWithdrawal < TaxOption.taxProgressionLimit
                  ? '${NumberFormat('###,###').format(taxableWithdrawal)} × ${(TaxOption.lowerTaxRate / 100).toStringAsFixed(2)} = '
                  // If taxableWithdrawal exceeds the tax progression limit
                  : '${NumberFormat('###,###').format(TaxOption.taxProgressionLimit)} × ${(TaxOption.lowerTaxRate / 100).toStringAsFixed(2)} + (${NumberFormat('###,###').format(taxableWithdrawal)} - ${NumberFormat('###,###').format(TaxOption.taxProgressionLimit)}) × ${(taxOption.ratePercentage / 100).toStringAsFixed(2)} = ',
            ),
            TextSpan(
              text: NumberFormat('###,###').format(annualTax),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(text: 'Tax (Monthly): ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: !useTaxProgressionLimit || taxOption.ratePercentage < TaxOption.lowerTaxRate
                // If useTaxProgressionLimit is false or taxOption rate is lower than the lowerTaxRate
                ? '${NumberFormat('###,###').format(taxableWithdrawal / 12)} × ${(taxOption.ratePercentage / 100).toStringAsFixed(2)} = '
                // If taxableWithdrawal is less than the tax progression limit
                : taxableWithdrawal < TaxOption.taxProgressionLimit
                  ? '${NumberFormat('###,###').format(taxableWithdrawal / 12)} × ${(TaxOption.lowerTaxRate / 100).toStringAsFixed(2)} = '
                  // If taxableWithdrawal exceeds the tax progression limit
                  : '${NumberFormat('###,###').format(TaxOption.taxProgressionLimit / 12)} × ${(TaxOption.lowerTaxRate / 100).toStringAsFixed(2)} + (${NumberFormat('###,###').format(taxableWithdrawal / 12)} - ${NumberFormat('###,###').format(TaxOption.taxProgressionLimit / 12)}) × ${(taxOption.ratePercentage / 100).toStringAsFixed(2)} = ',
            ),
            TextSpan(
              text: NumberFormat('###,###').format(annualTax / 12),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(
              text: 'Actual Tax Rate: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: (useTaxExemptionCard && useTaxProgressionLimit)
                // Both conditions are true
                ? '${NumberFormat('###,###').format(annualTax)} / ( ${NumberFormat('###,###').format(taxableWithdrawal)} + ${NumberFormat('###,###').format(TaxOption.taxExemptionCard)}) = '
                // Only exemption card is true
                : (useTaxExemptionCard)
                  ? '${NumberFormat('###,###').format(annualTax)} / ( ${NumberFormat('###,###').format(taxableWithdrawal)} + ${NumberFormat('###,###').format(TaxOption.taxExemptionCard)}) = '
                  // Only progression limit is true
                  : (useTaxProgressionLimit)
                    ? '${NumberFormat('###,###').format(annualTax)} / ${NumberFormat('###,###').format(taxableWithdrawal)} = '
                    // Neither condition is true
                    : '${NumberFormat('###,###').format(annualTax)} / ${NumberFormat('###,###').format(taxableWithdrawal)} = ',
            ),
            TextSpan(
              text: (useTaxExemptionCard && useTaxProgressionLimit)
                // Both conditions are true
                ? '${(annualTax / (taxableWithdrawal + TaxOption.taxExemptionCard) * 100).toStringAsFixed(2)}%'
                // Only exemption card is true
                : (useTaxExemptionCard)
                  ? '${(annualTax / (taxableWithdrawal + TaxOption.taxExemptionCard) * 100).toStringAsFixed(2)}%'
                  // Only progression limit is true
                  : (useTaxProgressionLimit)
                    ? '${(annualTax / (taxableWithdrawal) * 100).toStringAsFixed(2)}%'
                    // Neither condition is true
                    : '${((taxOption.isNotionallyTaxed ? 0 : annualTax / taxableWithdrawal) * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ],
  );
}

}
