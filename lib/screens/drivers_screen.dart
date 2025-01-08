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

  void _showAddDriverDialog() {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    String? selectedBus;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Driver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Name Input
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 8),
              // Last Name Input
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 8),
              // Dropdown for Bus Selection
              DropdownButtonFormField<String>(
                value: selectedBus,
                items: drivers
                    .map((driver) => driver.busNumber)
                    .toSet() // Remove duplicates
                    .map((bus) => DropdownMenuItem(
                          value: bus,
                          child: Text(bus),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  selectedBus = value!;
                }),
                decoration: const InputDecoration(labelText: 'Select Bus'),
              ),
            ],
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            // Submit Button
            ElevatedButton(
              onPressed: () async {
                final firstName = firstNameController.text.trim();
                final lastName = lastNameController.text.trim();

                if (firstName.isEmpty ||
                    lastName.isEmpty ||
                    selectedBus == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                Navigator.of(context).pop();

                // Make POST request to add new driver
                await _addDriver(firstName, lastName, selectedBus!);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDriver(
      String firstName, String lastName, String busNumber) async {
    setState(() => isLoading = true);

    try {
      final newDriver = Driver(
        firstName: firstName,
        lastName: lastName,
        busNumber: busNumber,
        phoneNumber: '', // Default or placeholder phone number
      );

      // Call your service to make a POST request
      await _driverService.addDriver(newDriver);

      setState(() {
        drivers.add(newDriver);
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver added successfully!')),
      );
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding driver: $e')),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(' ', ''),
    );
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
        onPressed: _showAddDriverDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
