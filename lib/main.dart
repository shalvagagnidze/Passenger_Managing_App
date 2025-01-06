import 'package:flutter/material.dart';
import 'package:passenger_managing_app/screens/drivers_screen.dart';
import 'package:passenger_managing_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DriversScreen(),
      routes: {
        //'/': (context) => const HomeScreen(),
        '/drivers': (context) => const HomeScreen(), // Create this screen
      },
    );
  }
}
