import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:passenger_managing_app/models/bus.dart';
import 'package:passenger_managing_app/utils/sorting_utils.dart';

class BusService {
  static const String baseUrl = 'https://janiapp.azurewebsites.net';

  Future<void> addBus(String busNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Bus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': 0,
          'number': busNumber,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
            'პრობლემა ავტობუსის დამატებისას: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('პრობლემა ავტობუსის დამატებისას: $e');
    }
  }

  Future<List<Bus>> getAllBuses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Bus/get-all-buses'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final buses = jsonData.map((json) => Bus.fromJson(json)).toList();
        buses.sort((a, b) => compareDriversByBusNumber(a.number, b.number));
        return buses;
      } else {
        throw Exception('Failed to load buses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load buses: $e');
    }
  }

  Future<int> getBusIdByNumber(String busNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Bus/get-all-buses'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final bus = jsonData.firstWhere(
          (bus) => bus['number'] == busNumber,
          orElse: () => throw Exception('ავტობუსი ვერ მოიძებნა'),
        );
        return bus['id'] as int;
      } else {
        throw Exception('პრობლემა ავტობუსის ძიებისას: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('პრობლემა ავტობუსის ძიებისას: $e');
    }
  }
}
