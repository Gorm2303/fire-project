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
          DataColumn2(label: Center(child: Text('Year')), size: ColumnSize.S),
          DataColumn2(label: Center(child: Text('Total Expenses')), size: ColumnSize.M),
          DataColumn2(label: Center(child: Text('Interest (Yearly)')), size: ColumnSize.M),
          DataColumn2(label: Center(child: Text('Interest (Total)')), size: ColumnSize.M),
          DataColumn2(label: Center(child: Text('Total Value')), size: ColumnSize.M),
          DataColumn2(label: Center(child: Text('Inflation Adjusted')), size: ColumnSize.M),
        ],
        rows: tableData.map((data) {
          return DataRow(cells: [
            DataCell(Center(child: Text(data['year'].toString()))),
            DataCell(Center(child: Text(data['Total Expenses']))),
            DataCell(Center(child: Text(data['Interest (Yearly)']))),
            DataCell(Center(child: Text(data['Interest (Total)']))),
            DataCell(Center(child: Text(data['Total Value']))),
            DataCell(Center(child: Text(data['Inflation Adjusted']))),
          ]);
        }).toList(),
        headingRowHeight: 56,
        showBottomBorder: true,
        fixedLeftColumns: 1,
      ),
    );
  }
}
