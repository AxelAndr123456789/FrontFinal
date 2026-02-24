import '../services/api_service.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  Future<List<Appointment>> getMyAppointments({String status = 'programada'}) async {
    final data = await ApiService.getMyAppointments(status: status);
    return data.map((a) => Appointment.fromJson(a)).toList();
  }

  Future<bool> createAppointment({
    required int doctorId,
    required int specialtyId,
    required String date,
    required String time,
  }) async {
    await ApiService.createAppointment(
      doctorId: doctorId,
      specialtyId: specialtyId,
      date: date,
      time: time,
    );
    return true;
  }

  Future<bool> cancelAppointment(int id) async {
    await ApiService.cancelAppointment(id);
    return true;
  }
}
