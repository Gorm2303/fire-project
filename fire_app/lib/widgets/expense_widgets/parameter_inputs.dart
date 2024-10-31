import 'package:flutter/material.dart';

class ExpenseParameterInputs extends StatelessWidget {
  final TextEditingController interestRateController;
  final TextEditingController inflationRateController;
  final TextEditingController durationController;
  final VoidCallback onParameterChanged;

  const ExpenseParameterInputs({
    super.key,
    required this.interestRateController,
    required this.inflationRateController,
    required this.durationController,
    required this.onParameterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: interestRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Interest Rate (%)'),
          onChanged: (value) => onParameterChanged(),
        ),
        TextField(
          controller: inflationRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Inflation Rate (%)'),
          onChanged: (value) => onParameterChanged(),
        ),
        TextField(
          controller: durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Duration (Years)'),
          onChanged: (value) => onParameterChanged(),
        ),
      ],
    );
  }
}
