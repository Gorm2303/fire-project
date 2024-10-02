// lib/widgets/tax_rate_dropdown.dart

import 'package:flutter/material.dart';
import '../models/tax_option.dart';

class TaxRateDropdown extends StatelessWidget {
  final TaxOption selectedTaxOption;
  final List<TaxOption> taxOptions;
  final ValueChanged<TaxOption?>? onTaxOptionChanged;

  const TaxRateDropdown({
    super.key,
    required this.selectedTaxOption,
    required this.taxOptions,
    required this.onTaxOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TaxOption>(
      value: selectedTaxOption,
      items: taxOptions.map((TaxOption option) {
        return DropdownMenuItem<TaxOption>(
          value: option,
          child: Text('${option.ratePercentage}% - ${option.description}'),
        );
      }).toList(),
      onChanged: onTaxOptionChanged,
    );
  }
}
