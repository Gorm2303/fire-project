import 'package:flutter/material.dart';

class EarningsWithdrawalRatio extends StatelessWidget {
  final double totalAfterBreak;
  final double withdrawalAmount;
  final double totalDeposits;

  const EarningsWithdrawalRatio({
    super.key,
    required this.totalAfterBreak,
    required this.withdrawalAmount, 
    required this.totalDeposits,
  });

  @override
  Widget build(BuildContext context) {
    // Step 1: Calculate Earnings
    double earnings = totalAfterBreak - totalDeposits;

    // Step 2: Calculate Earnings Percent
    double earningsPercent = earnings / totalAfterBreak;

    // Step 3: Calculate Taxable Withdrawal
    double taxableWithdrawal = earningsPercent * withdrawalAmount;

    // Step 4: Calculate Annual Tax
    double annualTax;
    if (taxableWithdrawal <= 61000) {
      annualTax = taxableWithdrawal * 0.27;
    } else {
      annualTax = (61000 * 0.27) + ((taxableWithdrawal - 61000) * 0.42);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tax Calculation Results:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Total Earnings: ${earnings.toStringAsFixed(0)}'),
        Text('Earnings Percent: ${(earningsPercent * 100).toStringAsFixed(2)}%'),
        Row(
          children: [
            Text('Taxable Annual Withdrawal: ${taxableWithdrawal.toStringAsFixed(0)}'),
            const SizedBox(width: 8), // Add some spacing between the texts
            Text('Taxable Monthly Withdrawal: ${(taxableWithdrawal / 12).toStringAsFixed(0)}'),
          ],
        ),
        Row(
          children: [
            Text('Annual Tax: ${annualTax.toStringAsFixed(0)}'),
            const SizedBox(width: 8), // Add some spacing between the texts
            Text('Monthly Tax: ${(annualTax / 12).toStringAsFixed(0)}'),
          ],
        ),
      ],
    );
  }
}
