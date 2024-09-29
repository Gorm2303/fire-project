import 'package:fire_app/widgets/tax_exemption_switch.dart';
import 'package:flutter/material.dart';

class The4PercentWidget extends StatelessWidget {
  final TextEditingController withdrawalPercentageController;
  final double withdrawalYearlyAfterBreak;
  final double taxYearlyAfterBreak;
  final VoidCallback recalculateValues;
  final VoidCallback toggleTaxNote;
  final TextEditingController breakController;
  final double interestGatheredDuringBreak; 
  final TextEditingController withdrawalTimeController;
  final TextEditingController taxController;
  final Widget toggleSwitchWidget;
  final Widget notionalGainsTaxWidget;
  final TaxExemptionSwitch taxExemptionSwitch;

  const The4PercentWidget({
    super.key,
    required this.withdrawalPercentageController,
    required this.withdrawalYearlyAfterBreak,
    required this.taxYearlyAfterBreak,
    required this.recalculateValues,
    required this.toggleTaxNote,
    required this.breakController,
    required this.interestGatheredDuringBreak,
    required this.withdrawalTimeController, 
    required this.taxController,
    required this.toggleSwitchWidget,
    required this.notionalGainsTaxWidget,
    required this.taxExemptionSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Constrain the Break Period Input to a fixed width
        SizedBox(
          width: 305,  // Set the fixed width for the TextField
          child: TextField(
            controller: breakController,
            decoration: const InputDecoration(labelText: 'Break Period (No Deposits Nor Withdrawals in Years)'),
            keyboardType: TextInputType.number,
            onChanged: (value) => recalculateValues(),  // Trigger recalculation on change
          ),
        ),
        const SizedBox(height: 15),  // Spacing between rows
        // Constrain the Interest Gathered Text
        Text(
            'Interest Gathered During Break: ${interestGatheredDuringBreak.toStringAsFixed(0)} kr.-',
            style: const TextStyle(fontSize: 16),
          ),
        const SizedBox(height: 15),  // Spacing between rows
        SizedBox(
          width: 305,  // Set the fixed width for the TextField
          child: TextField(
            controller: withdrawalTimeController,
            decoration: const InputDecoration(labelText: 'Withdrawal Period (Years)'),
            keyboardType: TextInputType.number,
            onChanged: (value) => recalculateValues(),  // Trigger recalculation on change
          ),
        ),
        const SizedBox(height: 15),  // Spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,  // Center the row
          children: <Widget>[
            // Constrain the Withdrawal Period Input to a fixed width
              DropdownButton<String>(
                value: withdrawalPercentageController.text,
                items: ['3', '4', '5'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('$value%'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    withdrawalPercentageController.text = newValue;
                    recalculateValues();  // Trigger recalculation when value changes
                  }
                },
              ),
            // Constrain the Withdrawal Each Month Text
            Text(
              'Withdrawal Each Month: ${(withdrawalYearlyAfterBreak / 12).toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
              softWrap: true, // Allow text wrapping
            ),
          ],
        ),
        toggleSwitchWidget,
        notionalGainsTaxWidget,
        taxExemptionSwitch,
        const SizedBox(height: 10),  // Spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GestureDetector to toggle visibility of the tax note
            GestureDetector(
              onTap: toggleTaxNote,  // Toggle tax note visibility
              child: const Text(
                'Tax',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' on Monthly Withdrawal: ${(taxYearlyAfterBreak / 12).toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 15),  // Spacing between rows
        Text(
              'Monthly Withdrawal After Tax: ${((withdrawalYearlyAfterBreak / 12) - taxYearlyAfterBreak / 12).toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
            ),
      ],
    );
  }
}
