import 'package:flutter/material.dart';

class InvestmentTableWidget extends StatelessWidget {
  final List<Map<String, double>> yearlyValues;

  const InvestmentTableWidget({super.key, 
    required this.yearlyValues,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,  // Enable horizontal scrolling
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Year')),
          DataColumn(label: Text('Total Value (kr)')),
          DataColumn(label: Text('Total Deposits (kr)')),
          DataColumn(label: Text('Compound Earnings (kr)')),
        ],
        rows: yearlyValues.map((value) {
          return DataRow(cells: [
            DataCell(Text(value['year']!.toInt().toString())),
            DataCell(Text(value['totalValue']!.toStringAsFixed(0))),
            DataCell(Text(value['totalDeposits']!.toStringAsFixed(0))),
            DataCell(Text(value['compoundEarnings']!.toStringAsFixed(0))),
          ]);
        }).toList(),
      ),
    );
  }
}
