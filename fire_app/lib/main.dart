import 'package:flutter/material.dart';
import 'screens/calculator_screen.dart';  // Import the calculator screen

void main() {
  runApp(const FireApp());
}

class FireApp extends StatelessWidget {
  const FireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),  // This will be the main screen of your app
      routes: {
        '/calculator': (context) => const CalculatorScreen(),  // Add a route for the calculator
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire App Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/calculator');
          },
          child: const Text('Go to Calculator'),
        ),
      ),
    );
  }
}
