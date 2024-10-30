import 'package:flutter/material.dart';

class SalaryTable extends StatelessWidget {
  final int duration;
  final List<double> accumulatedSalaries;

  const SalaryTable({
    super.key,
    required this.duration,
    required this.accumulatedSalaries,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Year')),
            DataColumn(label: Text('Accumulated After Tax & Inflation')),
          ],
          rows: List<DataRow>.generate(
            duration + 1,
            (index) => DataRow(
              cells: [
                DataCell(Text('$index')),
                DataCell(Text(accumulatedSalaries[index].toStringAsFixed(0))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
