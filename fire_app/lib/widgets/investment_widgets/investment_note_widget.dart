import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'investment_compounding_results_widget.dart'; // Assuming you have this class separately

class InvestmentNoteWidget extends StatelessWidget {
  final double totalDeposits;
  final double totalValue;
  final double totalInterestFromPrincipal;
  final double totalInterestFromContributions;
  final double compoundEarnings;
  final double tax;

  const InvestmentNoteWidget({
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
        // Widget displaying investment contribution ratio
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}
