import 'package:flutter/material.dart';
import '../models/tax_option.dart';

class NotionalGainsTaxWidget extends StatefulWidget {
  final TaxOption selectedTaxOption;
  final VoidCallback recalculateValues;
  final ValueChanged<String> onTaxTypeChanged;  // Change to ValueChanged<String> for dropdown

  const NotionalGainsTaxWidget({
    super.key,
    required this.selectedTaxOption,
    required this.recalculateValues,
    required this.onTaxTypeChanged,  // Rename to onTaxTypeChanged for clarity
  });

  @override
  _NotionalGainsTaxWidgetState createState() => _NotionalGainsTaxWidgetState();
}

class _NotionalGainsTaxWidgetState extends State<NotionalGainsTaxWidget> {
  late String _selectedTaxType;

  @override
  void initState() {
    super.initState();
    // Initialize selected tax type based on the current selectedTaxOption
    _selectedTaxType = widget.selectedTaxOption.isNotionallyTaxed ? 'Notional Gains Tax' : 'Capital Gains Tax';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          value: _selectedTaxType,
          items: const [
            DropdownMenuItem(
              value: 'Capital Gains Tax',
              child: Text('Tax On Capital Gains'),
            ),
            DropdownMenuItem(
              value: 'Notional Gains Tax',
              child: Text('Tax On Yearly Notional Gains'),
            ),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTaxType = newValue;
              });
              widget.onTaxTypeChanged(newValue);  // Notify parent widget of the tax type change
              widget.recalculateValues();          // Trigger recalculation
            }
          },
        ),
      ],
    );
  }
}
