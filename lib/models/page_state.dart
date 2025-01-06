import 'package:flutter/material.dart';
import 'package:passenger_managing_app/models/passenger_data.dart';

class PageState {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController passengerController = TextEditingController();
  final TextEditingController onTheWayController = TextEditingController();
  final TextEditingController freePassengersController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final FocusNode freePassengersFocus = FocusNode();

  int passengerCount = 0;
  int onlinePassengerCount = 0;
  int cashPassengerCount = 0;
  int cardPassengerCount = 0;
  int wizzPassengerCount = 0;

  bool showCashChildCounter = false;
  bool showCardChildCounter = false;
  int cashChildPassengerCount = 0;
  int cardChildPassengerCount = 0;

  bool showOnTheWay = false;
  int onTheWayCashCount = 0;

  bool showFreePessangers = false;
  int freePassengersCount = 0;

  List<String> selectedTransferOptions = [];
  String selectedSingleOption = '';

  void dispose() {
    passengerController.dispose();
    onTheWayController.dispose();
    freePassengersController.dispose();
    focusNode.dispose();
    freePassengersFocus.dispose();
  }

  PassengerData toPassengerData() {
    double standardRate = 25.0;
    double childRate = 15.0;

    double totalCashAmount = (cashPassengerCount - cashChildPassengerCount) * standardRate +
        cashChildPassengerCount * childRate;

    double totalCardAmount = (cardPassengerCount - cardChildPassengerCount) * standardRate +
        cardChildPassengerCount * childRate;

    return PassengerData(
      date: selectedDate,
      hours: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
      route: selectedTransferOptions,
      bus: selectedSingleOption,
      totalPassengers: passengerCount,
      onlinePassengers: onlinePassengerCount,
      cashPassengers: cashPassengerCount,
      cashChild: cashChildPassengerCount,
      cardPassengers: cardPassengerCount,
      cardChild: cardChildPassengerCount,
      wizzAirPassengers: wizzPassengerCount,
      freePassengers: int.tryParse(freePassengersController.text) ?? 0,
      onTheWayPassengers: int.tryParse(onTheWayController.text) ?? 0,
      onTheWayCash: onTheWayCashCount,
      totalCashAmount: totalCashAmount,
      totalCardAmount: totalCardAmount,
    );
}
}