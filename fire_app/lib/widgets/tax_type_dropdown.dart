// lib/widgets/tax_type_dropdown.dart

import 'package:flutter/material.dart';

class TaxTypeDropdown extends StatelessWidget {
  final String selectedTaxType;
  final ValueChanged<String?> onTaxTypeChanged;
  final bool isDisabled;

  const TaxTypeDropdown({
    super.key,
    required this.selectedTaxType,
    required this.onTaxTypeChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Select Tax Type:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: selectedTaxType,
          items: const [
            DropdownMenuItem(
              value: 'Capital Gains Tax',
              child: Text('Capital Gains Tax'),
            ),
            DropdownMenuItem(
              value: 'Notional Gains Tax',
              child: Text('Notional Gains Tax'),
            ),
          ],
          onChanged: isDisabled
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    onTaxTypeChanged(newValue);
                  }
                },
        ),
      ],
    );
  }
}
