import 'package:flutter/material.dart';

class WithdrawalWidget extends StatelessWidget {
  final TextEditingController withdrawalPercentageController;
  final double withdrawalYearlyAfterBreak;
  final double taxYearlyAfterBreak;
  final VoidCallback recalculateValues;
  final VoidCallback toggleTaxNote;
  final TextEditingController withdrawalDurationController;

  const WithdrawalWidget({
    super.key,
    required this.withdrawalPercentageController,
    required this.withdrawalYearlyAfterBreak,
    required this.taxYearlyAfterBreak,
    required this.recalculateValues,
    required this.toggleTaxNote,
    required this.withdrawalDurationController,
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
            mainAxisSize: MainAxisSize.min,  // Minimize the height of the column to the content
            crossAxisAlignment: CrossAxisAlignment.center,  // Center contents horizontally
            children: <Widget>[
              // Title for this section
              const Text(
                'Withdrawal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,  // Center the title
              ),
              const Divider(),
              _buildWithdrawalPeriod(),
              _build4PercentWidget(),
              _buildTaxOnMonthlyWithdrawal(),
              const SizedBox(height: 10),
              _buildMonthlyWithdrawalAfterTax(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawalPeriod() {
    return SizedBox(
      width: 305,  
      child: TextField(
        controller: withdrawalDurationController,
        decoration: const InputDecoration(labelText: 'Withdrawal Period (Years)'),
        keyboardType: TextInputType.number,
        onChanged: (value) => recalculateValues(),
      ),
    );
  }

  Widget _build4PercentWidget() {
    return SizedBox(
      height: 45, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,  // Center the contents of the Row
        children: <Widget>[
          DropdownButton<String>(
            value: withdrawalPercentageController.text,
            items: ['3', '4', '5'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('$value%'),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                withdrawalPercentageController.text = newValue;
                recalculateValues();
              }
            },
          ),
          const SizedBox(width: 10),  // Small spacing between dropdown and text
          Text(
            'Withdrawal Each Month: ${(withdrawalYearlyAfterBreak / 12).toStringAsFixed(0)} kr.-',
            style: const TextStyle(fontSize: 16),
            softWrap: true,
            textAlign: TextAlign.center,  // Center text if it's multi-line
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyWithdrawalAfterTax() {
    return Text(
      'Monthly Withdrawal After Tax: ${(withdrawalYearlyAfterBreak / 12 - taxYearlyAfterBreak / 12).toStringAsFixed(0)} kr.-',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTaxOnMonthlyWithdrawal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: toggleTaxNote,
          child: const Text(
            'Tax',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Text(
          ' on Monthly Withdrawal: ${(taxYearlyAfterBreak / 12).toStringAsFixed(0)} kr.-',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
