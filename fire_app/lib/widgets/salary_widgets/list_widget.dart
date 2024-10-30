import 'package:fire_app/models/salary.dart';
import 'package:flutter/material.dart';

class SalaryList extends StatelessWidget {
  final List<Salary> salaries;
  final Function(int) toggleSalaryCallback;
  final Function(int) removeSalaryCallback;

  const SalaryList({
    super.key,
    required this.salaries,
    required this.toggleSalaryCallback,
    required this.removeSalaryCallback,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: salaries.length,
        itemBuilder: (context, index) {
          final salary = salaries[index];
          return ListTile(
            title: Text('${salary.amount} - ${salary.raiseYearlyPercentage}%'),
            leading: Checkbox(
              value: salary.isSelected,
              onChanged: (_) => toggleSalaryCallback(index),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => removeSalaryCallback(index),
            ),
          );
        },
      ),
    );
  }
}
