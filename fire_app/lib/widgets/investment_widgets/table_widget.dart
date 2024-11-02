import 'package:fire_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class InvestmentTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> yearlyValues;
  final bool isDepositingTable;
  final bool isWithdrawingTable;

  const InvestmentTableWidget({
    super.key,
    required this.yearlyValues,
    this.isDepositingTable = true,
    this.isWithdrawingTable = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure that the yearlyValues list is not empty
    if (yearlyValues.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SizedBox(
      height: 400,  // Define the height for the table
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: isDepositingTable
            ? const [
                DataColumn2(label: Center(child: Text('Year')), size: ColumnSize.S),
                DataColumn2(label: Center(child: Text('Total Value')), size: ColumnSize.M),
                DataColumn2(label: Center(child: Text('Deposits Total')), size: ColumnSize.M),
                DataColumn2(label: Center(child: Text('Interest (Yearly)')), size: ColumnSize.M),
                DataColumn2(label: Center(child: Text('Interest (Total)')), size: ColumnSize.M),
                DataColumn2(label: Center(child: Text('Tax (Yearly)')), size: ColumnSize.M),
              ]
            : const [
                DataColumn2(label: Center(child: Text('Year')), size: ColumnSize.S),
                DataColumn2(label: Center(child: Text('Total Value')), size: ColumnSize.L),
                DataColumn2(label: Center(child: Text('Interest (Yearly)')), size: ColumnSize.M),
                DataColumn2(label: Center(child: Text('Interest (Total)')), size: ColumnSize.M),
                DataColumn2(label: Center(child: Text('Withdrawal (Monthly)')), size: ColumnSize.M),
                DataColumn2(label: Center(child: Text('Withdrawal (Yearly)')), size: ColumnSize.M),
                DataColumn2(label: Center(child: Text('Tax (Yearly)')), size: ColumnSize.M),
              ],
        rows: yearlyValues.map((value) {
          return DataRow(cells: [
            DataCell(Center(child: Text(value['year']!.toString()))),
            DataCell(Center(child: Text(value['totalValue']!.toString()))),
            if (isDepositingTable)
              DataCell(Center(child: Text(value['totalDeposits']!.toString()))),
            DataCell(Center(child: Text(value['compoundThisYear']!.toString()))),
            DataCell(Center(child: Text(value['compoundEarnings']!.toString()))),
            if (isWithdrawingTable)
              DataCell(Center(child: Text(Utils.parseDivideAndFormat(value['withdrawal']!)))),

            if (isWithdrawingTable)
              DataCell(Center(child: Text((value['withdrawal'])!.toString()))),
            DataCell(Center(child: Text(value['tax']!.toString()))),
          ]);
        }).toList(),
        headingRowHeight: 56,
        showBottomBorder: true,
        fixedLeftColumns: 1,
      ),
    );
  }
}
