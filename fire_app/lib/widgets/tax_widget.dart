import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:fire_app/widgets/earnings_withdrawal_ratio.dart';
class TaxWidget extends StatelessWidget {
  final bool showTaxNote;   // Whether to show the tax note
  final double totalAfterBreak;  // Use final and set through constructor
  final double withdrawalAmount; // Use final and set through constructor
  final double totalDeposits; // Use final and set through constructor

  // Constructor with default values for totalAfterBreak and withdrawalAmount
  const TaxWidget({
    super.key, 
    required this.showTaxNote,
    required this.totalAfterBreak,   // Default value of 0.0
    required this.withdrawalAmount,  // Default value of 0.0
    required this.totalDeposits,  // Default value of 0.0
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
              const Text(
                'Note: The tax is calculated on an annually basis, tax is only calculated on the earnings which means deposits are not taxed. The first earned 61,000 kr is taxed at 27%, and any amount above that is taxed at 42%. The displayed amount is the monthly tax, calculated based on the following formulas:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
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
                      0.27 \times \text{Taxable Withdrawal}, & \text{if } \text{Taxable Withdrawal} \leq 61,000 \\ 
                      0.27 \times 61,000 + 0.42 \times (\text{Taxable Withdrawal} - 61,000), & \text{if } \text{Taxable Withdrawal} > 61,000
                      \end{cases}
                      """,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Add the renamed widget below the formulas
              EarningsWithdrawalRatio(
                totalAfterBreak: totalAfterBreak,
                totalDeposits: totalDeposits,
                withdrawalAmount: withdrawalAmount,
              ),
            ],
          ),
        ],
    );
  }
}
