import 'package:intl/intl.dart';

class PassengerData {

  final DateTime date;
  final DateTime hours;
  final List<String> route;
  final String bus;
  final int totalPassengers;
  final int onlinePassengers;
  final int cashPassengers;
  final int cashChild;
  final int cardPassengers;
  final int cardChild;
  final int wizzAirPassengers;
  final int freePassengers;
  final int onTheWayPassengers;
  final int onTheWayCash;
  final double totalCashAmount;
  final double totalCardAmount;

  PassengerData({
    required this.date,
    required this.hours,
    required this.route,
    required this.bus,
    required this.totalPassengers,
    required this.onlinePassengers,
    required this.cashPassengers,
    required this.cashChild,
    required this.cardPassengers,
    required this.cardChild,
    required this.wizzAirPassengers,
    required this.freePassengers,
    required this.onTheWayPassengers,
    required this.onTheWayCash,
    required this.totalCashAmount,
    required this.totalCardAmount,
  });

  // String toJson() {
  //   Map<String, dynamic> json = {};

  //   // Always include date, time, route and bus
  //   json['date'] = DateFormat('yyyy-MM-dd').format(date);
  //   json['hours'] = DateFormat('HH:mm').format(hours);
  //   json['route'] = route;
  //   json['bus'] = bus;

  //   // Include other fields only if they're greater than 0
  //   if (totalPassengers > 0) json['totalPassengers'] = totalPassengers;
  //   if (onlinePassengers > 0) json['onlinePassengers'] = onlinePassengers;
    
  //   // Handle cash passengers with child notation
  //   if (cashPassengers > 0) {
  //     if (cashChild > 0) {
  //       json['cashPassengers'] = '$cashPassengers ($cashChild child)';
  //     } else {
  //       json['cashPassengers'] = cashPassengers;
  //     }
  //   }

  //   // Handle card passengers with child notation
  //   if (cardPassengers > 0) {
  //     if (cardChild > 0) {
  //       json['cardPassengers'] = '$cardPassengers ($cardChild child)';
  //     } else {
  //       json['cardPassengers'] = cardPassengers;
  //     }
  //   }

  //   if (onTheWayPassengers >0){
  //     if(onTheWayCash > 0){
  //       json['onTheWayPassengers'] = '$onTheWayPassengers ($onTheWayCash cash)';
  //     }else{
  //       json['onTheWayPassengers'] = onTheWayPassengers;
  //     }
  //   }

  //   if (wizzAirPassengers > 0) json['wizzAirPassengers'] = wizzAirPassengers;
  //   if (freePassengers > 0) json['freePassengers'] = freePassengers;
  //   if (onTheWayPassengers > 0) json['onTheWayPassengers'] = onTheWayPassengers;
  //   if (onTheWayCash > 0) json['onTheWayCash'] = onTheWayCash;
  //   if (totalCashAmount > 0) json['totalCashAmount'] = totalCashAmount;
  //   if (totalCardAmount > 0) json['totalCardAmount'] = totalCardAmount;

  //   return jsonEncode(json);
  // }

  String toFormattedString() {
    final StringBuffer buffer = StringBuffer();
    
    // Format date and time together
    buffer.writeln(DateFormat('dd-MM-yyyy HH:mm').format(hours));
    
    buffer.writeln(route.join(','));

    buffer.writeln(bus);
    // Add passenger information line by line
    if (totalPassengers > 0) {
      buffer.writeln('მგზავრები: $totalPassengers');
    }
    if (onlinePassengers > 0) {
      buffer.writeln('ონლაინი: $onlinePassengers');
    }
    if (cashPassengers > 0) {
      final cashText = cashChild > 0 ? 'ქეში: $cashPassengers ($cashChild ბავშვი)' : 'ქეში: $cashPassengers';
      buffer.writeln(cashText);
    }
    if (cardPassengers > 0) {
      final cardText = cardChild > 0 ? 'ბარათი: $cardPassengers ($cardChild ბავშვი)' : 'ბარათი: $cardPassengers';
      buffer.writeln(cardText);
    }
    if (wizzAirPassengers > 0) {
      buffer.writeln('Wizz-Air: $wizzAirPassengers');
    }
    if (freePassengers > 0) {
      buffer.writeln('$freePassengers უფასო');
    }
    if (onTheWayPassengers > 0) {
      final onTheWayText = onTheWayCash > 0 
          ? '+$onTheWayPassengers გზაში, ($onTheWayCash ქეში)'
          : '+$onTheWayPassengers გზაში, ონლაინი';
      buffer.writeln(onTheWayText);
    }
    // if (totalCashAmount > 0) {
    //   buffer.writeln('ჯამური ქეში: ${totalCashAmount.toStringAsFixed(2)} GEL');
    // }
    // if (totalCardAmount > 0) {
    //   buffer.writeln('ჯამური ბარათი: ${totalCardAmount.toStringAsFixed(2)} GEL');
    // }

    return buffer.toString().trimRight();
  }

  @override
  String toString() => toFormattedString();
}

