import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_view.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final data = await ApiService.getMyAppointments(status: 'programada');
      if (mounted) {
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appointments = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelAppointment(int id) async {
    try {
      await ApiService.cancelAppointment(id);
      if (mounted) {
        setState(() {
          _appointments.removeWhere((apt) => apt['id'] == id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita cancelada exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cancelar: ${e.toString()}')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          ),
        ),
        title: const Text('Mis Citas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lista de Citas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF21DEDB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_appointments.length} Activas',
                          style: const TextStyle(
                            color: Color(0xFF00A8A6),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 3,
                      width: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7c4dff),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_appointments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No tienes citas programadas',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: _appointments.map((appointment) {
                        final specialty = appointment['specialty_name'] ?? appointment['specialty']?['name'] ?? 'Especialidad';
                        final doctorName = '${appointment['doctor_name'] ?? ''} ${appointment['doctor_last_name'] ?? ''}'.trim();
                        final date = appointment['date'] ?? '';
                        final time = appointment['time'] ?? '';
                        final id = appointment['id'];

                        return Column(
                          children: [
                            _buildAppointmentCard(
                              specialty: specialty,
                              doctorName: doctorName,
                              date: date,
                              time: time,
                              icon: _getIconForSpecialty(specialty),
                              iconColor: _getColorForSpecialty(specialty),
                              onCancel: () => _cancelAppointment(id),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppointmentCard({
    required String specialty,
    required String doctorName,
    required String date,
    required String time,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onCancel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctorName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancelar Cita'),
                    content: const Text('¿Estás seguro de que deseas cancelar esta cita?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel();
                        },
                        child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Cancelar Cita',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
