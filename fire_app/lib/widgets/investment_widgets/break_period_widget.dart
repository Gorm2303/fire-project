import 'package:flutter/material.dart';

class BreakPeriodWidget extends StatelessWidget {
  final TextEditingController breakController;
  final double interestGatheredDuringBreak;
  final double totalDeposits;
  final double totalValue;
  final VoidCallback recalculateValues;

  const BreakPeriodWidget({
    super.key,
    required this.breakController,
    required this.interestGatheredDuringBreak,
    required this.totalDeposits,
    required this.totalValue,
    required this.recalculateValues,
  });

  @override
  Widget build(BuildContext context) {
    double interestOverDeposits = totalDeposits != 0 ? (interestGatheredDuringBreak / totalDeposits * 100) : 0;
    double interestOverTotalValue = totalValue != 0 ? (interestGatheredDuringBreak / (totalValue - interestGatheredDuringBreak) * 100) : 0;

    return Column(
      children: <Widget>[
        SizedBox(
          width: 305,  
          child: TextField(
            controller: breakController,
            decoration: const InputDecoration(labelText: 'Break Period (No Deposits Nor Withdrawals in Years)'),
            keyboardType: TextInputType.number,
            onChanged: (value) => recalculateValues(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Interest Gathered During Break: ${interestGatheredDuringBreak.toStringAsFixed(0)} kr.-',
          style: const TextStyle(fontSize: 16),
        ),
        Text('Compared to deposits: ${interestOverDeposits.toStringAsFixed(2)}%'),
        Text('Compared to total value: ${interestOverTotalValue.toStringAsFixed(2)}%'),
      ],
    );
  }
}
