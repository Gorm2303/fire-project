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
  final TextEditingController withdrawalTimeController;

  const The4PercentWidget({
    super.key,
    required this.withdrawalPercentageController,
    required this.customWithdrawalRule,
    required this.customWithdrawalTax,
    required this.recalculateValues,
    required this.showTaxNote,
    required this.toggleTaxNote,
    required this.breakController,
    required this.compoundGatheredDuringBreak,
    required this.onInputChanged,
    required this.withdrawalTimeController,
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
            onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
          ),
        ),
        const SizedBox(height: 15),  // Spacing between rows
        // Constrain the Compound Gathered Text
        Text(
            'Compound Gathered During Break: ${compoundGatheredDuringBreak.toStringAsFixed(0)} kr.-',
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
                'Withdrawal Each Month: ${(customWithdrawalRule / 12).toStringAsFixed(0)} kr.-',
                style: const TextStyle(fontSize: 16),
                softWrap: true, // Allow text wrapping
              ),
            ],
          ),
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
              ' on Monthly Withdrawal: ${(customWithdrawalTax / 12).toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 15),  // Spacing between rows
        Text(
              'Monthly Withdrawal After Tax: ${((customWithdrawalRule / 12) - customWithdrawalTax / 12).toStringAsFixed(0)} kr.-',
              style: const TextStyle(fontSize: 16),
            ),
      ],
    );
  }
}
