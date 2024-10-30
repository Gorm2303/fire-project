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
          decoration: const InputDecoration(labelText: 'Interest Rate', border: OutlineInputBorder()),
          onChanged: (value) => onParameterChanged(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: inflationRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Inflation Rate', border: OutlineInputBorder()),
          onChanged: (value) => onParameterChanged(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
          onChanged: (value) => onParameterChanged(),
        ),
      ],
    );
  }
}
