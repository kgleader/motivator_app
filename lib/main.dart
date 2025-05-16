import 'package:flutter/material.dart';
import 'screens/quote_screen.dart';

void main() {
  runApp(const MotivatorApp());
}

class MotivatorApp extends StatefulWidget {
  const MotivatorApp({super.key});

  @override
  State<MotivatorApp> createState() => _MotivatorAppState();
}

class _MotivatorAppState extends State<MotivatorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мотиватор дня',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: QuoteScreen(onToggleTheme: _toggleTheme),
    );
  }
}
