import 'package:flutter/material.dart';
import '../../../models/tax_option.dart';

class TaxRateDropdown extends StatefulWidget {
  final TaxOption selectedTaxOption;
  final List<TaxOption> taxOptions;
  final ValueChanged<TaxOption?> onTaxOptionChanged;

  const TaxRateDropdown({
    super.key,
    required this.selectedTaxOption,
    required this.taxOptions,
    required this.onTaxOptionChanged,
  });

  @override
  _TaxRateDropdownState createState() => _TaxRateDropdownState();
}

class _TaxRateDropdownState extends State<TaxRateDropdown> {
  late TaxOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedTaxOption;  // Initialize with the passed selected option
  }

  @override
  void didUpdateWidget(covariant TaxRateDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the selected tax option changes from the parent, update the local state
    if (oldWidget.selectedTaxOption != widget.selectedTaxOption) {
      setState(() {
        _selectedOption = widget.selectedTaxOption;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox( height: 38, // Set an explicit height to reduce vertical space
      child: DropdownButton<TaxOption>(
        value: _selectedOption,
        items: widget.taxOptions.map((TaxOption option) {
          return DropdownMenuItem<TaxOption>(
            value: option,
            child: Text('${option.ratePercentage}% - ${option.description}'),
          );
        }).toList(),
        onChanged: (newOption) {
          if (newOption != null) {
            setState(() {
              _selectedOption = newOption;  // Update the local state to reflect the new selection
            });
            widget.onTaxOptionChanged(newOption);  // Notify the parent widget of the change
          }
        },
      ),
    );
  }
}
