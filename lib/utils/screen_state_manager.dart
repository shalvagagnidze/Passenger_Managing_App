import 'package:passenger_managing_app/models/night_flight.dart';
import 'package:passenger_managing_app/models/page_state.dart';

class ScreenStateManager {
  static final ScreenStateManager _instance = ScreenStateManager._internal();
  factory ScreenStateManager() => _instance;
  ScreenStateManager._internal();

  List<PageState> pages = [];
  int currentPageIndex = 0;
  List<NightFlight> nightFlights = [];
  bool isInitialized = false;
}