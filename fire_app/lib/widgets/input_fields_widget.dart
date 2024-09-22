import 'package:flutter/material.dart';

class InputFieldsWidget extends StatelessWidget {
  final TextEditingController principalController;
  final TextEditingController rateController;
  final TextEditingController timeController;
  final TextEditingController compoundController;
  final TextEditingController additionalAmountController;
  final String contributionFrequency;
  final Function(String) onContributionFrequencyChanged;  // Callback for dropdown
  final VoidCallback onInputChanged;  // Callback for when any input changes

  const InputFieldsWidget({
    super.key,
    required this.principalController,
    required this.rateController,
    required this.timeController,
    required this.compoundController,
    required this.additionalAmountController,
    required this.contributionFrequency,
    required this.onContributionFrequencyChanged,
    required this.onInputChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: principalController,
          decoration: const InputDecoration(labelText: 'Principal Amount'),
          keyboardType: TextInputType.number,
          onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
        ),
        TextField(
          controller: rateController,
          decoration: const InputDecoration(labelText: 'Rate of Interest (%)'),
          keyboardType: TextInputType.number,
          onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
        ),
        TextField(
          controller: timeController,
          decoration: const InputDecoration(labelText: 'Time (Years)'),
          keyboardType: TextInputType.number,
          onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
        ),
        TextField(
          controller: compoundController,
          decoration: const InputDecoration(labelText: 'Compounding Frequency (Times/Year)'),
          keyboardType: TextInputType.number,
          onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
        ),
        TextField(
          controller: additionalAmountController,
          decoration: const InputDecoration(labelText: 'Additional Amount'),
          keyboardType: TextInputType.number,
          onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
        ),
        // Dropdown to select the contribution frequency
        DropdownButton<String>(
          value: contributionFrequency,
          items: <String>['Monthly', 'Yearly'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onContributionFrequencyChanged(newValue);  // Trigger recalculation on dropdown change
            }
          },
        ),
      ],
    );
  }
}
