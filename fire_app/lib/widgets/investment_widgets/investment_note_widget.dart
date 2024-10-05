import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class InvestmentNoteWidget extends StatelessWidget {
  final bool showInvestmentNote;   // Whether to show the investment note
  final Widget investmentCompoundingResults;  // Widget to display the investment contribution ratio

  // Constructor for InvestmentNoteWidget
  const InvestmentNoteWidget({
    super.key, 
    required this.showInvestmentNote, 
    required this.investmentCompoundingResults,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conditionally show the investment note
        if (showInvestmentNote)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Center the column content
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 760, // Set the maximum width constraint
                ),
                child: const Text(
                  'Note: The total investment value is calculated by compounding the principal and monthly contributions separately. Each monthly contribution is compounded for the remaining months in the year, while the principal is compounded for the full year. The formulas used for this are displayed below.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
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
              ),
              const SizedBox(height: 8),
              // Add the widget that displays the investment contribution ratio
              investmentCompoundingResults,
            ],
          ),
      ],
    );
  }
}
