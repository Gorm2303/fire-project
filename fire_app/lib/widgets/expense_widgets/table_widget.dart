import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class ExpenseTable extends StatelessWidget {
  final List<Map<String, dynamic>> tableData;

  const ExpenseTable({
    super.key,
    required this.tableData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // Set a finite height to constrain the overall layout
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: const [
          DataColumn(label: Text('Year')),
          DataColumn(label: Text('Total Expenses')),
          DataColumn(label: Text('Interest (Yearly)')),
          DataColumn(label: Text('Interest (Total)')),
          DataColumn(label: Text('Total Value')),
          DataColumn(label: Text('Inflation Adjusted')),
        ],
        rows: tableData.map((data) {
          return DataRow(cells: [
            DataCell(Text(data['year'].toString())),
            DataCell(Text(data['Total Expenses'])),
            DataCell(Text(data['Interest (Yearly)'])),
            DataCell(Text(data['Interest (Total)'])),
            DataCell(Text(data['Total Value'])),
            DataCell(Text(data['Inflation Adjusted'])),
          ]);
        }).toList(),
      ),
    );
  }
}
