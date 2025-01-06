class Driver {
  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final int busId;

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.busId,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      busId: json['busId'],
    );
  }

  String get fullName => '$firstName $lastName';
}