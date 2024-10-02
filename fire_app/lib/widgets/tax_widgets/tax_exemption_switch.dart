// lib/widgets/tax_exemption_switch.dart

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Use Tax Exemption And Progression Limit:', style: TextStyle(fontSize: 16)),
        Transform.scale(
          scale: 0.6,
          child: Switch(
            value: useTaxExemptionCard,
            onChanged: onSwitchChanged,
          ),
        ),
      ],
    );
  }
}
