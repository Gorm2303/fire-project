import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompoundingResults extends StatelessWidget {
  final double totalDeposits;
  final double totalValue;
  final double totalInterestFromPrincipal;
  final double totalInterestFromContributions;
  final double compoundEarnings;
  final double tax;

  const CompoundingResults({
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
        Text('Total Deposits: ${NumberFormat('###,###').format(totalDeposits)}'),
        Text('Compound Interest from Principal: ${NumberFormat('###,###').format(totalInterestFromPrincipal)}'),
        Text('Compound Interest from Contributions: ${NumberFormat('###,###').format(totalInterestFromContributions)}'),
        Text('Tax on Compound Interest: ${NumberFormat('###,###').format(tax)}'),
        Text('Total Compound Interest: ${NumberFormat('###,###').format(compoundEarnings)}'),
        Text('Total Investment Value: ${NumberFormat('###,###').format(totalValue)}'),
      ],
    );
  }
}
