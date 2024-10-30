import 'package:flutter/material.dart';

class TabMenuWidget extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const TabMenuWidget({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  _TabMenuWidgetState createState() => _TabMenuWidgetState();
}

class _TabMenuWidgetState extends State<TabMenuWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.selectedIndex,
    );

    // Update the index when the tab is changed
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prevent expanding to infinite height
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Salary'),
            Tab(text: 'Expenses'),
            Tab(text: 'Investments'),
          ],
        ),
      ],
    );
  }
}