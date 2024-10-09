import 'package:flutter/material.dart';

class TaxExemptionSwitch extends StatelessWidget {
  final bool useTaxExemptionCard;
  final ValueChanged<bool> onSwitchChanged;

  const TaxExemptionSwitch({
    super.key,
    required this.useTaxExemptionCard,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28, // Set an explicit height to reduce vertical space
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Ensure centering
        children: [
          const Text(
            'Tax Exemption And Progression Limit:', 
            style: TextStyle(fontSize: 14), // Smaller font size for compactness
          ),
          const SizedBox(width: 5), // Reduce the space between text and switch
          Transform.scale(
            scale: 0.6,  // Adjust scale to make Switch smaller
            child: Switch(
              value: useTaxExemptionCard,
              onChanged: onSwitchChanged,
            ),
          ),
        ],
      ),
    );
  }
}
