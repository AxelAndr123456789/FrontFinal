class User {
  final int id;
  final String email;
  final String name;
  final String? lastName;
  final String? phone;
  final String? dni;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.lastName,
    this.phone,
    this.dni,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      lastName: json['last_name'],
      phone: json['phone'],
      dni: json['dni'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'last_name': lastName,
      'phone': phone,
      'dni': dni,
    };
  }
}
