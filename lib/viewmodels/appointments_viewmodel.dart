import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/appointment_model.dart';

class AppointmentsViewModel extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadAppointments() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await ApiService.getMyAppointments(status: 'programada');
      _appointments = data.map((apt) => Appointment.fromJson(apt)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _appointments = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment({
    required int doctorId,
    required int specialtyId,
    required String date,
    required String time,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await ApiService.createAppointment(
        doctorId: doctorId,
        specialtyId: specialtyId,
        date: date,
        time: time,
      );
      await loadAppointments();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAppointment(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await ApiService.cancelAppointment(id);
      _appointments.removeWhere((apt) => apt.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool hasExistingAppointment(String specialtyName) {
    return _appointments.any(
      (apt) => apt.specialtyName.toLowerCase() == specialtyName.toLowerCase(),
    );
  }
}
