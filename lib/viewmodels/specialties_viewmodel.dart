import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/specialty_model.dart';

class SpecialtiesViewModel extends ChangeNotifier {
  List<Specialty> _specialties = [];
  List<Specialty> _filteredSpecialties = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';

  List<Specialty> get specialties => _specialties;
  List<Specialty> get filteredSpecialties => _filteredSpecialties;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> loadSpecialties() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await ApiService.getSpecialties();
      _specialties = data.map((s) => Specialty.fromJson(s)).toList();
      _filteredSpecialties = List.from(_specialties);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterSpecialties(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSpecialties = List.from(_specialties);
    } else {
      _filteredSpecialties = _specialties
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredSpecialties = List.from(_specialties);
    notifyListeners();
  }
}
