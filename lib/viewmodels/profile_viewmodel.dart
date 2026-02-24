import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  final String _name = 'Juan Pérez García';
  final String _email = 'juan.perez@email.com';
  final String _phone = '+51 999 999 999';
  final String _address = 'Calle Falsa 123, Lima';
  final String _dni = '83758952';
  final String _birthDate = '15 de Mayo, 1990';
  final int _age = 33;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get dni => _dni;
  String get birthDate => _birthDate;
  int get age => _age;

  String get initials {
    final parts = _name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _name.isNotEmpty ? _name[0].toUpperCase() : 'U';
  }

  Future<void> loadProfile() async {
    notifyListeners();
  }

  void logout() {
    notifyListeners();
  }
}
