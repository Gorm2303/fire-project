import 'package:flutter/material.dart';

class AdditionalInputs extends StatelessWidget {
  final TextEditingController taxRateController;
  final TextEditingController durationController;
  final TextEditingController inflationRateController;

  const AdditionalInputs({
    super.key,
    required this.taxRateController,
    required this.durationController,
    required this.inflationRateController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: taxRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
        ),
        TextField(
          controller: durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Duration (years)'),
        ),
        TextField(
          controller: inflationRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Inflation Rate (%)'),
        ),
      ],
    );
  }
}
