import 'package:http/http.dart' as http;
import 'package:passenger_managing_app/models/flight.dart';
import 'dart:convert';

class FlightService {
  static const String baseUrl = 'http://janiapp.azurewebsites.net';

  Future<List<Flight>> getAllFlights() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Flight/get-all-flights'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Flight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load flights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load flights: $e');
    }
  }
}