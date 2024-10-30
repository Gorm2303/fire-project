import 'package:flutter/material.dart';

class SalaryTab extends StatefulWidget {
  
  const SalaryTab({Key? key}) : super(key: key);

  @override
  _SalaryTabState createState() => _SalaryTabState();
}

class _SalaryTabState extends State<SalaryTab> {
  @override
  Widget build(BuildContext context) {
    return const Text('Salary Calculator');
  }
}