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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Tax Type:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        SizedBox(
          height: 38,
          child: DropdownButton<String>(
            value: _selectedTaxType,
            iconSize: 16,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black, // Set text color based on theme
            ),
            dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white, // Set dropdown background color
            items: [
              DropdownMenuItem(
                value: 'Capital Gains Tax',
                child: Text(
                  'Capital Gains Tax',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black, // Match text color to theme
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'Notional Gains Tax',
                child: Text(
                  'Notional Gains Tax',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
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
