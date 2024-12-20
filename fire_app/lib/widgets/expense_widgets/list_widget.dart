import 'package:fire_app/models/expense.dart';
import 'package:flutter/material.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final Function(int) onToggleExpense;
  final Function(int) onRemoveExpense;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.onToggleExpense,
    required this.onRemoveExpense,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${expenses[index].amount} - ${expenses[index].frequency}'),
          leading: Checkbox(
            value: expenses[index].isSelected,
            onChanged: (value) => onToggleExpense(index),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: () => onRemoveExpense(index),
          ),
        );
      },
    );
  }
}
