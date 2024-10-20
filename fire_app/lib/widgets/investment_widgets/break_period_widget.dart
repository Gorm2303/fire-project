import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:fire_app/widgets/wrappers/textfield_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BreakPeriodWidget extends StatelessWidget {
  final TextEditingController breakController;
  final double interestGatheredDuringBreak;
  final double totalDeposits;
  final double totalValue;
  final double taxDuringBreak;
  final VoidCallback recalculateValues;

  const BreakPeriodWidget({
    super.key,
    required this.breakController,
    required this.interestGatheredDuringBreak,
    required this.totalDeposits,
    required this.totalValue,
    required this.taxDuringBreak,
    required this.recalculateValues,
  });

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      title: 'Break Period Information',
      children: [
        _buildBreakPeriodInput(),
        _buildInterestGatheredText(),
      ],
    );
  }

  _buildInterestGatheredText() {
    double interestOverDeposits = totalDeposits != 0 ? (interestGatheredDuringBreak / totalDeposits * 100) : 0;
    double interestOverTotalValue = totalValue != 0 ? (interestGatheredDuringBreak / (totalValue - interestGatheredDuringBreak) * 100) : 0;

    return Column(
      children: <Widget>[
        Text(
          'Interest Gathered During Break: ${NumberFormat('###,###').format(interestGatheredDuringBreak)}',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          'Compared to deposits: ${interestOverDeposits.toStringAsFixed(2)}%',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          'Compared to total value: ${interestOverTotalValue.toStringAsFixed(2)}%',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          'Tax Payed During Break: ${NumberFormat('###,###').format(taxDuringBreak)}',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBreakPeriodInput() {
    return TextFieldWrapper( 
      children: [
        TextField(
          controller: breakController,
          decoration: const InputDecoration(
            labelText: 'Break Period (No Deposits Nor Withdrawals in Years)',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => recalculateValues(),
        ),
      ]
    );
  }
}
