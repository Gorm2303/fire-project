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
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),  // Add margin around the card
        elevation: 3,  // Adds a shadow to the card for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),  // Rounded corners for a polished look
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),  // Padding inside the card
          child: Column(
            mainAxisSize: MainAxisSize.min,  // Keep the card height as small as possible
            crossAxisAlignment: CrossAxisAlignment.center,  // Center everything horizontally
            children: <Widget>[
              // Title for this section
              const Text(
                'Break Period Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,  // Center the title
              ),
              const Divider(),  // Separate title from content
              _buildBreakPeriodInput(),
              const SizedBox(height: 10),
              _buildInterestGatheredText(),
            ],
          ),
        ),
      ),
    );
  }

  _buildInterestGatheredText() {
    double interestOverDeposits = totalDeposits != 0 ? (interestGatheredDuringBreak / totalDeposits * 100) : 0;
    double interestOverTotalValue = totalValue != 0 ? (interestGatheredDuringBreak / (totalValue - interestGatheredDuringBreak) * 100) : 0;

    return Column(
      children: <Widget>[
        Text(
          'Interest Gathered During Break: ${interestGatheredDuringBreak.toStringAsFixed(0)} kr.-',
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
      ],
    );
  }

  Widget _buildBreakPeriodInput() {
    return SizedBox(
      width: 305,
      child: TextField(
        controller: breakController,
        decoration: const InputDecoration(
          labelText: 'Break Period (No Deposits Nor Withdrawals in Years)',
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) => recalculateValues(),
      ),
    );
  }
}
