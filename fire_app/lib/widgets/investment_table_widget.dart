import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class InvestmentTableWidget extends StatelessWidget {
  final List<Map<String, double>> yearlyValues;
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
                DataColumn2(label: Text('Year'), size: ColumnSize.S),
                DataColumn2(label: Text('Total Value'), size: ColumnSize.M),
                DataColumn2(label: Text('Total Deposits'), size: ColumnSize.M),
                DataColumn2(label: Text('Annual Interest'), size: ColumnSize.M),
                DataColumn2(label: Text('Total Interest'), size: ColumnSize.M),
                DataColumn2(label: Text('Annual Tax'), size: ColumnSize.M),
              ]
            : const [
                DataColumn2(label: Text('Year'), size: ColumnSize.S),
                DataColumn2(label: Text('Total Value'), size: ColumnSize.L),
                DataColumn2(label: Text('Annual Interest'), size: ColumnSize.M),
                DataColumn2(label: Text('Total Interest'), size: ColumnSize.M),
                DataColumn2(label: Text('Monthly Withdrawal'), size: ColumnSize.M),
                DataColumn2(label: Text('Annual Withdrawal'), size: ColumnSize.M),
                DataColumn2(label: Text('Annual Tax'), size: ColumnSize.M),
              ],
        rows: yearlyValues.map((value) {
          return DataRow(cells: [
            DataCell(Text(value['year']!.toInt().toString())),
            DataCell(Text(value['totalValue']!.toStringAsFixed(0))),
            if (isDepositingTable) DataCell(Text(value['totalDeposits']!.toStringAsFixed(0))),
            DataCell(Text(value['compoundThisYear']!.toStringAsFixed(0))),
            DataCell(Text(value['compoundEarnings']!.toStringAsFixed(0))),
            if (isWithdrawingTable) DataCell(Text((value['withdrawal']! / 12).toStringAsFixed(0))),
            if (isWithdrawingTable) DataCell(Text(value['withdrawal']?.toStringAsFixed(0) ?? '0')),
            DataCell(Text(value['tax']?.toStringAsFixed(0) ?? '0')),
          ]);
        }).toList(),
        headingRowHeight: 56,
        showBottomBorder: true,
        fixedLeftColumns: 1,
      ),
    );
  }
}
