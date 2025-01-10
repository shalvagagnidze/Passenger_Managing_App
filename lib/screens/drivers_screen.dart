import 'package:flutter/material.dart';
import 'package:passenger_managing_app/models/bus.dart';
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
  final BusService _busService = BusService();
  late final DriverService _driverService;
  bool isLoading = false;
  String? error;
  List<Driver> drivers = [];
  List<Bus> _buses = [];

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
      fetchedDrivers
          .sort((a, b) => compareDriversByBusNumber(a.busNumber, b.busNumber));

      final buses = await _busService.getAllBuses();

      setState(() {
        drivers = fetchedDrivers;
        _buses = buses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _showAddEntityDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AddEntityDialog(
          existingBuses:_buses.map((bus) => bus.number).toList(), // Use buses from BusService
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

  Future<void> _showUpdateDialog(Driver driver) async {
    final TextEditingController firstNameController =
        TextEditingController(text: driver.firstName);
    final TextEditingController lastNameController =
        TextEditingController(text: driver.lastName);
    final TextEditingController phoneController =
        TextEditingController(text: driver.phoneNumber);
    String selectedBus = driver.busNumber;

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.grey[50],
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  
                  const SizedBox(width: 16),
                  const Text(
                    'მძღოლის განახლება',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Fields
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'სახელი',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'გვარი',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'ტელეფონის ნომერი',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: selectedBus,
                items: _buses
                    .map((bus) => DropdownMenuItem(
                          value: bus.number,
                          child: Text(bus.number),
                        ))
                    .toList(),
                onChanged: (value) => selectedBus = value!,
                decoration: InputDecoration(
                  labelText: 'ავტობუსი',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.directions_bus_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('გაუქმება'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _driverService.updateDriver(Driver(
                          id: driver.id,
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          phoneNumber: phoneController.text,
                          busNumber: selectedBus,
                        ));
                        
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        _loadDrivers();
                        
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('მძღოლი წარმატებით განახლდა'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('შეცდომა: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('განახლება'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Driver driver) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'წაშლის დადასტურება',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'დარწმუნებული ხართ, რომ გსურთ წაშალოთ მძღოლი ${driver.fullName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('გაუქმება'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _driverService.deleteDriver(driver.id!);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        _loadDrivers();
                        
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('მძღოლი წარმატებით წაიშალა'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('შეცდომა: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('წაშლა'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadDrivers,
        child: isLoading
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      return Dismissible(
                        key: Key(driver.id.toString()),
                        background: Container(
                          color: Colors.orange,
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // Update
                            await _showUpdateDialog(driver);
                            return false; // Don't dismiss
                          } else {
                            // Delete
                            await _showDeleteConfirmation(driver);
                            return false; // Don't dismiss, we'll handle it in the dialog
                          }
                        },
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                                    const Icon(Icons.directions_bus, color: Colors.blueGrey),
                                    const SizedBox(width: 8),
                                    Text(
                                      driver.busNumber,
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
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntityDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
