import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:fire_app/widgets/investment_widgets/formula_widget.dart';
import 'package:flutter/material.dart';

class InvestmentCalculationWidget extends StatelessWidget {
  final bool showInvestmentNote;  // Whether to show the investment note
  final double totalDeposits;
  final double totalValue;
  final double totalInterestFromPrincipal;
  final double totalInterestFromContributions;
  final double compoundEarnings;
  final double tax;
  final int duration; // Add duration to handle the time-based logic
  final VoidCallback toggleInvestmentNote;  // Callback to handle toggling
  final FormulaWidget formulaWidget;

  const InvestmentCalculationWidget({
    super.key, 
    required this.showInvestmentNote, 
    required this.totalDeposits,
    required this.totalValue,
    required this.totalInterestFromPrincipal,
    required this.totalInterestFromContributions,
    required this.compoundEarnings,
    required this.tax,
    required this.duration,
    required this.toggleInvestmentNote, 
    required this.formulaWidget,
  });

  @override
  Widget build(BuildContext context) {
    double compoundEarningsOverDeposits = totalDeposits != 0 ? (compoundEarnings / totalDeposits * 100) : 0;
    return CardWrapper(
      title: 'Investment Calculation',
      children: [
        formulaWidget,
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: toggleInvestmentNote,  // Toggle the investment note
              child: const Text(
                'Investment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' After $duration Years: ${totalValue.toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        Text('Earnings compared to deposits: ${compoundEarningsOverDeposits.toStringAsFixed(2)}%'),
        // Conditionally show the detailed investment note
      ],
    );
  }
}
