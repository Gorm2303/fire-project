import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TaxWidget extends StatelessWidget {
  final bool showTaxNote;   // Whether to show the tax note

  const TaxWidget({super.key, 
    required this.showTaxNote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conditionally show the tax note
        if (showTaxNote)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the tax note
              const Text(
                'Note: The tax is calculated annually. The first earned 61,000 kr is taxed at 27%, and any amount above that is taxed at 42%. The displayed amount is the monthly tax, calculated based on the following formulars:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // The LaTeX formulas for earnings and tax
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      \text{Taxable Withdrawal} = \text{Earnings Percent} \times \text{Withdrawal Amount}
                      """,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Math.tex(
                      r"""
                      \text{Annual Tax} = 
                      \begin{cases} 
                      0.27 \times \text{Taxable Withdrawal}, & \text{if } \text{Taxable Withdrawal} \leq 61,000 \text{ kr} \\
                      0.27 \times 61,000 + 0.42 \times (\text{Taxable Withdrawal} - 61,000), & \text{if } \text{Taxable Withdrawal} > 61,000 \text{ kr}
                      \end{cases}
                      """,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
    );
  }
}
