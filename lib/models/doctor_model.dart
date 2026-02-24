class Doctor {
  final int id;
  final String name;
  final String lastName;
  final String? specialty;
  final String? license;
  final String? photo;

  Doctor({
    required this.id,
    required this.name,
    required this.lastName,
    this.specialty,
    this.license,
    this.photo,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      specialty: json['specialty']?['name'],
      license: json['license'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last_name': lastName,
      'specialty': specialty,
      'license': license,
      'photo': photo,
    };
  }
}
