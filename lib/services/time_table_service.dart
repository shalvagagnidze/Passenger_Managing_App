import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:passenger_managing_app/models/night_flight.dart';

class TimeTableService {
  static const String baseUrl = 'http://janiapp.azurewebsites.net'; 

  Future<List<NightFlight>> getNightFlights() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/TimeTable/get-timetable'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<NightFlight> nightFlights = [];

        // Parse entries
        for (var entry in data['entries']) {
          // Parse routes for each entry
          for (var route in entry['routes']) {
            // Convert departure time to DateTime for comparison
            final departureTime = _parseTime(route['departureTime']);
            if (_isNightFlight(departureTime)) {
              nightFlights.add(NightFlight(
                date: DateTime.parse(entry['date']),
                departureTime: departureTime,
                destinations: List<String>.from(route['destinations']),
              ));
            }
          }
        }
        
        return nightFlights;
      } else {
        throw Exception('Failed to load timetable');
      }
    } catch (e) {
      throw Exception('Error fetching timetable: $e');
    }
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 
      int.parse(parts[0]), int.parse(parts[1]));
  }

  bool _isNightFlight(DateTime time) {
    final hour = time.hour;
    return hour >= 22 || hour <= 6;
  }
}
