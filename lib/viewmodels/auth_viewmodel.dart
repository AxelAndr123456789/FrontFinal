import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showPassword = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get showPassword => _showPassword;

  void togglePasswordVisibility() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Por favor, completa todos los campos';
      notifyListeners();
      return false;
    }

    if (!email.contains('@') && !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(email)) {
      _errorMessage = 'Ingresa un correo o nombre de usuario válido';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await ApiService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String name,
    required String password,
    required String phone,
    required String birthDate,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await ApiService.register(
        email: email,
        name: name,
        lastName: name.split(' ').length > 1 ? name.split(' ').last : '',
        password: password,
        phone: phone,
        birthDate: birthDate,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Por favor, ingresa tu correo electrónico';
      notifyListeners();
      return false;
    }

    if (!email.contains('@')) {
      _errorMessage = 'Por favor, ingresa un correo válido';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await ApiService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.isEmpty) {
      _errorMessage = 'Por favor, ingresa una contraseña';
      notifyListeners();
      return false;
    }

    if (newPassword.length < 6) {
      _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'Las contraseñas no coinciden';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await ApiService.resetPassword(email: email, newPassword: newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
