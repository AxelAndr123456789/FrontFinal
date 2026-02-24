import '../services/api_service.dart';

class AuthRepository {
  Future<bool> login(String email, String password) async {
    await ApiService.login(email, password);
    return true;
  }

  Future<bool> register({
    required String email,
    required String name,
    required String lastName,
    required String password,
    required String phone,
    required String birthDate,
  }) async {
    await ApiService.register(
      email: email,
      name: name,
      lastName: lastName,
      password: password,
      phone: phone,
      birthDate: birthDate,
    );
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    await ApiService.forgotPassword(email);
    return true;
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await ApiService.resetPassword(email: email, newPassword: newPassword);
    return true;
  }
}
