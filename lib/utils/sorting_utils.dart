int compareDriversByBusNumber(String busNumber1, String busNumber2) {
  // Extract numeric part from bus numbers (assuming format GB-XXX-US)
  final regex = RegExp(r'\d+');
  final match1 = regex.firstMatch(busNumber1);
  final match2 = regex.firstMatch(busNumber2);
  
  if (match1 == null || match2 == null) return 0;
  
  // Convert to integers and compare
  final num1 = int.parse(match1.group(0)!);
  final num2 = int.parse(match2.group(0)!);
  
  return num1.compareTo(num2);
}

