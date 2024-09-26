import 'package:flutter/material.dart';
import '../models/tax_option.dart';

class SwitchAndTaxRate extends StatefulWidget {
  final TextEditingController customTaxController;
  final TaxOption selectedTaxOption;
  final List<TaxOption> taxOptions;
  final VoidCallback recalculateValues;
  final bool isCustom;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<TaxOption> onTaxOptionChanged;  // Add this callback

  const SwitchAndTaxRate({
    super.key,
    required this.customTaxController,
    required this.selectedTaxOption,
    required this.taxOptions,
    required this.recalculateValues,
    required this.isCustom,
    required this.onSwitchChanged,
    required this.onTaxOptionChanged,  // Initialize the new callback in the constructor
  });

  @override
  _SwitchAndTaxRateState createState() => _SwitchAndTaxRateState();
}

class _SwitchAndTaxRateState extends State<SwitchAndTaxRate> {
  late bool _isActive;
  late TaxOption _currentTaxOption;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isCustom;
    _currentTaxOption = widget.selectedTaxOption;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Custom Tax Rate: ${_isActive ? 'Active' : 'Inactive'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 20),
            Transform.scale(
              scale: 0.6,
              child: Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                  widget.onSwitchChanged(value);
                },
              ),
            ),
          ],
        ),
        _isActive
            ? SizedBox(
                width: 305,
                child: TextField(
                  controller: widget.customTaxController,
                  decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => widget.recalculateValues(),
                ),
              )
            : DropdownButton<TaxOption>(
                value: _currentTaxOption,
                items: widget.taxOptions.map((TaxOption option) {
                  return DropdownMenuItem<TaxOption>(
                    value: option,
                    child: Text('${option.rate}% - ${option.description}'),
                  );
                }).toList(),
                onChanged: (TaxOption? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentTaxOption = newValue;
                    });
                    widget.onTaxOptionChanged(newValue);  // Call the new callback here
                  }
                },
              ),
      ],
    );
  }
}
