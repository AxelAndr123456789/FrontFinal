import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'appointment_selection_view.dart';

class SpecialtiesScreen extends StatefulWidget {
  const SpecialtiesScreen({super.key});

  @override
  State<SpecialtiesScreen> createState() => _SpecialtiesScreenState();
}

class _SpecialtiesScreenState extends State<SpecialtiesScreen> {
  List<dynamic> _specialties = [];
  List<dynamic> _filteredSpecialties = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
  }

  Future<void> _loadSpecialties() async {
    try {
      final data = await ApiService.getSpecialties();
      if (mounted) {
        setState(() {
          _specialties = data.map((s) => {
            'id': s['id'],
            'name': s['name'] ?? '',
          }).toList();
          _filteredSpecialties = List.from(_specialties);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _specialties = [];
          _filteredSpecialties = [];
          _isLoading = false;
        });
      }
    }
  }

  void _filterSpecialties(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSpecialties = List.from(_specialties);
      } else {
        _filteredSpecialties = _specialties
            .where((specialty) => (specialty['name'] as String).toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterSpecialties('');
  }

  void _navigateToAppointmentScreen(String specialty, int specialtyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentSelectionScreen(
          specialty: specialty,
          specialtyId: specialtyId,
        ),
      ),
    );
  }

  Color _getSpecialtyColor(int index) {
    final colors = [
      const Color(0xFF7c4dff), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF4CAF50), // Green
      const Color(0xFFE91E63), // Pink
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF009688), // Teal
      const Color(0xFFF44336), // Red
    ];
    return colors[index % colors.length];
  }

  IconData _getSpecialtyIcon(String specialty) {
    final specialtyLower = specialty.toLowerCase();
    if (specialtyLower.contains('cardiología') || specialtyLower.contains('cardio')) {
      return Icons.favorite;
    } else if (specialtyLower.contains('dermatología') || specialtyLower.contains('piel')) {
      return Icons.face;
    } else if (specialtyLower.contains('pediatría') || specialtyLower.contains('niños')) {
      return Icons.child_care;
    } else if (specialtyLower.contains('oftalmología') || specialtyLower.contains('ojo')) {
      return Icons.visibility;
    } else if (specialtyLower.contains('ortopedia') || specialtyLower.contains('hueso')) {
      return Icons.accessibility_new;
    } else if (specialtyLower.contains('neurología') || specialtyLower.contains('cerebro')) {
      return Icons.psychology;
    } else if (specialtyLower.contains('ginecología') || specialtyLower.contains('mujer')) {
      return Icons.pregnant_woman;
    } else if (specialtyLower.contains('medicina general') || specialtyLower.contains('general')) {
      return Icons.local_hospital;
    } else if (specialtyLower.contains('odontología') || specialtyLower.contains('diente')) {
      return Icons.mood;
    } else if (specialtyLower.contains('psicología') || specialtyLower.contains('psico')) {
      return Icons.emoji_emotions;
    }
    return Icons.medical_services;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Especialidades'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFe7f1f3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Icon(
                            Icons.search,
                            color: Color(0xFF4c8d9a),
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: "Buscar especialidad",
                                hintStyle: TextStyle(color: Color(0xFF4c8d9a)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF0d191b),
                                fontSize: 16,
                              ),
                              onChanged: _filterSpecialties,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: _clearSearch,
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF4c8d9a),
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredSpecialties.isEmpty
                      ? const Center(child: Text('No se encontraron especialidades'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: _filteredSpecialties.length,
                          itemBuilder: (context, index) {
                            final specialty = _filteredSpecialties[index];
                            return GestureDetector(
                              onTap: () => _navigateToAppointmentScreen(
                                specialty['name'] as String,
                                specialty['id'] as int,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: _getSpecialtyColor(index),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _getSpecialtyIcon(specialty['name'] as String),
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      specialty['name'] as String,
                                      style: const TextStyle(
                                        color: Color(0xFF0d191b),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
