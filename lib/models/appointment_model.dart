class Appointment {
  final int id;
  final int doctorId;
  final int specialtyId;
  final String specialtyName;
  final String doctorName;
  final String date;
  final String time;
  final String status;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.specialtyId,
    required this.specialtyName,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      specialtyId: json['specialty_id'] ?? 0,
      specialtyName: json['specialty_name'] ?? '',
      doctorName: json['doctor_name'] != null 
          ? '${json['doctor_name']} ${json['doctor_last_name'] ?? ''}'.trim()
          : '',
      date: json['date'] ?? json['fecha'] ?? '',
      time: json['time'] ?? json['hora'] ?? '',
      status: json['status'] ?? 'programada',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'specialty_id': specialtyId,
      'specialty_name': specialtyName,
      'doctor_name': doctorName,
      'date': date,
      'time': time,
      'status': status,
    };
  }
}
