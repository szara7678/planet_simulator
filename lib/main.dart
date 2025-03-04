// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/advanced_simulation_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '최초의신: 고도화된 생태계',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AdvancedSimulationScreen(),
    );
  }
}
