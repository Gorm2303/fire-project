import 'package:fire_app/widgets/withdrawal_tax_widgets/tax_note_widget.dart';
import 'package:fire_app/widgets/wrappers/textfield_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/widgets/wrappers/card_wrapper.dart';

class WithdrawalWidget extends StatelessWidget {
  final TextEditingController withdrawalPercentageController;
  final double withdrawalYearlyAfterBreak;
  final double taxYearlyAfterBreak;
  final VoidCallback recalculateValues;
  final VoidCallback toggleTaxNote;
  final TextEditingController withdrawalDurationController;
  final TaxNoteWidget taxNoteWidget;

  const WithdrawalWidget({
    super.key,
    required this.withdrawalPercentageController,
    required this.withdrawalYearlyAfterBreak,
    required this.taxYearlyAfterBreak,
    required this.recalculateValues,
    required this.toggleTaxNote,
    required this.withdrawalDurationController,
    required this.taxNoteWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      title: 'Withdrawal Information',
      children: [
        _buildWithdrawalPeriod(),
        _build4PercentWidget(),
        _buildTaxOnMonthlyWithdrawal(),
        const SizedBox(height: 10),
        _buildMonthlyWithdrawalAfterTax(),
        taxNoteWidget,
      ],
    );
  }

  Widget _buildWithdrawalPeriod() {
    return TextFieldWrapper( 
      children: [
        TextField(
          controller: withdrawalDurationController,
          decoration: const InputDecoration(labelText: 'Withdrawal Period (Years)'),
          keyboardType: TextInputType.number,
          onChanged: (value) => recalculateValues(),
        ),
      ]
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
