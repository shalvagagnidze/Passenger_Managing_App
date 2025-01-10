class Bus {
  final int id;
  final String number;

  Bus({
    required this.id,
    required this.number,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
    };
  }
}