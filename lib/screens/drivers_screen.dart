import 'package:flutter/material.dart';
import 'package:passenger_managing_app/models/driver.dart';
import 'package:passenger_managing_app/services/driver_service.dart';
import 'package:passenger_managing_app/widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  _DriversScreenState createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  // Sample data - replace with your actual data source
  final DriverService _driverService = DriverService();
  bool isLoading = false;
  String? error;
  List<Driver> drivers = [];
  

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    // Sort the drivers by the numeric part of busNumber
    // drivers.sort((a, b) {
    //   final aNumber = int.tryParse(_extractNumber(a.busNumber)) ?? 0;
    //   final bNumber = int.tryParse(_extractNumber(b.busNumber)) ?? 0;
    //   return aNumber.compareTo(bNumber);
    // });
  }

  Future<void> _loadDrivers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetchedDrivers = await _driverService.getAllDrivers();

      setState(() {
        drivers = fetchedDrivers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // String _extractNumber(String busNumber) {
  //   final match = RegExp(r'\d+').firstMatch(busNumber);
  //   return match?.group(0) ?? '0'; // Return '0' if no match is found
  // }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(' ', ''),
    );
    print(await canLaunchUrl(Uri.parse('tel:+995555456789')));
    await launchUrl(launchUri);
    // if (await canLaunchUrl(launchUri)) {
    //   await launchUrl(launchUri);
    // } else {
    //   throw 'Could not launch $launchUri';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'მძღოლები',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrivers,
          ),
        ],
      ),
      drawer: const AppDrawer(), // Using the previously created drawer
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      ElevatedButton(
                        onPressed: _loadDrivers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  driver.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.directions_bus,
                                    color: Colors.blueGrey),
                                const SizedBox(width: 8),
                                Text(
                                  driver.busId.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: () => _makePhoneCall(driver.phoneNumber),
                            child: Row(
                              children: [
                                const Icon(Icons.phone, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  driver.phoneNumber,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone_forwarded),
                          color: Colors.green,
                          onPressed: () => _makePhoneCall(driver.phoneNumber),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new driver functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Add new driver functionality coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
