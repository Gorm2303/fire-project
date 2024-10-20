import 'package:fire_app/services/utils.dart';
import 'package:fire_app/widgets/wrappers/textfield_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class WithdrawalWidget extends StatelessWidget {
  final TextEditingController withdrawalPercentageController;
  final double withdrawalYearlyAfterBreak;
  final double taxYearlyAfterBreak;
  final VoidCallback recalculateValues;
  final VoidCallback toggleTaxNote;
  final TextEditingController withdrawalDurationController;
  final TextEditingController inflationController;
  final int durationAfterBreak;

  const WithdrawalWidget({
    super.key,
    required this.withdrawalPercentageController,
    required this.withdrawalYearlyAfterBreak,
    required this.taxYearlyAfterBreak,
    required this.recalculateValues,
    required this.toggleTaxNote,
    required this.withdrawalDurationController,
    required this.inflationController,
    required this.durationAfterBreak,
  });

  @override
  Widget build(BuildContext context) {
    final taxOnMonthlyWithdrawal = taxYearlyAfterBreak / 12;
    final withdrawalMonthly = withdrawalYearlyAfterBreak / 12;
    final withdrawalMonthyAfterTax = withdrawalMonthly - taxOnMonthlyWithdrawal;
    final double expectedInflation = (pow(1 + (Utils.parseTextToDouble(inflationController.text)/100), durationAfterBreak) - 1);
    final double withdrawalMonthlyAfterTaxAndInflation = withdrawalMonthyAfterTax / (1 + expectedInflation);
    return CardWrapper(
      title: 'Withdrawal Information',
      children: [
        _buildWithdrawalPeriod(),
        _build4PercentWidget(withdrawalMonthly),
        _buildTaxOnMonthlyWithdrawal(taxOnMonthlyWithdrawal),
        const SizedBox(height: 10),
        _buildMonthlyWithdrawalAfterTax(withdrawalMonthyAfterTax),
        _buildInflation(),
        _buildInflationAccumulated(expectedInflation),
        _buildInflationAdjustedWithdrawal(withdrawalMonthyAfterTax, withdrawalMonthlyAfterTaxAndInflation),
      ],
    );
  }

  Widget _buildInflationAccumulated(double expectedInflation) {
    return Text(
      'Inflation Accumulated Over $durationAfterBreak Years: ${(expectedInflation*100).toStringAsFixed(2)}%',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInflationAdjustedWithdrawal(double withdrawal, double withdrawalAfterInflation) {
    return Text(
      'In $durationAfterBreak Years ${NumberFormat('###,###').format(withdrawal)} Is Worth: ${NumberFormat('###,###').format(withdrawalAfterInflation)}',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInflation() {
    return TextFieldWrapper(
      children: [
        TextField(
          controller: inflationController,
          decoration: const InputDecoration(labelText: 'Inflation Rate (%)'),
          keyboardType: TextInputType.number,
          onChanged: (value) => recalculateValues(),
        ),
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

  Widget _build4PercentWidget(double withdrawal) {
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
            'Withdrawal Each Month: ${NumberFormat('###,###').format(withdrawal)}',
            style: const TextStyle(fontSize: 16),
            softWrap: true,
            textAlign: TextAlign.center,  // Center text if it's multi-line
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyWithdrawalAfterTax(withdrawal) {
    return Text(
      'Monthly Withdrawal After Tax: ${NumberFormat('###,###').format(withdrawal)}',
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTaxOnMonthlyWithdrawal(withdrawal) {
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
          ' on Monthly Withdrawal: ${NumberFormat('###,###').format(withdrawal)}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
