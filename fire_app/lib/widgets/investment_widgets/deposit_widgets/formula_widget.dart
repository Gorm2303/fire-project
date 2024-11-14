import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class FormulaWidget extends StatelessWidget {
  final double principal;
  final double interestRate;
  final double duration;
  final double additionalAmount;
  final String contributionFrequency;

  const FormulaWidget({
    super.key,
    required this.principal,
    required this.interestRate,
    required this.duration,
    required this.additionalAmount,
    required this.contributionFrequency,
  });

  @override
  Widget build(BuildContext context) {
    String fullFormula = _buildFormula();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      child: Math.tex(
        fullFormula,
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  // Method to build the dynamic formula text
  String _buildFormula() {
    String fullFormula = '';

    // Step 1: Add principal part if principal > 0
    if (principal > 0) {
      String principalPart = principal.toStringAsFixed(0);
      String ratePart = (interestRate / 100).toStringAsFixed(3);
      String exponentPart = "^{$duration}";
      String mainFormula = "$principalPart \\times (1 + $ratePart)$exponentPart";
      fullFormula += "A = $mainFormula";
    }

    // Step 2: Add contribution part if additionalAmount > 0
    if (additionalAmount > 0 && contributionFrequency == 'Monthly') {
      String contributionText = additionalAmount.toStringAsFixed(0);
      String ratePart = (interestRate / 100).toStringAsFixed(3);

      // Corrected monthly contributions with remaining months' interest over `t` years
      String monthlyContributionFormula =
        "\\sum_{t=1}^{$duration} \\sum_{k=1}^{12} $contributionText \\times \\left(1 + \\frac{$ratePart}{12} \\times \\frac{12 - k}{12}\\right)^{$duration - t}";

      if (fullFormula.isNotEmpty) {
        fullFormula += " + ";
      } else {
        fullFormula = "A = ";
      }
      fullFormula += monthlyContributionFormula;
    } else if (additionalAmount > 0 && contributionFrequency == 'Yearly') {
      // Handle yearly contributions (unchanged)
      String contributionText = additionalAmount.toStringAsFixed(0);
      String ratePart = (interestRate / 100).toStringAsFixed(3);
      String exponentPart = "^{$duration}";

      String contributionFormula =
          "$contributionText \\times \\frac{(1 + $ratePart)$exponentPart - 1}{$ratePart}";

      if (fullFormula.isNotEmpty) {
        fullFormula += " + ";
      } else {
        fullFormula = "A = ";
      }
      fullFormula += contributionFormula;
    }

    // If both are zero, show nothing
    if (fullFormula.isEmpty) {
      fullFormula = "A = 0";
    }

    return fullFormula;
  }
}
