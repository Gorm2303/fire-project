import 'package:flutter/material.dart';

class TaxCalculationResults extends StatelessWidget {
  final double earnings;
  final double earningsPercent;
  final double taxableWithdrawal;
  final double annualTax;


  const TaxCalculationResults({
    super.key, 
    required this.earnings, 
    required this.earningsPercent, 
    required this.taxableWithdrawal, 
    required this.annualTax,

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
        Text('Earnings (Total): ${earnings.toStringAsFixed(0)}'),
        Text('Earnings (Percent): ${(earningsPercent * 100).toStringAsFixed(2)}%'),
        Text('Taxable Withdrawal (Yearly): ${taxableWithdrawal.toStringAsFixed(0)}'),
        Text('Taxable Withdrawal (Monthly): ${(taxableWithdrawal / 12).toStringAsFixed(0)}'),
        Text('Tax (Yearly): ${annualTax.toStringAsFixed(0)}'),
        Text('Tax (Monthly): ${(annualTax / 12).toStringAsFixed(0)}'),
        Text('Actual Tax Rate: ${(annualTax / taxableWithdrawal * 100).toStringAsFixed(2)}%'),
      ],
    );
  }
}
