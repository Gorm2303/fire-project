import 'package:flutter/material.dart';
import 'custom_tax_switch.dart';
import 'tax_rate_dropdown.dart';
import 'tax_exemption_switch.dart';
import 'tax_type_dropdown.dart';
import '../models/tax_option.dart';
import '../services/tax_option_manager.dart';

class SwitchAndTaxRate extends StatefulWidget {
  final TextEditingController customTaxController;
  final TaxOptionManager taxOptionManager; // Pass the manager
  final VoidCallback recalculateValues;

  const SwitchAndTaxRate({
    super.key,
    required this.customTaxController,
    required this.taxOptionManager,
    required this.recalculateValues,
  });

  @override
  _SwitchAndTaxRateState createState() => _SwitchAndTaxRateState();
}

class _SwitchAndTaxRateState extends State<SwitchAndTaxRate> {
  late TaxOptionManager _taxOptionManager;
  late String _selectedTaxType;
  late bool _useTaxExemptionCard;

  @override
  void initState() {
    super.initState();
    _taxOptionManager = widget.taxOptionManager;
    _selectedTaxType = _taxOptionManager.currentOption.isNotionallyTaxed ? 'Notional Gains Tax' : 'Capital Gains Tax';
    _useTaxExemptionCard = _taxOptionManager.currentOption.useTaxExemptionCardAndThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomTaxSwitch(
          isCustom: _taxOptionManager.isCustomTaxRate, // Use custom tax rate
          onSwitchChanged: (bool value) {
            setState(() {
              if (value) {
                // Switch to custom tax rate
                _taxOptionManager.switchToCustomRate(
                  double.tryParse(widget.customTaxController.text) ?? _taxOptionManager.currentOption.ratePercentage,
                  _taxOptionManager.currentOption.isNotionallyTaxed,
                  _taxOptionManager.currentOption.useTaxExemptionCardAndThreshold,
                );
              } else {
                  // Switch back to the last predefined option
                  _taxOptionManager.switchBackToLastPredefined();
              }
              _selectedTaxType = _taxOptionManager.currentOption.isNotionallyTaxed ? 'Notional Gains Tax' : 'Capital Gains Tax';
              _useTaxExemptionCard = _taxOptionManager.currentOption.useTaxExemptionCardAndThreshold;
            });
            widget.recalculateValues();
          },
        ),
        _taxOptionManager.isCustomTaxRate
            ? SizedBox(
                width: 305,
                child: TextField(
                  controller: widget.customTaxController,
                  decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        double customTaxRate = double.tryParse(value) ?? _taxOptionManager.currentOption.ratePercentage;
                        _taxOptionManager.switchToCustomRate(
                          customTaxRate,
                          _taxOptionManager.currentOption.isNotionallyTaxed,
                          _taxOptionManager.currentOption.useTaxExemptionCardAndThreshold,
                        );
                      });
                      widget.recalculateValues();
                    }
                  },
                ),
              )
            : TaxRateDropdown(
                selectedTaxOption: _taxOptionManager.currentOption,
                taxOptions: _taxOptionManager.allTaxOptions, // Includes "Custom" if active
                onTaxOptionChanged: (TaxOption? newOption) {
                  if (newOption != null) {
                    setState(() {
                      _taxOptionManager.switchToPredefined(newOption);
                      _selectedTaxType = newOption.isNotionallyTaxed ? 'Notional Gains Tax' : 'Capital Gains Tax';
                      _useTaxExemptionCard = newOption.useTaxExemptionCardAndThreshold;
                    });
                    widget.recalculateValues();
                  }
                },
              ),
        TaxTypeDropdown(
          selectedTaxType: _selectedTaxType,
          onTaxTypeChanged: (String? newTaxType) {
            if (newTaxType != null) {
              setState(() {
                _selectedTaxType = newTaxType;
                _taxOptionManager.toggleTaxType(newTaxType == 'Notional Gains Tax');
              });
              widget.recalculateValues();
            }
          },
        ),
        TaxExemptionSwitch(
          useTaxExemptionCard: _useTaxExemptionCard,
          onSwitchChanged: (bool value) {
            setState(() {
              _useTaxExemptionCard = value;
              _taxOptionManager.toggleTaxExemption(value);
            });
            widget.recalculateValues();
          },
        ),
      ],
    );
  }
}
