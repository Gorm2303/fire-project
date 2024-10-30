import 'package:flutter/material.dart';

class ExpenseInputForm extends StatelessWidget {
  final TextEditingController expenseController;
  final List<String> frequencies;
  final String selectedFrequency;
  final Function(String) onFrequencyChanged;
  final VoidCallback onAddExpense;

  const ExpenseInputForm({
    Key? key,
    required this.expenseController,
    required this.frequencies,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
    required this.onAddExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: expenseController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Expense', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedFrequency,
          items: frequencies.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) => onFrequencyChanged(newValue ?? 'One Time'),
          decoration: const InputDecoration(labelText: 'Frequency', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onAddExpense, child: const Text('Add Expense')),
      ],
    );
  }
}
