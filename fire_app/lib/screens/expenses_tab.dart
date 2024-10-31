import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/widgets/expense_widgets/input_form.dart';
import 'package:fire_app/widgets/expense_widgets/list_widget.dart';
import 'package:fire_app/widgets/expense_widgets/parameter_inputs.dart';
import 'package:fire_app/widgets/expense_widgets/chart_widget.dart';
import 'package:fire_app/widgets/expense_widgets/table_widget.dart';
import '../models/expense.dart';
import '../services/expense_calculator.dart';

class ExpensesTab extends StatefulWidget {
  final double maxWidth;
  const ExpensesTab({super.key, required this.maxWidth});

  @override
  _ExpensesTabState createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> with SingleTickerProviderStateMixin {
  final List<Expense> _expenses = [];
  final TextEditingController _expenseController = TextEditingController(text: '10000');
  final TextEditingController _interestRateController = TextEditingController(text: '7');
  final TextEditingController _inflationRateController = TextEditingController(text: '2');
  final TextEditingController _durationController = TextEditingController(text: '50');
  
  String _selectedFrequency = 'One Time';
  final List<String> _frequencies = ['One Time', 'Yearly', 'Monthly'];
  late final TabController _tableTabController = TabController(length: 1, vsync: this);

  List<Map<String, dynamic>> _tableData = [];
  List<FlSpot> _graphDataTotalValue = [];
  List<FlSpot> _graphDataTotalExpenses = [];
  List<FlSpot> _graphDataInflationAdjusted = [];

  @override
  void dispose() {
    _tableTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ExpenseInputForm(
          expenseController: _expenseController,
          frequencies: _frequencies,
          selectedFrequency: _selectedFrequency,
          onFrequencyChanged: (newFrequency) => setState(() => _selectedFrequency = newFrequency),
          onAddExpense: _addExpense,
        ),
        ExpenseList(
          expenses: _expenses,
          onToggleExpense: (index) {
            setState(() {
              _expenses[index].isSelected = !_expenses[index].isSelected;
            });
            _calculateTableData();
          },
          onRemoveExpense: (index) {
            setState(() {
              _expenses.removeAt(index);
            });
            _calculateTableData();
          },
        ),
        ExpenseParameterInputs(
          interestRateController: _interestRateController,
          inflationRateController: _inflationRateController,
          durationController: _durationController,
          onParameterChanged: _calculateTableData,
        ),
        ExpenseLineChart(
          graphDataTotalValue: _graphDataTotalValue,
          graphDataTotalExpenses: _graphDataTotalExpenses,
          graphDataInflationAdjusted: _graphDataInflationAdjusted,
        ),
        TabBar(
          controller: _tableTabController,
          tabs: const [Tab(text: 'Expenses')],
        ),
        SizedBox(
          height: 475,
          child: TabBarView(
            controller: _tableTabController,
            children: [
              ExpenseTable(
                tableTabController: _tableTabController,
                tableData: _tableData,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addExpense() {
    double expenseAmount = double.tryParse(_expenseController.text) ?? 0;
    Expense newExpense = Expense(amount: expenseAmount, frequency: _selectedFrequency);
    
    setState(() {
      _expenses.add(newExpense);
    });

    _calculateTableData();
  }

  void _calculateTableData() {
    ExpenseCalculator calculator = ExpenseCalculator(
      expenses: _expenses,
      interestRate: double.tryParse(_interestRateController.text) ?? 0,
      inflationRate: double.tryParse(_inflationRateController.text) ?? 0,
      duration: int.tryParse(_durationController.text) ?? 50,
    );

    final results = calculator.calculate();

    setState(() {
      _tableData = results['tableData'];
      _graphDataTotalExpenses = results['graphDataTotalExpenses'];
      _graphDataTotalValue = results['graphDataTotalValue'];
      _graphDataInflationAdjusted = results['graphDataInflationAdjusted'];
    });
  }
}
