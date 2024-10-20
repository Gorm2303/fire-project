import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:fire_app/widgets/wrappers/textfield_wrapper.dart';
import 'package:flutter/material.dart';

class InputFieldsWidget extends StatelessWidget {
  final TextEditingController principalController;
  final TextEditingController interestRateController;
  final TextEditingController durationController;
  final TextEditingController additionalAmountController;
  final TextEditingController increaseInContributionController;
  final String contributionFrequency;
  final Function(String) onContributionFrequencyChanged;  // Callback for dropdown
  final VoidCallback onInputChanged;  // Callback for when any input changes
  final TextEditingController presettingsController;
  final ValueChanged<String> onPresetSelected;  // Accept callback to handle preset selection
  final List<String> presetValues;  // Accept preset values


  const InputFieldsWidget({
    super.key,
    required this.principalController,
    required this.interestRateController,
    required this.durationController,
    required this.additionalAmountController,
    required this.contributionFrequency,
    required this.increaseInContributionController,
    required this.onContributionFrequencyChanged,
    required this.onInputChanged,
    required this.presettingsController,
    required this.onPresetSelected,
    required this.presetValues,
  });

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      title: 'Deposit Information',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,  // Center the row
          children: <Widget>[
            const Text(
              'Preset: ',
              style: TextStyle(fontSize: 16),
              softWrap: true, // Allow text wrapping
            ),
            // Dropdown for preset selections
            DropdownButton<String>(
              value: presettingsController.text,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  presettingsController.text = newValue;
                  onPresetSelected(newValue);  // Call the callback to update the controllers
                }
              },
              items: presetValues.map<DropdownMenuItem<String>>((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),  // Display the preset label
                );
              }).toList(),
            ),
          ],
        ),
        TextFieldWrapper( 
          children: [
            TextField(
              controller: principalController,
              decoration: const InputDecoration(labelText: 'Principal Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
            ),
            TextField(
              controller: interestRateController,
              decoration: const InputDecoration(labelText: 'Rate of Interest (%)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duration (Years)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // Center the row content
              children: [
                // Constrain the TextField to take part of the 305 width (e.g., 200)
                Expanded(
                  flex: 10,
                  child: TextField(
                    controller: additionalAmountController,
                    decoration: const InputDecoration(labelText: 'Additional Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
                  ),
                ),
                const SizedBox(width: 8),  // Add some spacing between TextField and DropdownButton
                // Set DropdownButton to take the remaining space (e.g., 100)
                Expanded(
                  flex: 4,
                  child: DropdownButton<String>(
                    value: contributionFrequency,
                    isExpanded: true,  // Ensure the dropdown fills the remaining space
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
                ),
              ],
            ),
            TextField(
              controller: increaseInContributionController,
              decoration: const InputDecoration(labelText: 'Increase in Contribution (Yearly in %)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
            ),
          ],
        ),
      ],
    );
  }
}
