import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:passenger_managing_app/models/page_state.dart';
import 'package:passenger_managing_app/screens/modern_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<List<PageState>> _getSavedPages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pagesDataString = prefs.getString('temp_pages_data');
      
      if (pagesDataString != null) {
        final pagesData = jsonDecode(pagesDataString) as List;
        return pagesData.map((pageData) {
          final page = PageState();
          
          // Restore basic properties
          page.selectedDate = DateTime.parse(pageData['selectedDate']);
          page.selectedTime = TimeOfDay(
            hour: pageData['selectedTime']['hour'],
            minute: pageData['selectedTime']['minute']
          );
          
          // Restore counts
          page.passengerCount = pageData['passengerCount'] ?? 0;
          page.onlinePassengerCount = pageData['onlinePassengerCount'] ?? 0;
          page.cashPassengerCount = pageData['cashPassengerCount'] ?? 0;
          page.cardPassengerCount = pageData['cardPassengerCount'] ?? 0;
          page.wizzPassengerCount = pageData['wizzPassengerCount'] ?? 0;
          
          // Restore child counters
          page.showCashChildCounter = pageData['showCashChildCounter'] ?? false;
          page.showCardChildCounter = pageData['showCardChildCounter'] ?? false;
          page.cashChildPassengerCount = pageData['cashChildPassengerCount'] ?? 0;
          page.cardChildPassengerCount = pageData['cardChildPassengerCount'] ?? 0;
          
          // Restore way states
          page.showOnTheWay = pageData['showOnTheWay'] ?? false;
          page.onTheWayCashCount = pageData['onTheWayCashCount'] ?? 0;
          
          // Restore free passengers
          page.showFreePessangers = pageData['showFreePessangers'] ?? false;
          page.freePassengersCount = pageData['freePassengersCount'] ?? 0;
          
          // Restore selections
          page.selectedTransferOptions = List<String>.from(pageData['selectedTransferOptions'] ?? []);
          page.selectedSingleOption = pageData['selectedSingleOption'] ?? '';
          page.selectedDriverName = pageData['selectedDriverName'] ?? '';
          
          // Restore controller values
          page.passengerController.text = pageData['passengerControllerText'] ?? '';
          page.onTheWayController.text = pageData['onTheWayControllerText'] ?? '';
          page.freePassengersController.text = pageData['freePassengersControllerText'] ?? '';
          
          return page;
        }).toList();
      }
      return [PageState()]; // Return default page if no saved data
    } catch (e) {
      return [PageState()]; // Return default page on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer header with app logo or titleS
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_bus,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'მგზავრთა მართვა',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation items
            ListTile(
              leading: const Icon(
                Icons.home,
                size: 28,
                color: Colors.blue,
              ),
              title: const Text(
                'მთავარი გვერდი',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                final savedPages = await _getSavedPages();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModernHomeScreen(
                        initialPages: savedPages,
                      ),
                    ),
                  );
                }
              },           
            ),
            
            const Divider(height: 1),
            
            ListTile(
              leading: const Icon(
                Icons.person,
                size: 28,
                color: Colors.blue,
              ),
              title: const Text(
                'მძღოლები',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/drivers');
              },
            ),
            
            const Divider(height: 1),
            
            // Spacer to push the version info to the bottom
            const Spacer(),
            
            // Version info at the bottom
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'ვერსია 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}