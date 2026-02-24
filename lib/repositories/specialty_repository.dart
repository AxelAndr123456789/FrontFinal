import '../services/api_service.dart';
import '../models/specialty_model.dart';

class SpecialtyRepository {
  Future<List<Specialty>> getAll() async {
    final data = await ApiService.getSpecialties();
    return data.map((s) => Specialty.fromJson(s)).toList();
  }

  Future<Specialty?> getById(int id) async {
    final specialties = await getAll();
    try {
      return specialties.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
