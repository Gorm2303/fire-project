import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class FormulaWidget extends StatelessWidget {
  final double principal;
  final double rate;
  final double time;
  final int compoundingFrequency;
  final double additionalAmount;
  final String contributionFrequency;

  const FormulaWidget({super.key, 
    required this.principal,
    required this.rate,
    required this.time,
    required this.compoundingFrequency,
    required this.additionalAmount,
    required this.contributionFrequency,
  });

  @override
  Widget build(BuildContext context) {
    String fullFormula = _buildFormula();

    return Math.tex(
      fullFormula,
      textStyle: const TextStyle(fontSize: 16),
    );
  }

  // Method to build the dynamic formula text
  String _buildFormula() {
    String fullFormula = '';

    // Step 1: Add principal part if principal > 0
    if (principal > 0) {
      String principalPart = principal.toStringAsFixed(0);
      String ratePart = "\\frac{${(rate / 100).toStringAsFixed(3)}}{$compoundingFrequency}";
      String exponentPart = "^{$compoundingFrequency \\times $time}";
      String mainFormula = "$principalPart \\times (1 + $ratePart)$exponentPart";
      fullFormula += "A = $mainFormula";
    }

    // Step 2: Add contribution part if additionalAmount > 0
    if (additionalAmount > 0) {
      String contributionText = contributionFrequency == 'Monthly'
          ? "12 \\times ${additionalAmount.toStringAsFixed(0)}"
          : additionalAmount.toStringAsFixed(0);
      String ratePart = "\\frac{${(rate / 100).toStringAsFixed(3)}}{$compoundingFrequency}";
      String exponentPart = "^{$compoundingFrequency \\times $time}";
      String contributionFormula = "$contributionText \\times \\frac{\\left( (1 + $ratePart)$exponentPart - 1 \\right)}{$ratePart}";
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
