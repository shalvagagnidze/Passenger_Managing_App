import 'package:http/http.dart' as http;
import 'package:passenger_managing_app/models/driver.dart';
import 'dart:convert';

import 'package:passenger_managing_app/services/bus_service.dart';


class DriverService {
  static const String baseUrl = 'https://passengermanagingapp-production.up.railway.app';

  final BusService _busService;

  DriverService(this._busService);

  Future<List<Driver>> getAllDrivers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Driver/get-all-drivers'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Driver.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load drivers: $e');
    }
  }

  Future<void> addDriver(Driver driver) async {
    try {
      // First get the bus ID from the bus number
      final busId = await _busService.getBusIdByNumber(driver.busNumber);

      final response = await http.post(
        Uri.parse('$baseUrl/Driver/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': driver.firstName,
          'lastName': driver.lastName,
          'busId': busId, 
          'phoneNumber': driver.phoneNumber,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to add driver: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to add driver: $e');
    }
  }

  Future<void> updateDriver(Driver driver) async {
    try {
      // First, get all buses to find the matching bus ID
      final buses = await _busService.getAllBuses();
      final bus = buses.firstWhere(
        (bus) => bus.number == driver.busNumber,
        orElse: () => throw Exception('Bus not found with number: ${driver.busNumber}'),
      );

      // Prepare the update data according to your API model
      final updateData = {
        'id': driver.id,
        'firstName': driver.firstName,
        'lastName': driver.lastName,
        'phoneNumber': driver.phoneNumber.startsWith('+995') 
            ? driver.phoneNumber.substring(4) // Remove +995 if it exists
            : driver.phoneNumber,
        'busId': bus.id, // Use the bus ID from the matched bus
      };

      final response = await http.put(
        Uri.parse('$baseUrl/Driver/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update driver: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating driver: $e');
    }
  }

  Future<void> deleteDriver(int driverId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Driver/delete/$driverId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete driver: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting driver: $e');
    }
  }

}