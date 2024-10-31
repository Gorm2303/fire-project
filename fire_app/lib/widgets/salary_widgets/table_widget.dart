import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class SalaryTable extends StatelessWidget {
  final List<Map<String, dynamic>> tableData;


  const SalaryTable({
    super.key,
    required this.tableData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: const [
          DataColumn(label: Text('Year')),
          DataColumn(label: Text('Salary (Monthly)')),
          DataColumn(label: Text('Salary (Total)')),
          DataColumn(label: Text('After Tax')),
          DataColumn(label: Text('Inflation Adjusted')),
        ],
        rows: tableData.map((data) {
          return DataRow(cells: [
            DataCell(Text(data['year'].toString())),
            DataCell(Text(data['Salary (Monthly)'])),
            DataCell(Text(data['Salary (Total)'])),
            DataCell(Text(data['After Tax'])),
            DataCell(Text(data['Inflation Adjusted'])),
          ]);
        }).toList(),
      ),
    );
  }
}
