import 'package:flutter/material.dart';

class The4PercentWidget extends StatelessWidget {
  final TextEditingController withdrawalPercentageController;
  final double customWithdrawalRule;
  final double customWithdrawalTax;
  final VoidCallback recalculateValues;
  final bool showTaxNote;
  final VoidCallback toggleTaxNote;
  final TextEditingController breakController;
  final double compoundGatheredDuringBreak; 
  final VoidCallback onInputChanged;  // Callback for when any input changes

  const The4PercentWidget({
    Key? key,
    required this.withdrawalPercentageController,
    required this.customWithdrawalRule,
    required this.customWithdrawalTax,
    required this.recalculateValues,
    required this.showTaxNote,
    required this.toggleTaxNote,
    required this.breakController,
    required this.compoundGatheredDuringBreak,
    required this.onInputChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            // Break Period Input
            Expanded(
              child: TextField(
                controller: breakController,
                decoration: const InputDecoration(labelText: 'Break Period After Investing Time (No Deposits Nor Withdrawals in Years)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
              ),
            ),
            const SizedBox(width: 16),  // Add some spacing between TextField and the Text
            // Display Compound Interest Gathered During Break Period
            Expanded(
              child: Text(
                'Compound Gathered: ${compoundGatheredDuringBreak.toStringAsFixed(0)} kr.-',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Dropdown for selecting withdrawal percentage (3%, 4%, 5%)
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
            const SizedBox(width: 16),
            // Display the monthly withdrawal amount
            Text(
              'Withdrawal Each Month: ${(customWithdrawalRule / 12).toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
              ' on Monthly Withdrawal: ${(customWithdrawalTax / 12).toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
