import 'package:flutter/material.dart';

class EarningsWithdrawalRatio extends StatelessWidget {
  final double earnings;
  final double earningsPercent;
  final double taxableWithdrawal;
  final double annualTax;


  const EarningsWithdrawalRatio({
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
        Text('Taxable Withdrawal (Annual): ${taxableWithdrawal.toStringAsFixed(0)}'),
        const SizedBox(width: 8), // Add some spacing between the texts
        Text('Taxable Withdrawal (Monthly): ${(taxableWithdrawal / 12).toStringAsFixed(0)}'),
        Text('Tax (Annual): ${annualTax.toStringAsFixed(0)}'),
        const SizedBox(width: 8), // Add some spacing between the texts
        Text('Tax (Monthly): ${(annualTax / 12).toStringAsFixed(0)}'),
      ],
    );
  }
}
