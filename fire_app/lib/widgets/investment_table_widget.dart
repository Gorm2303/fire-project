import 'package:flutter/material.dart';

class InvestmentTableWidget extends StatelessWidget {
  final List<Map<String, double>> yearlyValues;
  final bool showTotalDeposits;  // Flag to show or hide total deposits column

  const InvestmentTableWidget({
    super.key,
    required this.yearlyValues,
    this.showTotalDeposits = true,  // Default to true for the first table
  });

  @override
  Widget build(BuildContext context) {
    // Safeguard: Ensure that the yearlyValues list is not empty
    if (yearlyValues.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,  // Enable horizontal scrolling
      child: DataTable(
        columns: showTotalDeposits
            ? const [
                DataColumn(label: Text('Year', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Value (kr)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Deposits (kr)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Annual Compound (kr)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Compound (kr)', style: TextStyle(fontWeight: FontWeight.bold))),
              ]
            : const [
                DataColumn(label: Text('Year', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Value (kr)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Annual Compound (kr)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total Compound (kr)', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
        rows: yearlyValues.map((value) {
          return DataRow(cells: [
            DataCell(Text(value['year']!.toInt().toString())),
            DataCell(Text(value['totalValue']!.toStringAsFixed(0))),
            if (showTotalDeposits) DataCell(Text(value['totalDeposits']!.toStringAsFixed(0))),  // Total Deposits column in correct position
            DataCell(Text(value['compoundThisYear']!.toStringAsFixed(0))),  // Display Annual Compound
            DataCell(Text(value['compoundEarnings']!.toStringAsFixed(0))),  // Display Total Compound
          ]);
        }).toList(),
      ),
    );
  }
}
