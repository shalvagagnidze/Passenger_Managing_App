import 'package:flutter/material.dart';
import 'package:passenger_managing_app/models/passenger_data.dart';

class PageState {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  late TextEditingController passengerController = TextEditingController();
  late TextEditingController onTheWayController = TextEditingController();
  late TextEditingController freePassengersController = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode freePassengersFocus = FocusNode();

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
  String selectedDriverName = '';
  bool _isDisposed = false;

   PageState()
      : passengerController = TextEditingController(),
        onTheWayController = TextEditingController(),
        freePassengersController = TextEditingController(),
        focusNode = FocusNode(),
        freePassengersFocus = FocusNode();

  // void dispose() {
  //   passengerController.dispose();
  //   onTheWayController.dispose();
  //   freePassengersController.dispose();
  //   focusNode.dispose();
  //   freePassengersFocus.dispose();
  // }

  void dispose() {
    if (!_isDisposed) {
      passengerController.dispose();
      onTheWayController.dispose();
      freePassengersController.dispose();
      focusNode.dispose();
      freePassengersFocus.dispose();
      _isDisposed = true;
    }
  }

  void resetControllers() {
    passengerController.clear();
    freePassengersController.clear();
    onTheWayController.clear();
  }

 void recreateControllers() {
    // Store current values
    final passengerText = passengerController.text;
    final onTheWayText = onTheWayController.text;
    final freePassengersText = freePassengersController.text;
    
    // Dispose old controllers
    passengerController.dispose();
    onTheWayController.dispose();
    freePassengersController.dispose();
    
    // Create new controllers with previous values
    passengerController = TextEditingController(text: passengerText);
    onTheWayController = TextEditingController(text: onTheWayText);
    freePassengersController = TextEditingController(text: freePassengersText);
  }

  PassengerData toPassengerData() {
    double standardRate = 25.0;
    double childRate = 15.0;

    double totalCashAmount =
        (cashPassengerCount - cashChildPassengerCount) * standardRate +
            cashChildPassengerCount * childRate;

    double totalCardAmount =
        (cardPassengerCount - cardChildPassengerCount) * standardRate +
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
      bus: '$selectedDriverName $selectedSingleOption',
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

  static PageState fromJson(Map<String, dynamic> json) {
    final page = PageState();

    page.selectedDate = DateTime.parse(json['selectedDate']);
    page.selectedTime = TimeOfDay(
        hour: json['selectedTime']['hour'],
        minute: json['selectedTime']['minute']);

    page.passengerCount = json['passengerCount'];
    page.onlinePassengerCount = json['onlinePassengerCount'];
    page.cashPassengerCount = json['cashPassengerCount'];
    page.cardPassengerCount = json['cardPassengerCount'];
    page.wizzPassengerCount = json['wizzPassengerCount'];

    page.showCashChildCounter = json['showCashChildCounter'];
    page.showCardChildCounter = json['showCardChildCounter'];
    page.cashChildPassengerCount = json['cashChildPassengerCount'];
    page.cardChildPassengerCount = json['cardChildPassengerCount'];

    page.showOnTheWay = json['showOnTheWay'];
    page.onTheWayCashCount = json['onTheWayCashCount'];

    page.showFreePessangers = json['showFreePessangers'];
    page.freePassengersCount = json['freePassengersCount'];

    page.selectedTransferOptions =
        List<String>.from(json['selectedTransferOptions']);
    page.selectedSingleOption = json['selectedSingleOption'];
    page.selectedDriverName = json['selectedDriverName'];

    // Restore text controller values
    page.passengerController.text = json['passengerControllerText'] ?? '';
    page.onTheWayController.text = json['onTheWayControllerText'] ?? '';
    page.freePassengersController.text =
        json['freePassengersControllerText'] ?? '';

    return page;
  }
}

extension PageStateJson on PageState {
  Map<String, dynamic> toJson() {
    return {
      'selectedDate': selectedDate.toIso8601String(),
      'selectedTime': {
        'hour': selectedTime.hour,
        'minute': selectedTime.minute
      },
      'passengerCount': passengerCount,
      'onlinePassengerCount': onlinePassengerCount,
      'cashPassengerCount': cashPassengerCount,
      'cardPassengerCount': cardPassengerCount,
      'wizzPassengerCount': wizzPassengerCount,
      'showCashChildCounter': showCashChildCounter,
      'showCardChildCounter': showCardChildCounter,
      'cashChildPassengerCount': cashChildPassengerCount,
      'cardChildPassengerCount': cardChildPassengerCount,
      'showOnTheWay': showOnTheWay,
      'onTheWayCashCount': onTheWayCashCount,
      'showFreePessangers': showFreePessangers,
      'freePassengersCount': freePassengersCount,
      'selectedTransferOptions': selectedTransferOptions,
      'selectedSingleOption': selectedSingleOption,
      'selectedDriverName': selectedDriverName,
      // Save text controller values
      'passengerControllerText': passengerController.text,
      'onTheWayControllerText': onTheWayController.text,
      'freePassengersControllerText': freePassengersController.text,
    };
  }
}
