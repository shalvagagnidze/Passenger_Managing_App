import 'package:flutter/material.dart';
import 'package:passenger_managing_app/models/driver.dart';
import 'package:passenger_managing_app/services/bus_service.dart';
import 'package:passenger_managing_app/services/driver_service.dart';
import 'package:passenger_managing_app/utils/sorting_utils.dart';
import 'package:passenger_managing_app/widgets/add_entity_dialog.dart';
import 'package:passenger_managing_app/widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  _DriversScreenState createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  // Sample data - replace with your actual data source
  final BusService _busService = BusService();
  late final DriverService _driverService;
  bool isLoading = false;
  String? error;
  List<Driver> drivers = [];

  @override
  void initState() {
    super.initState();
    _driverService = DriverService(_busService);
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final fetchedDrivers = await _driverService.getAllDrivers();

      fetchedDrivers.sort((a, b) => compareDriversByBusNumber(a.busNumber, b.busNumber));

      setState(() {
        drivers = fetchedDrivers;
        isLoading = false;
      });

      final buses = await _busService.getAllBuses();
      setState(() {
        _buses = buses;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<String> _buses = [];



  void _showAddEntityDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AddEntityDialog(
          existingBuses: _buses,  // Use buses from BusService
          driverService: _driverService,
          busService: _busService,
          onSuccess: () {
            _loadDrivers();
            //_loadBuses();  // Reload both drivers and buses after successful addition
          },
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(' ', ''),
    );
    await launchUrl(launchUri);
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
                                  driver.busNumber.toString(),
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
        onPressed: _showAddEntityDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
