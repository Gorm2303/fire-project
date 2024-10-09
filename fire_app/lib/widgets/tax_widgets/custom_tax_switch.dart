import 'package:flutter/material.dart';

class CustomTaxSwitch extends StatelessWidget {
  final bool isCustom;
  final ValueChanged<bool> onSwitchChanged;

  const CustomTaxSwitch({
    super.key,
    required this.isCustom,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28, // Set an explicit height to reduce vertical space
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Ensure vertical centering
        children: [
          const Text(
            'Custom Tax Rate: ', 
            style: TextStyle(fontSize: 16), // Adjust font size for compactness
          ),
          Transform.scale(
            scale: 0.6,  // Adjust the scale to reduce the size of the Switch
            child: Switch(
              value: isCustom,
              onChanged: onSwitchChanged,
            ),
          ),
        ],
      ),
    );
  }
}
