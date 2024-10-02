// lib/widgets/custom_tax_switch.dart

import 'package:flutter/material.dart';

class CustomTaxSwitch extends StatelessWidget {
  final bool isCustom;
  final ValueChanged<bool> onSwitchChanged;

  const CustomTaxSwitch({
    super.key,
    required this.isCustom,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Custom Tax Rate: ', style: TextStyle(fontSize: 16)),
        Switch(
          value: isCustom,
          onChanged: onSwitchChanged,
        ),
      ],
    );
  }
}
