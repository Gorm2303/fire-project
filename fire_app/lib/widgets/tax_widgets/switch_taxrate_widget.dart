import 'package:flutter/material.dart';
import 'custom_tax_switch.dart';
import 'tax_rate_dropdown.dart';
import 'tax_exemption_switch.dart';
import 'tax_type_dropdown.dart';
import '../../models/tax_option.dart';
import '../../services/tax_option_manager.dart';

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
    _selectedTaxType = _getTaxType(_taxOptionManager.currentOption.isNotionallyTaxed);
    _useTaxExemptionCard = _taxOptionManager.currentOption.useTaxExemptionCardAndThreshold;
  }

  String _getTaxType(bool isNotionallyTaxed) {
    return isNotionallyTaxed ? 'Notional Gains Tax' : 'Capital Gains Tax';
  }

  void _updateTaxRate(String value) {
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
  }

  void _onTaxRateSwitchChanged(bool value) {
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
      _selectedTaxType = _getTaxType(_taxOptionManager.currentOption.isNotionallyTaxed);
      _useTaxExemptionCard = _taxOptionManager.currentOption.useTaxExemptionCardAndThreshold;
    });
    widget.recalculateValues();
  }

  void _onTaxOptionChanged(TaxOption? newOption) {
    if (newOption != null) {
      setState(() {
        _taxOptionManager.switchToPredefined(newOption);
        _selectedTaxType = _getTaxType(newOption.isNotionallyTaxed);
        _useTaxExemptionCard = newOption.useTaxExemptionCardAndThreshold;
      });
      widget.recalculateValues();
    }
  }

  void _onTaxTypeChanged(String? newTaxType) {
    if (newTaxType != null) {
      setState(() {
        _selectedTaxType = newTaxType;
        _taxOptionManager.toggleTaxType(newTaxType == 'Notional Gains Tax');
      });
      widget.recalculateValues();
    }
  }

  void _onTaxExemptionSwitchChanged(bool value) {
    setState(() {
      _useTaxExemptionCard = value;
      _taxOptionManager.toggleTaxExemption(value);
    });
    widget.recalculateValues();
  }

  Widget _buildCustomTaxSwitch() {
    return CustomTaxSwitch(
      isCustom: _taxOptionManager.isCustomTaxRate, // Use custom tax rate
      onSwitchChanged: _onTaxRateSwitchChanged,
    );
  }

  Widget _buildTaxRateInputField() {
    return SizedBox(
      width: 305,
      child: TextField(
        controller: widget.customTaxController,
        decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
        keyboardType: TextInputType.number,
        onChanged: _updateTaxRate,
      ),
    );
  }

  Widget _buildTaxRateDropdown() {
    return TaxRateDropdown(
      selectedTaxOption: _taxOptionManager.currentOption,
      taxOptions: _taxOptionManager.allTaxOptions, // Includes "Custom" if active
      onTaxOptionChanged: _onTaxOptionChanged,
    );
  }

  Widget _buildTaxTypeDropdown() {
    return TaxTypeDropdown(
      selectedTaxType: _selectedTaxType,
      onTaxTypeChanged: _onTaxTypeChanged,
    );
  }

  Widget _buildTaxExemptionSwitch() {
    return TaxExemptionSwitch(
      useTaxExemptionCard: _useTaxExemptionCard,
      onSwitchChanged: _onTaxExemptionSwitchChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildCustomTaxSwitch(),
        _taxOptionManager.isCustomTaxRate
            ? _buildTaxRateInputField()
            : _buildTaxRateDropdown(),
        _buildTaxTypeDropdown(),
        _buildTaxExemptionSwitch(),
      ],
    );
  }
}
