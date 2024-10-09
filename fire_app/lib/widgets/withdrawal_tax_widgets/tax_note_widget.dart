import 'package:fire_app/widgets/wrappers/math_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TaxNoteWidget extends StatelessWidget {
  final bool showTaxNote; // Whether to show the tax note
  final Widget earningsWithdrawalRatio;

  // Constructor with required parameters
  const TaxNoteWidget({
    super.key,
    required this.showTaxNote,
    required this.earningsWithdrawalRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conditionally show the tax note
        if (showTaxNote)
          Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the column content
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 750, // Set the maximum width constraint
                ),
                child: const Text(
                  'Note: The tax is calculated on an annual basis. Tax is only calculated on the earnings, which means deposits are not taxed. Every person in Denmark has a tax exemption card of 49700 kr (in 2024) per year. The first earned 61,000 kr (in 2024) is taxed at 27%, and any amount above that is taxed at 42%. The displayed amount is the monthly tax, calculated based on the following formulas:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              MathWrapper(
                rightBoundaryMargin: 205,
                children: [
                  Math.tex(
                    r"""
                    \text{Earnings} = \text{Total Value} - \text{Total Deposits}
                    """,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Math.tex(
                    r"""
                    \text{Earnings percent} = \frac{\text{Earnings}}{\text{Total Value}}
                    """,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Math.tex(
                    r"""
                    \text{Taxable Withdrawal} = \text{Earnings Percent} \times \text{Withdrawal Amount} - 49700, \ \ \text{Tax Exemption Card} = 49700
                    """,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Math.tex(
                    r"""
                    \text{Annual Tax} = 
                    \begin{cases} 
                    0.27 \times \text{Taxable Withdrawal}, & \text{if } \text{Taxable Withdrawal} \leq 61000 \\ 
                    0.27 \times 61000 + 0.42 \times (\text{Taxable Withdrawal} - 61000), & \text{if } \text{Taxable Withdrawal} > 61000
                    \end{cases}
                    """,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Display earningsWithdrawalRatio widget below the formulas
              earningsWithdrawalRatio,
            ],
          ),
      ],
    );
  }
}
