import 'package:http/http.dart' as http;
import 'package:passenger_managing_app/models/driver.dart';
import 'dart:convert';


class DriverService {
  static const String baseUrl = 'http://localhost:5004';

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
}