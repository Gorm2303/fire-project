import 'package:fire_app/widgets/investment_widgets/break_period_widget.dart';
import 'package:fire_app/widgets/withdrawal_tax_widgets/withdrawal_widget.dart';
import 'package:flutter/material.dart';

class The4PercentWidget extends StatelessWidget {
  final TextEditingController withdrawalPercentageController;
  final double withdrawalYearlyAfterBreak;
  final double taxYearlyAfterBreak;
  final VoidCallback recalculateValues;
  final VoidCallback toggleTaxNote;
  final TextEditingController breakController;
  final double interestGatheredDuringBreak;
  final TextEditingController withdrawalDurationController;
  final TextEditingController taxController;
  final Widget toggleSwitchWidget;
  final double totalDeposits;
  final double totalValue;

  const The4PercentWidget({
    super.key,
    required this.withdrawalPercentageController,
    required this.withdrawalYearlyAfterBreak,
    required this.taxYearlyAfterBreak,
    required this.recalculateValues,
    required this.toggleTaxNote,
    required this.breakController,
    required this.interestGatheredDuringBreak,
    required this.withdrawalDurationController,
    required this.taxController,
    required this.toggleSwitchWidget,
    required this.totalDeposits,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        BreakPeriodWidget(
          breakController: breakController,
          interestGatheredDuringBreak: interestGatheredDuringBreak,
          totalDeposits: totalDeposits,
          totalValue: totalValue,
          recalculateValues: recalculateValues,
          toggleSwitchWidget: toggleSwitchWidget,
        ),
        WithdrawalWidget(
          withdrawalPercentageController: withdrawalPercentageController,
          withdrawalYearlyAfterBreak: withdrawalYearlyAfterBreak,
          taxYearlyAfterBreak: taxYearlyAfterBreak,
          recalculateValues: recalculateValues,
          toggleTaxNote: toggleTaxNote,
          withdrawalDurationController: withdrawalDurationController,
        ),
      ],
    );
  }
}
