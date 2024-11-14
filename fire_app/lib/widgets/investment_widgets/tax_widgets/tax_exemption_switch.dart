import 'package:flutter/material.dart';

class TaxExemptionSwitch extends StatelessWidget {
  final bool useTaxExemptionCard;
  final bool useTaxProgressionLimit;
  final ValueChanged<bool> onExemptionSwitchChanged;
  final ValueChanged<bool> onProgressionSwitchChanged;

  const TaxExemptionSwitch({
    super.key,
    required this.useTaxExemptionCard,
    required this.useTaxProgressionLimit,
    required this.onExemptionSwitchChanged,
    required this.onProgressionSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 28, // Set an explicit height to reduce vertical space
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Ensure centering
            children: [
              const Text(
                'Tax Exemption Card:',
                style: TextStyle(fontSize: 16), // Smaller font size for compactness
              ),
              Transform.scale(
                scale: 0.6,  // Adjust scale to make Switch smaller
                child: Switch(
                  value: useTaxExemptionCard,
                  onChanged: onExemptionSwitchChanged,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 28, // Set an explicit height to reduce vertical space
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Ensure centering
            children: [
              const Text(
                'Tax Progression Limit:',
                style: TextStyle(fontSize: 16), // Smaller font size for compactness
              ),
              Transform.scale(
                scale: 0.6,  // Adjust scale to make Switch smaller
                child: Switch(
                  value: useTaxProgressionLimit,
                  onChanged: onProgressionSwitchChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
