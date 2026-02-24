import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_view.dart';

class AppointmentSelectionScreen extends StatefulWidget {
  final String specialty;
  final int specialtyId;
  
  const AppointmentSelectionScreen({
    super.key, 
    required this.specialty,
    required this.specialtyId,
  });

  @override
  State<AppointmentSelectionScreen> createState() =>
      _AppointmentSelectionScreenState();
}

class _AppointmentSelectionScreenState
    extends State<AppointmentSelectionScreen> {
  int selectedDayIndex = 0;
  String selectedTime = '';
  bool isDaySelected = true;
  List<dynamic> _doctors = [];
  List<dynamic> _existingAppointments = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> days = [];
  List<Map<String, dynamic>> timeSlots = [];

  final List<String> weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final List<String> monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

  @override
  void initState() {
    super.initState();
    timeSlots = generateTimeSlots();
    _loadDoctors();
    _loadAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() => _loadAppointments());
  }

  @override
  void didUpdateWidget(covariant AppointmentSelectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await ApiService.getMyAppointments();
      if (mounted) {
        setState(() {
          _existingAppointments = appointments;
        });
      }
    } catch (e) {
      // Silently fail
    }
    
    try {
      final bookedSlots = await ApiService.getBookedTimeSlots();
      if (mounted && bookedSlots.isNotEmpty) {
        setState(() {
          _existingAppointments = [..._existingAppointments, ...bookedSlots];
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await ApiService.getDoctorsBySpecialty(widget.specialtyId);
      if (mounted) {
        setState(() {
          _doctors = doctors;
          days = _generateDaysOfFebruary2026();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          days = _generateDaysOfFebruary2026();
        });
      }
    }

    try {
      final appointments = await ApiService.getMyAppointments();
      if (mounted) {
        setState(() {
          _existingAppointments = appointments;
        });
      }
    } catch (e) {
      // Silently fail for appointments
    }
    
    try {
      final bookedSlots = await ApiService.getBookedTimeSlots();
      if (mounted && bookedSlots.isNotEmpty) {
        setState(() {
          _existingAppointments = [..._existingAppointments, ...bookedSlots];
        });
      }
    } catch (e) {
      // Silently fail
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDoctorsForSpecialty() {
    if (_doctors.isEmpty) return [];
    return _doctors.map((d) => {
      'name': '${d['name'] ?? ''} ${d['last_name'] ?? ''}'.trim(),
      'image': d['photo'] ?? '',
      'id': d['id'],
    }).toList();
  }

  List<Map<String, dynamic>> _generateDaysOfFebruary2026() {
    List<Map<String, dynamic>> daysList = [];
    final doctors = _getDoctorsForSpecialty();
    
    if (doctors.isEmpty) {
      return daysList;
    }
    
    DateTime firstDay = DateTime(2026, 2, 1);
    
    for (int i = 0; i < 28; i++) {
      DateTime currentDay = firstDay.add(Duration(days: i));
      int weekdayIndex = currentDay.weekday - 1;
      String weekday = weekdays[weekdayIndex];
      
      bool isWeekend = weekdayIndex >= 5;
      
      final doctorIndex = i % doctors.length;
      String doctorName = doctors[doctorIndex]['name'] as String? ?? 'Doctor';
      String? imageUrl = doctors[doctorIndex]['image'] as String?;
      int? doctorId = doctors[doctorIndex]['id'] as int?;
      
      daysList.add({
        'day': currentDay.day.toString(),
        'weekday': weekday,
        'month': 'Febrero',
        'doctorName': isWeekend ? 'Libre' : doctorName,
        'doctorId': isWeekend ? null : doctorId,
        'imageUrl': isWeekend ? null : imageUrl,
        'isFree': isWeekend,
        'available': !isWeekend,
        'fullDate': '${currentDay.day} de Febrero',
      });
    }
    
    return daysList;
  }

  List<Map<String, dynamic>> generateTimeSlots() {
    List<Map<String, dynamic>> slots = [];

    for (int hour = 7; hour <= 12; hour++) {
      int maxMinute = (hour == 12) ? 0 : 60;
      
      for (int minute = 0; minute < maxMinute; minute += 15) {
        final time =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

        slots.add({
          'time': time,
          'duration': '15 min',
          'available': true,
          'selected': time == selectedTime,
          'isMorning': true,
        });
      }
    }

    for (int hour = 14; hour <= 17; hour++) {
      int startMinute = (hour == 14) ? 30 : 0;
      int maxMinute = (hour == 17) ? 0 : 60;
      
      for (int minute = startMinute; minute < maxMinute; minute += 15) {
        if (hour == 17 && minute > 0) break;
        
        final time =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

        slots.add({
          'time': time,
          'duration': '15 min',
          'available': true,
          'selected': time == selectedTime,
          'isMorning': false,
        });
      }
    }

    return slots;
  }

  bool _isTimeSlotBooked(String time) {
    if (_existingAppointments.isEmpty) return false;
    
    final selectedDay = days[selectedDayIndex];
    final dayNumber = selectedDay['day'] as String;
    final dayMonth = selectedDay['month'] as String;
    
    final monthMap = {
      'Enero': '01', 'Febrero': '02', 'Marzo': '03', 'Abril': '04',
      'Mayo': '05', 'Junio': '06', 'Julio': '07', 'Agosto': '08',
      'Septiembre': '09', 'Octubre': '10', 'Noviembre': '11', 'Diciembre': '12'
    };
    final monthNum = monthMap[dayMonth] ?? '02';
    final apiDateFormat = '2026-$monthNum-${dayNumber.padLeft(2, '0')}';
    final currentSpecialtyLower = widget.specialty.toLowerCase();
    
    for (var appointment in _existingAppointments) {
      var appointmentDate = appointment['fecha']?.toString() ?? 
                           appointment['date']?.toString() ?? '';
      var appointmentTime = appointment['hora']?.toString() ?? 
                           appointment['time']?.toString() ?? '';
      
      final appointmentSpecialty = appointment['especialidad']?.toString().toLowerCase() ??
                                   appointment['specialty_name']?.toString().toLowerCase() ?? 
                                   appointment['specialty']?.toString().toLowerCase() ?? '';
      
      // Skip if no specialty
      if (appointmentSpecialty.isEmpty) continue;
      
      if (appointmentDate.contains(' ')) {
        appointmentDate = appointmentDate.split(' ')[0];
      }
      
      if (appointmentTime.contains(':')) {
        final timeParts = appointmentTime.split(':');
        appointmentTime = '${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}';
      }
      
      final isSameSpecialty = appointmentSpecialty == currentSpecialtyLower || 
                              appointmentSpecialty.contains(currentSpecialtyLower) ||
                              currentSpecialtyLower.contains(appointmentSpecialty);
      
      if (appointmentDate == apiDateFormat && appointmentTime == time && isSameSpecialty) {
        return true;
      }
    }
    return false;
  }

  void selectDay(int index) {
    setState(() {
      selectedDayIndex = index;
      final dayAvailable = days[index]['available'] as bool? ?? false;
      isDaySelected = dayAvailable;

      selectedTime = '';
      timeSlots = generateTimeSlots();
    });
  }

  void selectTime(String time) {
    final dayAvailable = days[selectedDayIndex]['available'] as bool? ?? false;
    if (!dayAvailable) {
      return;
    }

    if (_isTimeSlotBooked(time)) {
      return;
    }

    setState(() {
      selectedTime = time;

      for (var slot in timeSlots) {
        slot['selected'] = slot['time'] == time;
      }
    });
  }

  void bookAppointment() {
    if (!isDaySelected) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Día no disponible'),
          content: const Text(
              'El día seleccionado no tiene disponibilidad. Por favor selecciona otro día.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (selectedTime.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Horario no seleccionado'),
          content: const Text(
              'Por favor, selecciona un horario disponible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final selectedDay = days[selectedDayIndex];
    final doctorId = selectedDay['doctorId'] as int?;
    final dateStr = selectedDay['fullDate'] as String;

    _createAppointmentAndNavigate(doctorId, dateStr, selectedTime, selectedDay['doctorName'] as String);
  }

  String _formatDateForApi(String dateStr) {
    try {
      final parts = dateStr.split(' de ');
      if (parts.isNotEmpty) {
        final day = int.tryParse(parts[0].trim()) ?? 1;
        
        final monthMap = {
          'Enero': 1, 'Febrero': 2, 'Marzo': 3, 'Abril': 4,
          'Mayo': 5, 'Junio': 6, 'Julio': 7, 'Agosto': 8,
          'Septiembre': 9, 'Octubre': 10, 'Noviembre': 11, 'Diciembre': 12
        };
        
        final monthStr = parts.length > 1 ? parts[1].trim() : 'Febrero';
        final month = monthMap[monthStr] ?? 2;
        
        return '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Return default date on error
    }
    return '2026-02-01';
  }

  Future<void> _createAppointmentAndNavigate(int? doctorId, String date, String time, String doctorName) async {
    if (doctorId == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('No se pudo obtener el ID del médico.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiDate = _formatDateForApi(date);
      
      await ApiService.createAppointment(
        doctorId: doctorId,
        specialtyId: widget.specialtyId,
        date: apiDate,
        time: time,
      );

      final appointments = await ApiService.getMyAppointments();

      if (mounted) {
        setState(() {
          _existingAppointments = appointments;
        });
        Navigator.pop(context);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CitaConfirmadaScreen(
              specialty: widget.specialty,
              doctorName: doctorName,
              date: date,
              time: time,
              duration: '15 minutos',
              doctorId: doctorId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo agendar la cita: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || days.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final selectedDay = days[selectedDayIndex];
    
    final bookedTimes = <String>{};
    final dayNumber = selectedDay['day'] as String;
    final dayMonth = selectedDay['month'] as String;
    
    final monthMap = {
      'Enero': '01', 'Febrero': '02', 'Marzo': '03', 'Abril': '04',
      'Mayo': '05', 'Junio': '06', 'Julio': '07', 'Agosto': '08',
      'Septiembre': '09', 'Octubre': '10', 'Noviembre': '11', 'Diciembre': '12'
    };
    final monthNum = monthMap[dayMonth] ?? '02';
    final apiDateFormat = '2026-$monthNum-${dayNumber.padLeft(2, '0')}';
    
    final currentSpecialtyLower = widget.specialty.toLowerCase();
    
    for (var appointment in _existingAppointments) {
      var appointmentDate = appointment['fecha']?.toString() ?? 
                           appointment['date']?.toString() ?? '';
      var appointmentTime = appointment['hora']?.toString() ?? 
                           appointment['time']?.toString() ?? '';
      
      // Verificar que la cita sea de la misma especialidad
      final appointmentSpecialty = appointment['especialidad']?.toString().toLowerCase() ??
                                   appointment['specialty_name']?.toString().toLowerCase() ?? 
                                   appointment['specialty']?.toString().toLowerCase() ?? '';
      
      // Skip if no specialty (booked slots without specialty info)
      if (appointmentSpecialty.isEmpty) continue;
      
      // Extraer solo la fecha (sin hora)
      if (appointmentDate.contains(' ')) {
        appointmentDate = appointmentDate.split(' ')[0];
      }
      
      // Extraer solo la hora (sin minutos/segundos extra)
      if (appointmentTime.contains(':')) {
        final timeParts = appointmentTime.split(':');
        appointmentTime = '${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}';
      }
      
      // Solo bloquear si es la misma especialidad
      final isSameSpecialty = appointmentSpecialty == currentSpecialtyLower || 
                              appointmentSpecialty.contains(currentSpecialtyLower) ||
                              currentSpecialtyLower.contains(appointmentSpecialty);
      
      if (appointmentDate == apiDateFormat && isSameSpecialty) {
        bookedTimes.add(appointmentTime);
      }
    }
    
    final availableSlots = timeSlots.where((slot) => 
      (slot['available'] as bool) && !bookedTimes.contains(slot['time'])
    ).length;
    final totalSlots = timeSlots.length;
    final dayAvailable = selectedDay['available'] as bool? ?? false;

    final morningSlots =
        timeSlots.where((slot) => slot['isMorning'] as bool).toList();
    final afternoonSlots =
        timeSlots.where((slot) => !(slot['isMorning'] as bool)).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.specialty} - Turnos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Médico por día',
                              style: TextStyle(
                                color: Color(0xFF0d1b1a),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
Text(
                              'Febrero 2026',
                              style: TextStyle(
                                color: const Color(0xFF7c4dff),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            children: List.generate(days.length, (index) {
                              final day = days[index];
                              return GestureDetector(
                                onTap: () => selectDay(index),
                                child: _buildDayCard(
                                  day: day['day'] as String,
                                  weekday: day['weekday'] as String,
                                  doctorName: day['doctorName'] as String,
                                  imageUrl: day['imageUrl'] as String?,
                                  isSelected: index == selectedDayIndex,
                                  isFree: day['isFree'] as bool? ?? false,
                                  available: day['available'] as bool? ?? false,
                                ),
                              );
                            }),
                          ),
                        ),
                        if (!dayAvailable)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.orange[700], size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Este día no tiene disponibilidad',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7c4dff),
                            Color(0xFF9c27b0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  image: (selectedDay['imageUrl'] != null && (selectedDay['imageUrl'] as String).isNotEmpty)
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            selectedDay['imageUrl'] as String,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: (selectedDay['imageUrl'] == null || (selectedDay['imageUrl'] as String).isEmpty)
                                      ? const Color(0xFF9ca3af)
                                      : null,
                                ),
                                child: (selectedDay['imageUrl'] == null || (selectedDay['imageUrl'] as String).isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        color: Colors.white.withValues(alpha: 0.7),
                                        size: 30,
                                      )
                                    : null,
                              ),
                              if (!(selectedDay['isFree'] as bool? ?? true))
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF13ecda),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      size: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MÉDICO DE TURNO',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedDay['doctorName'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dayAvailable
                                      ? 'Especialista en ${widget.specialty}'
                                      : 'Sin disponibilidad',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bloques Disponibles',
                              style: TextStyle(
                                color: Color(0xFF0d1b1a),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF13ecda).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.event_available,
                                    size: 14,
                                    color: Color(0xFF0f8e83),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dayAvailable
                                        ? '$availableSlots de $totalSlots libres'
                                        : '0 de 0 libres',
                                    style: TextStyle(
                                      color: const Color(0xFF0f8e83),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Text(
                            dayAvailable
                                ? 'Horarios disponibles:'
                                : 'No hay horarios disponibles para este día',
                            style: TextStyle(
                              color: dayAvailable
                                  ? const Color(0xFF666666)
                                  : Colors.orange[700],
                              fontSize: 12,
                            ),
                          ),
                        ),

                        if (dayAvailable)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, top: 4),
                                child: Text(
                                  'Mañana (7:00 AM - 12:00 PM)',
                                  style: TextStyle(
                                    color: const Color(0xFF7c4dff),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.3,
                                ),
itemCount: morningSlots.length,
                                itemBuilder: (context, index) {
                                  final slot = morningSlots[index];
                                  final slotAvailable = slot['available'] as bool;
                                  final isBooked = bookedTimes.contains(slot['time']);

                                  return GestureDetector(
                                    onTap: slotAvailable && dayAvailable && !isBooked
                                        ? () => selectTime(slot['time'] as String)
                                        : null,
                                    child: _buildTimeSlot(
                                      slot['time'] as String,
                                      slot['duration'] as String,
                                      isAvailable: slotAvailable && !isBooked,
                                      isSelected: slot['selected'] as bool? ?? false,
                                      dayAvailable: dayAvailable,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                        if (dayAvailable)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, top: 12),
                                child: Text(
                                  'Tarde (2:30 PM - 5:00 PM)',
                                  style: TextStyle(
                                    color: const Color(0xFF7c4dff),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.3,
                                ),
itemCount: afternoonSlots.length,
                                itemBuilder: (context, index) {
                                  final slot = afternoonSlots[index];
                                  final slotAvailable = slot['available'] as bool;
                                  final isBooked = bookedTimes.contains(slot['time']);

                                  return GestureDetector(
                                    onTap: slotAvailable && dayAvailable && !isBooked
                                        ? () => selectTime(slot['time'] as String)
                                        : null,
                                    child: _buildTimeSlot(
                                      slot['time'] as String,
                                      slot['duration'] as String,
                                      isAvailable: slotAvailable && !isBooked,
                                      isSelected: slot['selected'] as bool? ?? false,
                                      dayAvailable: dayAvailable,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFe5e7eb),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CITA PROGRAMADA',
                          style: TextStyle(
                            color: const Color(0xFF9ca3af),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dayAvailable && selectedTime.isNotEmpty
                              ? '${selectedDay['day']} de Agosto, $selectedTime'
                              : 'Sin cita seleccionada',
                          style: TextStyle(
                            color: dayAvailable && selectedTime.isNotEmpty
                                ? const Color(0xFF0d1b1a)
                                : const Color(0xFF9ca3af),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf3e5f5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF7c4dff).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Color(0xFF7c4dff),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isDaySelected && selectedTime.isNotEmpty
                        ? bookAppointment
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDaySelected && selectedTime.isNotEmpty
                          ? const Color(0xFF7c4dff)
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isDaySelected && selectedTime.isNotEmpty
                              ? 'Confirmar'
                              : 'Selecciona día y hora',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isDaySelected && selectedTime.isNotEmpty)
                          const SizedBox(width: 6),
                        if (isDaySelected && selectedTime.isNotEmpty)
                          const Icon(Icons.check_circle, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard({
    required String day,
    required String weekday,
    required String doctorName,
    String? imageUrl,
    bool isSelected = false,
    bool isFree = false,
    required bool available,
  }) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? (available ? const Color(0xFF7c4dff) : Colors.grey[400])
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFFe5e7eb),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? Colors.black.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekday,
            style: TextStyle(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.8)
                  : const Color(0xFF9ca3af),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0d1b1a),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Column(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.5)
                          : const Color(0xFFe5e7eb),
                      width: isSelected ? 2 : 1,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe5e7eb),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 18,
                    color: Color(0xFF9ca3af),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                doctorName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6b7280),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(
    String time,
    String duration, {
    bool isAvailable = true,
    bool isSelected = false,
    bool dayAvailable = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: dayAvailable
            ? (isAvailable
                ? (isSelected
                    ? const Color(0xFF7c4dff).withValues(alpha: 0.1)
                    : Colors.white)
                : const Color(0xFFf3f4f6).withValues(alpha: 0.5))
            : const Color(0xFFf3f4f6).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF7c4dff)
              : (isAvailable && dayAvailable
                  ? const Color(0xFFe5e7eb)
                  : Colors.transparent),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: dayAvailable
                      ? (isAvailable
                          ? (isSelected
                              ? const Color(0xFF7c4dff)
                              : const Color(0xFF0d1b1a))
                          : const Color(0xFF9ca3af))
                      : const Color(0xFF9ca3af),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              Text(
                '15 min',
                style: TextStyle(
                  color: dayAvailable
                      ? (isAvailable
                          ? (isSelected
                              ? const Color(0xFF7c4dff)
                              : const Color(0xFF9ca3af))
                          : const Color(0xFF9ca3af))
                      : const Color(0xFF9ca3af),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              if (isSelected && dayAvailable) 
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7c4dff),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SELECCIONADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CitaConfirmadaScreen extends StatelessWidget {
  final String specialty;
  final String doctorName;
  final String date;
  final String time;
  final String duration;
  final int? doctorId;

  const CitaConfirmadaScreen({
    super.key,
    required this.specialty,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.duration,
    this.doctorId,
  });

  String _formatDate(String date) {
    try {
      final parts = date.split(' de ');
      if (parts.isNotEmpty) {
        final day = parts[0].trim();
        
        final now = DateTime.now();
        final monthStr = parts.length > 1 ? parts[1].trim() : now.month.toString();
        
        final monthMap = {
          'Enero': 1, 'Febrero': 2, 'Marzo': 3, 'Abril': 4,
          'Mayo': 5, 'Junio': 6, 'Julio': 7, 'Agosto': 8,
          'Septiembre': 9, 'Octubre': 10, 'Noviembre': 11, 'Diciembre': 12
        };
        
        final month = monthMap[monthStr] ?? now.month;
        final year = now.year;
        
        final parsedDate = DateTime(year, month, int.parse(day));
        
        final weekday = _getWeekdayAbbreviation(parsedDate.weekday);
        final monthAbbrev = _getMonthAbbreviation(month);
        
        return '$weekday, $day $monthAbbrev';
      }
    } catch (e) {
      // Return original date on parse error
    }
    return date;
  }

  String _getWeekdayAbbreviation(int weekday) {
    const weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    return weekdays[weekday % 7];
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        
        final period = hour >= 12 ? 'PM' : 'AM';
        
        final hour12 = hour % 12;
        final displayHour = hour12 == 0 ? 12 : hour12;
        
        return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
      }
    } catch (e) {
      // Return original date on parse error
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(date);
    final formattedTime = _formatTime(time);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalles de la Cita'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFF2F0F4),
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
            const SizedBox(height: 40),

            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF7c4dff),
              child: const Icon(Icons.check, color: Colors.white, size: 50),
            ),

            const SizedBox(height: 20),

            const Text(
              '¡Cita Confirmada!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Tu salud es nuestra prioridad. Hemos agendado tu espacio exitosamente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7c4dff), fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialty.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF7C3AED),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7c4dff).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF7c4dff),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Fecha',
                                      style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF7C3AED),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hora',
                                      style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formattedTime,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21DEDB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.timer,
                        color: Color(0xFF21DEDB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Duración estimada',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sesión de $duration',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21DEDB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Color(0xFF00A8A6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7c4dff),
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Confirmar Cita',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ),
              ),

              const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }
}
