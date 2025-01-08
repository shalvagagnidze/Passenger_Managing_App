import 'package:http/http.dart' as http;
import 'package:passenger_managing_app/models/driver.dart';
import 'dart:convert';


class DriverService {
  static const String baseUrl = 'http://janiapp.azurewebsites.net';

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
  final response = await http.post(
    Uri.parse('$baseUrl/Driver/add-drivers'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fistname': driver.fullName,
      'lastname': driver.lastName,
      'busId': driver.busNumber,
      'phoneNumber': driver.phoneNumber,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add driver');
  }
}

}