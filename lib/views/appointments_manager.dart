import 'package:flutter/material.dart';

class AppointmentsManager {
  static final AppointmentsManager _instance = AppointmentsManager._internal();
  factory AppointmentsManager() => _instance;
  AppointmentsManager._internal();

  final List<Map<String, dynamic>> _appointments = [];

  List<Map<String, dynamic>> get appointments => List.from(_appointments);

  void addAppointment({
    required String specialty,
    required String doctorName,
    required String date,
    required String time,
  }) {
    _appointments.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'specialty': specialty,
      'doctorName': doctorName,
      'date': date,
      'time': time,
      'icon': _getIconForSpecialty(specialty),
      'iconColor': _getColorForSpecialty(specialty),
    });
  }

  void removeAppointment(int id) {
    _appointments.removeWhere((appointment) => appointment['id'] == id);
  }

  IconData _getIconForSpecialty(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'cardiología':
        return Icons.favorite;
      case 'psicología':
        return Icons.psychology;
      case 'odontología':
        return Icons.medical_services;
      case 'dermatología':
        return Icons.spa;
      case 'gastroenterología':
        return Icons.medical_information;
      case 'neurología':
        return Icons.memory;
      case 'oftalmología':
        return Icons.remove_red_eye;
      case 'pediatría':
        return Icons.child_care;
      default:
        return Icons.medical_services;
    }
  }

  Color _getColorForSpecialty(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'cardiología':
        return const Color(0xFF21DEDB);
      case 'psicología':
        return const Color(0xFF9B8ACB);
      case 'odontología':
        return const Color(0xFF21DEDB);
      case 'dermatología':
        return const Color(0xFFFFB74D);
      case 'gastroenterología':
        return const Color(0xFF4CAF50);
      case 'neurología':
        return const Color(0xFF2196F3);
      case 'oftalmología':
        return const Color(0xFF9C27B0);
      case 'pediatría':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF7c4dff);
    }
  }
}
