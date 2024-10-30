import 'package:flutter/material.dart';

class SalaryInputField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController yearlyRaiseController;
  final VoidCallback addSalaryCallback;

  const SalaryInputField({
    super.key,
    required this.controller,
    required this.addSalaryCallback, required this.yearlyRaiseController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monthly Salary'),
        ),
        TextField(
          controller: yearlyRaiseController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Yearly Pay Raise (%)'),
        ),
        ElevatedButton(
          onPressed: addSalaryCallback,
          child: const Text('Add Salary'),
        ),
      ],
    );
  }
}
