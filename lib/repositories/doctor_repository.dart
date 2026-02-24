import '../services/api_service.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  Future<List<Doctor>> getBySpecialty(int specialtyId) async {
    final data = await ApiService.getDoctorsBySpecialty(specialtyId);
    return data.map((d) => Doctor.fromJson(d)).toList();
  }
}
