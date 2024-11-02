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
          DataColumn2(label: Center(child: Text('Year')), size: ColumnSize.S),
          DataColumn2(label: Center(child: Text('Salary (Monthly)')), size: ColumnSize.M),
          DataColumn2(label: Center(child: Text('Salary (Total)')), size: ColumnSize.M),
          DataColumn2(label: Center(child: Text('After Tax')), size: ColumnSize.M),
          DataColumn2(label: Center(child: Text('Inflation Adjusted')), size: ColumnSize.M),
        ],
        rows: tableData.map((data) {
          return DataRow(cells: [
            DataCell(Center(child: Text(data['year'].toString()))),
            DataCell(Center(child: Text(data['Salary (Monthly)']))),
            DataCell(Center(child: Text(data['Salary (Total)']))),
            DataCell(Center(child: Text(data['After Tax']))),
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
