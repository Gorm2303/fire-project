import 'package:fire_app/models/tax_option.dart';
import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:fire_app/widgets/wrappers/textfield_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'custom_tax_switch.dart';
import 'tax_rate_dropdown.dart';
import 'tax_exemption_switch.dart';
import 'tax_type_dropdown.dart';
import '../../services/tax_option_manager.dart';

class TaxRateWidget extends StatelessWidget {
  final TextEditingController customTaxController;
  final VoidCallback recalculateValues;

  const TaxRateWidget({
    super.key,
    required this.customTaxController,
    required this.recalculateValues,
  });

  @override
  Widget build(BuildContext context) {
    // Using Consumer to listen to TaxOptionManager updates
    return Consumer<TaxOptionManager>(
      builder: (context, taxOptionManager, child) {
        return CardWrapper(
          title: 'Tax Options',
          children: [
            // Custom Tax Switch
            _buildCustomTaxSwitch(taxOptionManager),

            // Display custom tax rate input when custom rate is selected
            taxOptionManager.isCustomTaxRate
                ? _buildCustomTaxRateInput(taxOptionManager)
                : _buildTaxRateDropdown(taxOptionManager),

            // Tax Type Dropdown
            _buildTaxTypeDropdown(taxOptionManager),

            // Tax Exemption Switch
            _buildTaxExemptionSwitch(taxOptionManager),
          ],
        );          
      }
    );
  }


  Widget _buildCustomTaxRateInput(TaxOptionManager taxOptionManager) {
    return TextFieldWrapper( 
      children: [ 
        TextField(
          controller: customTaxController,
          decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
          keyboardType: TextInputType.number,
          onChanged: (String value) {
            if (value.isNotEmpty) {
              taxOptionManager.switchToCustomRate(
                double.tryParse(value) ?? taxOptionManager.currentOption.ratePercentage,
                taxOptionManager.currentOption.isNotionallyTaxed,
                taxOptionManager.currentOption.useTaxExemptionCard,
                taxOptionManager.currentOption.useTaxProgressionLimit,
              );
            }
            recalculateValues(); // Recalculate after tax rate change
          },
        ),
      ]
    );
  }

  Widget _buildCustomTaxSwitch(TaxOptionManager taxOptionManager) {
    return CustomTaxSwitch(
      isCustom: taxOptionManager.isCustomTaxRate,
      onSwitchChanged: (bool value) {
        if (value) {
          taxOptionManager.switchToCustomRate(
            double.tryParse(customTaxController.text) ?? taxOptionManager.currentOption.ratePercentage,
            taxOptionManager.currentOption.isNotionallyTaxed,
            taxOptionManager.currentOption.useTaxExemptionCard,
            taxOptionManager.currentOption.useTaxProgressionLimit,
          );
        } else {
          taxOptionManager.switchBackToLastPredefined();
        }
        recalculateValues(); // Recalculate values after changing tax rate
      },
    );
  }

  Widget _buildTaxExemptionSwitch(TaxOptionManager taxOptionManager) {
    return TaxExemptionSwitch(
      useTaxExemptionCard: taxOptionManager.currentOption.useTaxExemptionCard,
      useTaxProgressionLimit: taxOptionManager.currentOption.useTaxProgressionLimit, // Add this line
      onExemptionSwitchChanged: (bool value) { // Add this block
        taxOptionManager.toggleTaxExemption(value);
        recalculateValues(); // Recalculate after exemption switch change
      },
      onProgressionSwitchChanged: (bool value) { // Add this block
        taxOptionManager.toggleTaxProgressionLimit(value);
        recalculateValues(); // Recalculate after progression switch change
      },
    );
  }

  Widget _buildTaxRateDropdown(TaxOptionManager taxOptionManager) {
    return TaxRateDropdown(
      selectedTaxOption: taxOptionManager.currentOption,  // Current selected tax option
      taxOptions: taxOptionManager.allTaxOptions,         // All available tax options
      onTaxOptionChanged: (TaxOption? newOption) {
        if (newOption != null) {
          taxOptionManager.switchToPredefined(newOption);
          recalculateValues(); // Recalculate after tax rate change
        }
      },
    );
  }

  Widget _buildTaxTypeDropdown(TaxOptionManager taxOptionManager) {
    return TaxTypeDropdown(
      selectedTaxType: _getTaxType(taxOptionManager.currentOption.isNotionallyTaxed), // Selected tax type
      onTaxTypeChanged: (String? newTaxType) {
        if (newTaxType != null) {
          taxOptionManager.toggleTaxType(newTaxType == 'Notional Gains Tax'); // Toggle tax type
          recalculateValues(); // Recalculate after tax type change
        }
      },
    );
  }

  String _getTaxType(bool isNotionallyTaxed) {
    return isNotionallyTaxed ? 'Notional Gains Tax' : 'Capital Gains Tax';
  }
}
