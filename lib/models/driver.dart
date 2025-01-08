class Driver {
  final int? id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String busNumber;

  Driver({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.busNumber,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      busNumber: json['bus']['number'],
    );
  }

  String get fullName => '$firstName $lastName';
}