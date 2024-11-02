import 'package:flutter/material.dart';
import 'widgets/calculator_screen.dart';
import 'tabs/statistics_tab.dart';
import 'tabs/settings_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FireApp());
}

class FireApp extends StatefulWidget {
  const FireApp({super.key});

  @override
  _FireAppState createState() => _FireAppState();
}

class _FireAppState extends State<FireApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode(); // Load theme mode on startup
  }

  // Toggle and save theme mode
  void toggleTheme(bool isDarkMode) async {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode); // Save theme mode preference
  }

  // Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire App',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode, // Set the theme mode dynamically
      home: HomeScreen(onThemeChanged: toggleTheme), // Pass theme toggle to HomeScreen
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged; // Callback for theme change

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the pages used in each tab
    List<Widget> pages = <Widget>[
      const CalculatorScreen(),
      const StatisticsTab(),
      SettingsTab(onThemeChanged: widget.onThemeChanged), // Pass theme toggle to SettingsTab
    ];

    return Scaffold(
      // Remove the appBar property entirely if not needed
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
