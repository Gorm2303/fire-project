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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Tax Type:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10), // Reduce horizontal space
        SizedBox(
          height: 38, // Adjust height to reduce vertical space
          child: DropdownButton<String>(
            value: _selectedTaxType,
            iconSize: 16,  // Reduce the dropdown icon size
            style: const TextStyle(fontSize: 16),  // Control text style
            items: const [
              DropdownMenuItem(
                value: 'Capital Gains Tax',
                child: Text('Capital Gains Tax', style: TextStyle(fontSize: 16)),
              ),
              DropdownMenuItem(
                value: 'Notional Gains Tax',
                child: Text('Notional Gains Tax', style: TextStyle(fontSize: 16)),
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
        ),
      ],
    );
  }
}
