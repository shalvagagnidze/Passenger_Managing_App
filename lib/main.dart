import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:passenger_managing_app/models/page_state.dart';
import 'package:passenger_managing_app/screens/drivers_screen.dart';
import 'package:passenger_managing_app/screens/modern_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  String? pagesDataString =
      prefs.getString('temp_pages_data'); // Change key to temp_pages_data

  pagesDataString ??= prefs.getString('backup_pages_data');

  //final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
  List<PageState> initialPages = [];

  if (pagesDataString != null) {
    try {
      final pagesData = jsonDecode(pagesDataString) as List;
      initialPages = await Future.wait(pagesData.map((pageData) async {
        final page = PageState();
        
        // Restore all the values
        page.selectedDate = DateTime.parse(pageData['selectedDate']);
        page.selectedTime = TimeOfDay(
          hour: pageData['selectedTime']['hour'],
          minute: pageData['selectedTime']['minute']
        );
        
        // Make sure to set the text values before adding listeners
        page.passengerController = TextEditingController(
          text: pageData['passengerControllerText'] ?? ''
        );
        page.onTheWayController = TextEditingController(
          text: pageData['onTheWayControllerText'] ?? ''
        );
        page.freePassengersController = TextEditingController(
          text: pageData['freePassengersControllerText'] ?? ''
        );
        
        page.passengerCount = pageData['passengerCount'] ?? 0;
        page.onlinePassengerCount = pageData['onlinePassengerCount'] ?? 0;
        page.cashPassengerCount = pageData['cashPassengerCount'] ?? 0;
        page.cardPassengerCount = pageData['cardPassengerCount'] ?? 0;
        page.wizzPassengerCount = pageData['wizzPassengerCount'] ?? 0;
        
        page.showCashChildCounter = pageData['showCashChildCounter'] ?? false;
        page.showCardChildCounter = pageData['showCardChildCounter'] ?? false;
        page.cashChildPassengerCount = pageData['cashChildPassengerCount'] ?? 0;
        page.cardChildPassengerCount = pageData['cardChildPassengerCount'] ?? 0;
        
        page.showOnTheWay = pageData['showOnTheWay'] ?? false;
        page.onTheWayCashCount = pageData['onTheWayCashCount'] ?? 0;
        
        page.showFreePessangers = pageData['showFreePessangers'] ?? false;
        page.freePassengersCount = pageData['freePassengersCount'] ?? 0;
        
        page.selectedTransferOptions = List<String>.from(pageData['selectedTransferOptions'] ?? []);
        page.selectedSingleOption = pageData['selectedSingleOption'] ?? '';
        page.selectedDriverName = pageData['selectedDriverName'] ?? '';
        
        return page;
      }));
    } catch (e) {
      initialPages = [PageState()];
    }
  } else {
    initialPages = [PageState()];
  }

  runApp(MyApp(initialPages: initialPages));
}

class MyApp extends StatelessWidget {
  final List<PageState> initialPages;

  const MyApp({super.key, required this.initialPages});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ModernHomeScreen(initialPages: initialPages),
      routes: {
        '/drivers': (context) => const DriversScreen(),
      },
    );
  }
}
