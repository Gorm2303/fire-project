import 'package:flutter/material.dart';
import '../models/tax_option.dart';

class SwitchAndTaxRate extends StatefulWidget {
  final TextEditingController customTaxController;
  final TaxOption selectedTaxOption;
  final List<TaxOption> taxOptions;
  final VoidCallback recalculateValues;
  final bool isCustom;
  final ValueChanged<bool> onSwitchChanged; // For custom tax switch
  final ValueChanged<TaxOption> onTaxOptionChanged;
  final ValueChanged<bool> onTaxExemptionChanged;

  const SwitchAndTaxRate({
    super.key,
    required this.customTaxController,
    required this.selectedTaxOption,
    required this.taxOptions,
    required this.recalculateValues,
    required this.isCustom,
    required this.onSwitchChanged,
    required this.onTaxOptionChanged,
    required this.onTaxExemptionChanged,
  });

  @override
  _SwitchAndTaxRateState createState() => _SwitchAndTaxRateState();
}

class _SwitchAndTaxRateState extends State<SwitchAndTaxRate> {
  late bool _isActive; // To track if custom tax is active
  late TaxOption _currentTaxOption;
  late String _selectedTaxType; // Tax Type (Capital Gains vs Notional Gains)
  late bool _useTaxExemptionCard; // To track the state of tax exemption switch
  late TaxOption _originalTaxOption; // To preserve the non-custom tax option when switching

  @override
  void initState() {
    super.initState();
    _isActive = widget.isCustom;
    _currentTaxOption = widget.selectedTaxOption;
    _originalTaxOption = widget.selectedTaxOption; // Store the original non-custom option
    _selectedTaxType = widget.selectedTaxOption.isNotionallyTaxed ? 'Notional Gains Tax' : 'Capital Gains Tax';
    _useTaxExemptionCard = widget.selectedTaxOption.useTaxExemptionCardAndThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildCustomTaxSwitch(),
        _buildTaxInputOrDropdown(),
        _buildTaxTypeDropdown(),
        _buildTaxExemptionSwitch(),
      ],
    );
  }

  // Build Dropdown for selecting tax type (Notional vs. Capital)
  Widget _buildTaxTypeDropdown() {
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
                bool isNotionallyTaxed = newValue == 'Notional Gains Tax';
                _currentTaxOption = TaxOption(
                  _currentTaxOption.rate,
                  _currentTaxOption.description,
                  _currentTaxOption.isCustomTaxRule,
                  isNotionallyTaxed,
                  _useTaxExemptionCard,
                );
              });
              widget.onTaxOptionChanged(_currentTaxOption);
              widget.recalculateValues();
            }
          },
        ),
      ],
    );
  }

  // Build Switch for Custom Tax Rate
  Widget _buildCustomTaxSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Custom Tax Rate: ', style: TextStyle(fontSize: 16)),
        Transform.scale(
          scale: 0.6,
          child: Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
                _handleCustomTaxSwitch(value);
              });
              widget.onSwitchChanged(value); // Notify parent
            },
          ),
        ),
      ],
    );
  }

  // Build Tax Rate Input Field or Dropdown based on custom switch state
  Widget _buildTaxInputOrDropdown() {
    return _isActive
        ? SizedBox(
            width: 305,
            child: TextField(
              controller: widget.customTaxController,
              decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  double customTaxRate = double.tryParse(value) ?? 0;
                  setState(() {
                    _currentTaxOption = TaxOption(
                      customTaxRate,
                      'Custom Tax Rate',
                      true,
                      _selectedTaxType == 'Notional Gains Tax',
                      _useTaxExemptionCard,
                    );
                  });
                  widget.onTaxOptionChanged(_currentTaxOption); // Notify parent of change
                  widget.recalculateValues();
                }
              },
            ),
          )
        : DropdownButton<TaxOption>(
            value: _getValidDropdownValue(), // Ensure the value is part of the items
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

                  // Automatically update Tax Type and Tax Exemption based on the preset
                  _selectedTaxType = _currentTaxOption.isNotionallyTaxed ? 'Notional Gains Tax' : 'Capital Gains Tax';
                  _useTaxExemptionCard = _currentTaxOption.useTaxExemptionCardAndThreshold;
                });
                widget.onTaxOptionChanged(_currentTaxOption); // Notify parent of the change
                widget.recalculateValues();
              }
            },
          );
  }

  // Helper method to ensure valid dropdown value
  TaxOption _getValidDropdownValue() {
    if (widget.taxOptions.contains(_currentTaxOption)) {
      return _currentTaxOption;
    } else {
      return widget.taxOptions.first; // Fallback to the first option
    }
  }

  // Build Switch for Tax Exemption
  Widget _buildTaxExemptionSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Use Tax Exemption and progression limit: ', style: TextStyle(fontSize: 16)),
        Transform.scale(
          scale: 0.6,
          child: Switch(
            value: _useTaxExemptionCard,
            onChanged: (value) {
              setState(() {
                _useTaxExemptionCard = value;
                _currentTaxOption = TaxOption(
                  _currentTaxOption.rate,
                  _currentTaxOption.description,
                  _currentTaxOption.isCustomTaxRule,
                  _currentTaxOption.isNotionallyTaxed,
                  _useTaxExemptionCard,
                );
              });
              widget.onTaxExemptionChanged(_useTaxExemptionCard); // Notify parent
              widget.recalculateValues();
            },
          ),
        ),
      ],
    );
  }

  // Update the method that handles the custom tax switch change
  void _handleCustomTaxSwitch(bool isCustom) {
    if (isCustom) {
      double customTaxRate = double.tryParse(widget.customTaxController.text) ?? 0;
      _currentTaxOption = TaxOption(
        customTaxRate, 
        'Custom Tax Rate', 
        true, 
        _selectedTaxType == 'Notional Gains Tax', 
        _useTaxExemptionCard,
      );
    } else {
      // Switch back to the preserved original tax option
      _currentTaxOption = _originalTaxOption;
    }
    widget.onTaxOptionChanged(_currentTaxOption);
    widget.recalculateValues();
  }

}
