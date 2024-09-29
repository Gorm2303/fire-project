import 'package:flutter/material.dart';
import '../models/tax_option.dart';

class TaxExemptionSwitch extends StatefulWidget {
  final TaxOption selectedTaxOption;
  final VoidCallback recalculateValues;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<TaxOption> onTaxOptionChanged;  // Callback for custom or predefined tax option

  const TaxExemptionSwitch({
    super.key,
    required this.selectedTaxOption,
    required this.recalculateValues,
    required this.onSwitchChanged,
    required this.onTaxOptionChanged,
  });

  @override
  _SwitchAndTaxRateState createState() => _SwitchAndTaxRateState();
}

class _SwitchAndTaxRateState extends State<TaxExemptionSwitch> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    // Initialize the switch state based on the provided tax option's exemption card usage
    _isActive = widget.selectedTaxOption.useTaxExemptionCardAndThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Use Tax Exemption Card and Threshold:',
              style: TextStyle(fontSize: 16),
            ),
            Transform.scale(
              scale: 0.6,
              child: Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;  // Update local state
                  });

                  // Notify the parent widget that the switch state has changed
                  widget.onSwitchChanged(value);

                  // Create a new TaxOption with the updated `useTaxExemptionCardAndThreshold` value
                  TaxOption updatedTaxOption = TaxOption(
                    widget.selectedTaxOption.rate,
                    widget.selectedTaxOption.description,
                    widget.selectedTaxOption.isCustomTaxRule,
                    widget.selectedTaxOption.isNotionallyTaxed,
                    _isActive,  // Updated value from the switch
                  );

                  // Notify parent about the updated tax option
                  widget.onTaxOptionChanged(updatedTaxOption);

                  // Trigger recalculation
                  widget.recalculateValues();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
