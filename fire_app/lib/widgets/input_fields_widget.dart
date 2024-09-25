import 'package:flutter/material.dart';

class InputFieldsWidget extends StatelessWidget {
  final TextEditingController principalController;
  final TextEditingController rateController;
  final TextEditingController timeController;
  final TextEditingController additionalAmountController;
  final String contributionFrequency;
  final Function(String) onContributionFrequencyChanged;  // Callback for dropdown
  final VoidCallback onInputChanged;  // Callback for when any input changes
  final TextEditingController presettingsController;
  final ValueChanged<String> onPresetSelected;  // Accept callback to handle preset selection
  final Map<String, Map<String, String>> presetValues;  // Accept preset values


  const InputFieldsWidget({
    super.key,
    required this.principalController,
    required this.rateController,
    required this.timeController,
    required this.additionalAmountController,
    required this.contributionFrequency,
    required this.onContributionFrequencyChanged,
    required this.onInputChanged,
    required this.presettingsController,
    required this.onPresetSelected,
    required this.presetValues,
  });

  @override
  Widget build(BuildContext context) {
    return Center(  // Center the entire Column
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,  // Center the column content
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,  // Center the row
            children: <Widget>[
              const Text(
                'Presettings: ',
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
                  items: presetValues.keys.map<DropdownMenuItem<String>>((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),  // Display the preset label
                    );
                  }).toList(),
                ),
            ],
          ),
          // Constrain the TextFields to a fixed width of 305
          SizedBox(
            width: 305,
            child: TextField(
              controller: principalController,
              decoration: const InputDecoration(labelText: 'Principal Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
            ),
          ),
          SizedBox(
            width: 305,
            child: TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'Rate of Interest (%)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
            ),
          ),
          SizedBox(
            width: 305,
            child: TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (Years)'),
              keyboardType: TextInputType.number,
              onChanged: (value) => onInputChanged(),  // Trigger recalculation on change
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,  // Center the row content
            children: [
              // Set a total width of 305 for the row
              SizedBox(
                width: 305,  // Fixed width for the entire row
                child: Row(
                  children: [
                    // Constrain the TextField to take part of the 305 width (e.g., 200)
                    Expanded(
                      flex: 2,
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
                      flex: 1,
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
              ),
            ],
          ),
        ],
      ),
    );
  }

}
