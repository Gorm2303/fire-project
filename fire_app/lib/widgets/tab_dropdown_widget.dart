import 'package:flutter/material.dart';

class TabDropdownWidget extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String?> onChanged;

  const TabDropdownWidget({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedOption,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      iconSize: 20,
      elevation: 16,
      dropdownColor: const Color.fromARGB(255, 203, 239, 255),
      underline: Container(
        height: 2,
        color: const Color.fromARGB(255, 119, 119, 119),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 18),
      onChanged: onChanged,
      items: <String>['Investment Calculator', 'Expenses Calculator']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
