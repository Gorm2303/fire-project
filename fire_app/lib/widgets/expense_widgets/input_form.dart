import 'package:flutter/material.dart';

class ExpenseInputForm extends StatelessWidget {
  final TextEditingController expenseController;
  final List<String> frequencies;
  final String selectedFrequency;
  final Function(String) onFrequencyChanged;
  final VoidCallback onAddExpense;

  const ExpenseInputForm({
    super.key,
    required this.expenseController,
    required this.frequencies,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: expenseController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Expense'),
        ),
        DropdownButtonFormField<String>(
          value: selectedFrequency,
          items: frequencies.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) => onFrequencyChanged(newValue ?? 'One Time'),
          decoration: const InputDecoration(labelText: 'Frequency'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onAddExpense, child: const Text('Add Expense')),
      ],
    );
  }
}
