import 'package:flutter/material.dart';

class InvestmentCompoundingResults extends StatelessWidget {
  final double totalDeposits;
  final double totalValue;
  final double totalInterestFromPrincipal;
  final double totalInterestFromContributions;
  final double compoundEarnings;
  final double tax;

  const InvestmentCompoundingResults({
    super.key, 
    required this.totalDeposits, 
    required this.totalValue, 
    required this.totalInterestFromPrincipal, 
    required this.totalInterestFromContributions,
    required this.compoundEarnings,
    required this.tax,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,  // Center the column content
      children: [
        const Text(
          'Investment Calculation Results:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Total Deposits: ${totalDeposits.toStringAsFixed(0)}'),
        Text('Compound Interest from Principal: ${totalInterestFromPrincipal.toStringAsFixed(0)}'),
        Text('Compound Interest from Contributions: ${totalInterestFromContributions.toStringAsFixed(0)}'),
        Text('Tax on Compound Interest: ${tax.toStringAsFixed(2)}'),
        Text('Total Compound Interest: ${compoundEarnings.toStringAsFixed(0)}'),
        Text('Total Investment Value: ${totalValue.toStringAsFixed(0)}'),
      ],
    );
  }
}
