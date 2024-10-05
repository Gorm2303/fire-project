import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';  // Import the package

class InvestmentTableWidget extends StatelessWidget {
  final List<Map<String, double>> yearlyValues;
  final bool isDepositingTable;  // Flag to show or hide total deposits column
  final bool isWithdrawingTable;  // Flag to show or hide withdrawal and tax columns

  const InvestmentTableWidget({
    super.key,
    required this.yearlyValues,
    this.isDepositingTable = true,  // Default to true for the first table
    this.isWithdrawingTable = false,  // Default to false for the second table
  });

  @override
  Widget build(BuildContext context) {
    // Safeguard: Ensure that the yearlyValues list is not empty
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
                DataColumn2(
                  label: Text(
                    'Year',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'Total Value',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Total Deposits',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Annual Interest',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Total Interest',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Annual Tax',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
              ]
            : const [
                DataColumn2(
                  label: Text(
                    'Year',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'Total Value',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'Annual Interest',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Total Interest',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Monthly Withdrawal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Annual Withdrawal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'Annual Tax',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true, // Allow text wrapping
                  ),
                  size: ColumnSize.M,
                ),
              ],
        rows: yearlyValues.map((value) {
          return DataRow(cells: [
            DataCell(Text(value['year']!.toInt().toString())),
            DataCell(Text(value['totalValue']!.toStringAsFixed(0))),
            if (isDepositingTable) DataCell(Text(value['totalDeposits']!.toStringAsFixed(0))),
            DataCell(Text(value['compoundThisYear']!.toStringAsFixed(0))),
            DataCell(Text(value['compoundEarnings']!.toStringAsFixed(0))),
            if (isWithdrawingTable) DataCell(Text((value['withdrawal']! / 12).toStringAsFixed(0))),  // Monthly Withdrawal
            if (isWithdrawingTable) DataCell(Text(value['withdrawal']?.toStringAsFixed(0) ?? '0')),  // Annual Withdrawal
            DataCell(Text(value['tax']?.toStringAsFixed(0) ?? '0')),  // Tax column
          ]);
        }).toList(),
        headingRowHeight: 56,  // Height for the sticky header row
        showBottomBorder: true,  // Show border at the bottom
        fixedLeftColumns: 1,  // Fix the first column (e.g., 'Year') for scrolling
      ),
    );
  }
}
