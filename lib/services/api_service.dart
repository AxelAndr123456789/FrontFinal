import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.43.218:8000';
  
  static String? _token;
  static int? _userId;
  static Map<String, dynamic>? _userData;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static bool get isLoggedIn => _token != null;
  static int? get userId => _userId;
  static Map<String, dynamic>? get userData => _userData;

  static void setToken(String token) {
    _token = token;
  }

  static void setUserData(Map<String, dynamic> data) {
    _userData = data;
    _userId = data['id'];
  }

  static void clearSession() {
    _token = null;
    _userId = null;
    _userData = null;
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'] ?? data['token'];
      
      // Handle different response formats
      if (data['user'] != null) {
        setUserData(data['user']);
      } else if (data['id'] != null) {
        // If user data is directly in response
        setUserData(data);
      }
      return data;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Error al iniciar sesión');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String name,
    required String lastName,
    required String password,
    required String phone,
    required String birthDate,
    String? gender,
    String? dni,
    String? address,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': name,
        'last_name': lastName,
        'password': password,
        'phone': phone,
        'date_of_birth': birthDate,
        if (gender != null) 'gender': gender,
        if (dni != null) 'dni': dni,
        if (address != null) 'address': address,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Error al registrar usuario');
    }
  }

  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/forgot-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al recuperar contraseña');
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/reset-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al restablecer contraseña');
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _userData = data;
      return data;
    }
    throw Exception('Error al obtener datos del usuario');
  }

  // Specialties
  static Future<List<dynamic>> getSpecialties() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/specialties'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cargar especialidades');
  }

  // Doctors
  static Future<List<dynamic>> getDoctorsBySpecialty(int specialtyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/doctors/by-specialty/$specialtyId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cargar doctores');
  }

  // Appointments
  static Future<List<dynamic>> getMyAppointments({String status = 'programada'}) async {
    var url = '$baseUrl/api/appointments/me?status=$status';
    
    final headers = Map<String, String>.from(_headers);
    if (_userId != null) {
      headers['x-user-id'] = _userId.toString();
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cargar citas: ${response.statusCode}');
  }

  // Get all booked time slots (for showing availability to all users)
  static Future<List<dynamic>> getBookedTimeSlots() async {
    try {
      final url = '$baseUrl/api/appointments/booked-slots';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Silently fail
    }
    return [];
  }

  static Future<Map<String, dynamic>> createAppointment({
    required int doctorId,
    required int specialtyId,
    required String date,
    required String time,
  }) async {
    final headers = Map<String, String>.from(_headers);
    if (_userId != null) {
      headers['x-user-id'] = _userId.toString();
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/appointments'),
      headers: headers,
      body: jsonEncode({
        'doctor_id': doctorId,
        'specialty_id': specialtyId,
        'date': date,
        'time': time,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Error al crear cita');
    }
  }

  static Future<void> cancelAppointment(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/appointments/$id/cancel'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Error al cancelar cita');
    }
  }

  // Campaigns
  static Future<List<dynamic>> getFeaturedCampaigns() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/campaigns/featured'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cargar campañas');
  }

  // Hospital Info
  static Future<Map<String, dynamic>> getHospitalInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/hospital/info'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al cargar información del hospital');
  }
}
