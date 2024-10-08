import 'package:flutter/material.dart';

class TaxTypeDropdown extends StatefulWidget {
  final String selectedTaxType;
  final ValueChanged<String?> onTaxTypeChanged;

  const TaxTypeDropdown({
    super.key,
    required this.selectedTaxType,
    required this.onTaxTypeChanged,
  });

  @override
  _TaxTypeDropdownState createState() => _TaxTypeDropdownState();
}

class _TaxTypeDropdownState extends State<TaxTypeDropdown> {
  late String _selectedTaxType;

  @override
  void initState() {
    super.initState();
    _selectedTaxType = widget.selectedTaxType;
  }

  @override
  void didUpdateWidget(covariant TaxTypeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the selected tax type has changed and update the state
    if (oldWidget.selectedTaxType != widget.selectedTaxType) {
      setState(() {
        _selectedTaxType = widget.selectedTaxType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Select Tax Type:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedTaxType,
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
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTaxType = newValue;
              });
              widget.onTaxTypeChanged(newValue);
            }
          },
        ),
      ],
    );
  }
}
