import 'package:flutter/material.dart';

class AdditionalInputs extends StatelessWidget {
  final TextEditingController taxRateController;
  final TextEditingController durationController;
  final TextEditingController inflationRateController;
  final VoidCallback onParameterChanged;

  const AdditionalInputs({
    super.key,
    required this.taxRateController,
    required this.durationController,
    required this.inflationRateController,
    required this.onParameterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: taxRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
          onChanged: (value) => onParameterChanged(),
        ),
        TextField(
          controller: durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Duration (Years)'),
          onChanged: (value) => onParameterChanged(),
        ),
        TextField(
          controller: inflationRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Inflation Rate (%)'),
          onChanged: (value) => onParameterChanged(),
        ),
      ],
    );
  }
}
