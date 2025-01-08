class Flight {
  final int id;
  final String name;

  Flight({
    required this.id,
    required this.name
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'],
      name: json['name'],
    );
  }
}