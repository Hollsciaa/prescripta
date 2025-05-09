class Client {
  final String? id;
  final String firstName;
  final String name;
  final String email;
  final String phone;
  final String needs;
  final double? budget;
  final String notes;

  Client({
    this.id,
    required this.firstName,
    required this.name,
    required this.email,
    required this.phone,
    required this.needs,
    required this.budget,
    required this.notes,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id'],
      firstName: json['firstName'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      needs: json['needs'] ?? '',
      budget:
          (json['budget'] is double)
              ? json['budget']
              : double.tryParse(json['budget'].toString()),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'name': name,
      'email': email,
      'phone': phone,
      'needs': needs,
      'budget': budget,
      'notes': notes,
    };
  }
}
