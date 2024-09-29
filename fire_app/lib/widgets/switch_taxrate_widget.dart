import 'package:flutter/material.dart';
import '../models/tax_option.dart';

class SwitchAndTaxRate extends StatefulWidget {
  final TextEditingController customTaxController;
  final TaxOption selectedTaxOption;
  final List<TaxOption> taxOptions;
  final VoidCallback recalculateValues;
  final bool isCustom;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<TaxOption> onTaxOptionChanged;  // Callback for custom or predefined tax option

  const SwitchAndTaxRate({
    super.key,
    required this.customTaxController,
    required this.selectedTaxOption,
    required this.taxOptions,
    required this.recalculateValues,
    required this.isCustom,
    required this.onSwitchChanged,
    required this.onTaxOptionChanged,
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
            const Text(
              'Custom Tax Rate: ',
              style: TextStyle(fontSize: 16),
            ),
            Transform.scale(
              scale: 0.6,
              child: Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                    if (_isActive) {
                      // If custom is active, create a new custom tax option
                      double customTaxRate = double.tryParse(widget.customTaxController.text) ?? 0;
                      _currentTaxOption = TaxOption(customTaxRate, 'Custom Tax Rate', true, false, true);
                      widget.onTaxOptionChanged(_currentTaxOption);
                    } else {
                      // If custom is inactive, reset to selected dropdown option
                      _currentTaxOption = widget.taxOptions.first;
                      widget.onTaxOptionChanged(_currentTaxOption);
                    }
                  });
                  widget.onSwitchChanged(value);
                  widget.recalculateValues();
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
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      // Update custom tax option when input changes
                      double customTaxRate = double.tryParse(value) ?? 0;
                      setState(() {
                        _currentTaxOption = TaxOption(customTaxRate, 'Custom Tax Rate', true, false, true);
                      });
                      widget.onTaxOptionChanged(_currentTaxOption);
                      widget.recalculateValues();
                    }
                  },
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
                    widget.onTaxOptionChanged(newValue);  // Notify parent of change
                    widget.recalculateValues();
                  }
                },
              ),
      ],
    );
  }
}
