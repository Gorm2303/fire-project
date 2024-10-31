import 'package:fire_app/widgets/wrappers/card_wrapper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/widgets/expense_widgets/input_form.dart';
import 'package:fire_app/widgets/expense_widgets/list_widget.dart';
import 'package:fire_app/widgets/expense_widgets/parameter_inputs.dart';
import 'package:fire_app/widgets/expense_widgets/chart_widget.dart';
import 'package:fire_app/widgets/expense_widgets/table_widget.dart';
import '../models/expense.dart';
import '../services/expense_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesTab extends StatefulWidget {
  final double maxWidth;
  const ExpensesTab({super.key, required this.maxWidth});

  @override
  _ExpensesTabState createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> with SingleTickerProviderStateMixin {
  final TextEditingController _expenseController = TextEditingController(text: '10000');
  final TextEditingController _interestRateController = TextEditingController(text: '7');
  final TextEditingController _inflationRateController = TextEditingController(text: '2');
  final TextEditingController _durationController = TextEditingController(text: '50');
  
  String _selectedFrequency = 'One Time';
  final List<String> _frequencies = ['One Time', 'Yearly', 'Monthly'];
  late final TabController _tableTabController = TabController(length: 1, vsync: this);
  bool _isDataLoaded = false; // Add a flag to track if data has been loaded

  final List<Expense> _expenses = [];
  List<Map<String, dynamic>> _tableData = [];
  List<FlSpot> _graphDataTotalValue = [];
  List<FlSpot> _graphDataTotalExpenses = [];
  List<FlSpot> _graphDataInflationAdjusted = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Load saved data on initialization
  }

  @override
  void dispose() {
    _tableTabController.dispose();
    super.dispose();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenseAmount', _expenseController.text);
    await prefs.setString('interestRate', _interestRateController.text);
    await prefs.setString('inflationRate', _inflationRateController.text);
    await prefs.setString('duration', _durationController.text);
    await prefs.setString('selectedFrequency', _selectedFrequency);

    // Save expenses as a list of strings
    List<String> expenseList = _expenses.map((expense) =>
      '${expense.amount},${expense.frequency},${expense.isSelected}'
    ).toList();
    await prefs.setStringList('expenses', expenseList);
  }

  Future<void> _loadDataAndRecalculate() async {
    await _loadData(); // Load data from SharedPreferences
    _calculateTableData(); // Recalculate based on loaded data
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _expenseController.text = prefs.getString('expenseAmount') ?? '10000';
      _interestRateController.text = prefs.getString('interestRate') ?? '7';
      _inflationRateController.text = prefs.getString('inflationRate') ?? '2';
      _durationController.text = prefs.getString('duration') ?? '50';
      _selectedFrequency = prefs.getString('selectedFrequency') ?? 'One Time';

      // Load expenses
      final savedExpenses = prefs.getStringList('expenses') ?? [];
      _expenses.clear();
      for (String expenseString in savedExpenses) {
        final parts = expenseString.split(',');
        if (parts.length == 3) {
          final amount = double.tryParse(parts[0]) ?? 0.0;
          final frequency = parts[1];
          final isSelected = parts[2] == 'true';
          _expenses.add(Expense(amount: amount, frequency: frequency, isSelected: isSelected));
        }
      }
    });
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

    _saveData(); // Save data after calculations
  }
  
    @override
  Widget build(BuildContext context) {
    // Check if data has been loaded, and load + recalculate if not
    if (!_isDataLoaded) {
      _loadDataAndRecalculate();
      _isDataLoaded = true; // Set the flag to true after loading and calculating
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: widget.maxWidth,
          child: CardWrapper(
            title: 'Expenses Information',
            darkColor: Colors.red.shade900,
            lightColor: Colors.red.shade100,
            contentPadding: MediaQuery.of(context).size.width > widget.maxWidth
                ? const EdgeInsetsDirectional.symmetric(horizontal: 100, vertical: 0) 
                : MediaQuery.of(context).size.width > widget.maxWidth - 100 
                ? const EdgeInsetsDirectional.symmetric(horizontal: 75, vertical: 0)
                : MediaQuery.of(context).size.width > widget.maxWidth - 200
                ? const EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 0)
                : const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 0),
            children: [
              ExpenseInputForm(
                expenseController: _expenseController,
                frequencies: _frequencies,
                selectedFrequency: _selectedFrequency,
                onFrequencyChanged: (newFrequency) {
                  setState(() => _selectedFrequency = newFrequency);
                  _saveData(); // Save data after changing frequency
                },
                onAddExpense: _addExpense,
              ),
              ExpenseList(
                expenses: _expenses,
                onToggleExpense: (index) {
                  setState(() {
                    _expenses[index].isSelected = !_expenses[index].isSelected;
                  });
                  _calculateTableData();
                  _saveData(); // Save data after toggling selection
                },
                onRemoveExpense: (index) {
                  setState(() {
                    _expenses.removeAt(index);
                  });
                  _calculateTableData();
                  _saveData(); // Save data after removing an expense
                },
              ),
              ExpenseParameterInputs(
                interestRateController: _interestRateController,
                inflationRateController: _inflationRateController,
                durationController: _durationController,
                onParameterChanged: () {
                  _calculateTableData();
                  _saveData(); // Save data after changing parameters
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                tableData: _tableData,
              ),
            ],
          ),
        ),
      ],
    );
  }
}