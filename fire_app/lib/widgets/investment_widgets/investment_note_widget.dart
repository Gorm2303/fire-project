import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:fire_app/widgets/investment_widgets/formula_widget.dart';
import 'package:fire_app/widgets/investment_widgets/investment_compounding_results_widget.dart';
import 'package:fire_app/widgets/wrappers/math_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class InvestmentNoteWidget extends StatelessWidget {
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

  const InvestmentNoteWidget({
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
        if (showInvestmentNote) _buildInvestmentDetails(context),
      ],
    );
  }

  // Builds the detailed investment section including math formulas
  Widget _buildInvestmentDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxWidth: 760),
          child: const Text(
            'Note: The total investment value is calculated by compounding the principal and monthly contributions separately. Each monthly contribution is compounded for the remaining months in the year, while the principal is compounded for the full year. The formulas used for this are displayed below.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        _buildMathTexWidget(),
        const SizedBox(height: 8),
        // Add the widget that displays the investment contribution ratio
        InvestmentCompoundingResults(
          totalDeposits: totalDeposits,
          totalValue: totalValue,
          totalInterestFromPrincipal: totalInterestFromPrincipal,
          totalInterestFromContributions: totalInterestFromContributions,
          compoundEarnings: compoundEarnings,
          tax: tax,
        ),
      ],
    );
  }

  // MathTeX formulas as part of the investment explanation
  Widget _buildMathTexWidget() {
    return MathWrapper(
      rightBoundaryMargin: 415,
      children: [
        Math.tex(
          r"""
          \text{Principal and Compound Interest} = \text{Principal} \times (1 + \text{Interest Rate})^\text{Years}
          """,
          textStyle: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Math.tex(
          r"""
          \text{Monthly Interest Rate} = \frac{\text{Interest Rate}}{12}
          """,
          textStyle: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Math.tex(
          r"""
          \text{Remaining Year Fraction} = \frac{12 - \text{Month No.}}{12}
          """,
          textStyle: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Math.tex(
          r"""
          \text{Monthly Contributions and Compound Interest} = \sum_{\text{t}=1}^{\text{Years}} \sum_{\text{Month No.}=1}^{12} \text{Monthly Contribution} \times \left(1 + \frac{\text{Interest Rate}}{12} \times \frac{12 - \text{Month No.}}{12}\right)^\text{Years - t}
          """,
          textStyle: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Math.tex(
          r"""
          \text{Total Investment} = \text{Principal and Compound Interest} + \text{Monthly Contributions and Compound Interest}
          """,
          textStyle: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
