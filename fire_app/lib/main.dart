import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';
import 'screens/statistics_tab.dart';
import 'screens/settings_tab.dart'; // Import the settings tab

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

  void toggleTheme(bool isDarkMode) {
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
    // Move _pages into build to access widget.onThemeChanged
    List<Widget> pages = <Widget>[
      const CalculatorScreen(),
      const StatisticsTab(),
      SettingsTab(onThemeChanged: widget.onThemeChanged), // Pass actual theme toggle
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire App Home'),
      ),
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
