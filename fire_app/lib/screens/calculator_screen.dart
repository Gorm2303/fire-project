import 'package:fire_app/screens/expenses_tab.dart';
import 'package:fire_app/screens/investment_tab.dart';
import 'package:fire_app/screens/salary_tab.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/widgets/tab_menu_widget.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with TickerProviderStateMixin {
  late TabController _mainTabController;
  int _selectedTab = 0;
  static const double maxWidth = 550;

  @override
  void initState() {
    super.initState();

    _initializeTabControllers();
  }

  void _initializeTabControllers() {
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    
    super.dispose(); // Ensure super.dispose() is always called last
  }

  Widget investmentCalculatorContent() {
    return const InvestmentTab(maxWidth: maxWidth);
  }

  Widget expensesCalculatorContent() {
    return const ExpensesTab(maxWidth: maxWidth);
  }

  Widget salaryCalculatorContent() {
    return const SalaryTab(maxWidth: maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevents infinite height issues
          children: [
              const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Compound Interest Calculators',
                style: TextStyle(fontSize: 24),
              ),
              ),
            TabMenuWidget(
              selectedIndex: _selectedTab, // Pass the selected tab index
              onChanged: (int newIndex) {
                setState(() {
                  _selectedTab = newIndex; // Update tab index when changed
                });
              },
            ),
              _selectedTab == 0
                ? salaryCalculatorContent()
                : _selectedTab == 1
                  ? expensesCalculatorContent()
                  : investmentCalculatorContent(),
          ],
        ),
      ),
    );
  }
}
