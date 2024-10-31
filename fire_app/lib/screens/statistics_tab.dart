import 'package:flutter/material.dart';

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({Key? key}) : super(key: key);

  @override
  _StatisticsTabState createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  // Example statistics data
  final double totalIncome = 120000; // example data
  final double totalExpenses = 45000; // example data
  final double savingsRate = 25.0; // example data
  final double projectedGrowth = 5.0; // example data

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Display statistics in cards
          Card(
            child: ListTile(
              title: const Text('Total Income'),
              subtitle: Text('\$${totalIncome.toStringAsFixed(0)}'),
              leading: const Icon(Icons.attach_money, color: Colors.green),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Total Expenses'),
              subtitle: Text('\$${totalExpenses.toStringAsFixed(0)}'),
              leading: const Icon(Icons.money_off, color: Colors.red),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Savings Rate'),
              subtitle: Text('${savingsRate.toStringAsFixed(1)}%'),
              leading: const Icon(Icons.savings, color: Colors.blue),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Projected Growth'),
              subtitle: Text('${projectedGrowth.toStringAsFixed(1)}%'),
              leading: const Icon(Icons.show_chart, color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
