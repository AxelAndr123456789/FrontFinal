import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;
  bool _obscurePassword = true;
  bool _hasNineEntered = false;
  bool _isLoginButtonHovered = false;
  bool _isLoading = false;
  String _errorMessage = '';

  final Color _secondaryColor = const Color(0xFF7c4dff);
  final Color _backgroundColor = const Color(0xFFF6F8F8);
  final Color _cardColor = Colors.white;
  final Color _iconColor = Colors.black;

  final FocusNode _dateFocusNode = FocusNode();
  String _dateText = '';

  final onlyNumbersFormatter = FilteringTextInputFormatter.digitsOnly;

  String _formatDateForApi(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    } catch (e) {
      // Return original if parsing fails
    }
    return dateStr;
  }

  Future<void> _performRegistration() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final birthDate = _formatDateForApi(_birthDateController.text.trim());
      
      await ApiService.register(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        birthDate: birthDate,
        gender: _selectedGender,
      );

      // Auto login after registration
      await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      _showErrorDialog(_errorMessage);
    }
  }

  @override
  void initState() {
    super.initState();
    _ageController.text = '--';
    
    _birthDateController.addListener(_formatDate);
    _birthDateController.addListener(_calculateAge);
    _phoneController.addListener(_validatePhoneFirstDigit);
  }

  @override
  void dispose() {
    _birthDateController.removeListener(_formatDate);
    _birthDateController.removeListener(_calculateAge);
    _phoneController.removeListener(_validatePhoneFirstDigit);
    _nameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateFocusNode.dispose();
    super.dispose();
  }

  void _formatDate() {
    final text = _birthDateController.text;
    
    String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }
    
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      
      final char = digits[i];
      if (i == 0) {
        if (int.parse(char) > 3) {
          digits = '${digits.substring(0, i)}3${digits.substring(i + 1)}';
        }
      } else if (i == 1) {
        if (digits.isNotEmpty) {
          final firstDayDigit = int.parse(digits[0]);
          if (firstDayDigit == 0) {
            if (int.parse(char) < 1) {
              digits = '${digits.substring(0, i)}1${digits.substring(i + 1)}';
            }
          } else if (firstDayDigit == 3) {
            if (int.parse(char) > 1) {
              digits = '${digits.substring(0, i)}1${digits.substring(i + 1)}';
            }
          }
        }
      } else if (i == 2) {
        if (int.parse(char) > 1) {
          digits = '${digits.substring(0, i)}1${digits.substring(i + 1)}';
        }
      } else if (i == 3) {
        if (digits.length > 2) {
          final firstMonthDigit = int.parse(digits[2]);
          if (firstMonthDigit == 0) {
            if (int.parse(char) < 1) {
              digits = '${digits.substring(0, i)}1${digits.substring(i + 1)}';
            }
          } else if (firstMonthDigit == 1) {
            if (int.parse(char) > 2) {
              digits = '${digits.substring(0, i)}2${digits.substring(i + 1)}';
            }
          }
        }
      } else if (i == 4) {
        final yearDigit = int.parse(char);
        if (yearDigit < 1) {
          digits = '${digits.substring(0, i)}1${digits.substring(i + 1)}';
        } else if (yearDigit > 2) {
          digits = '${digits.substring(0, i)}2${digits.substring(i + 1)}';
        }
      } else if (i == 5) {
        if (digits.length > 4) {
          final firstYearDigit = int.parse(digits[4]);
          final currentYear = DateTime.now().year;
          final currentFirstTwoDigits = currentYear ~/ 100;
          
          if (firstYearDigit == 2) {
            final maxSecondDigit = (currentFirstTwoDigits % 10).toString();
            if (int.parse(char) > int.parse(maxSecondDigit)) {
              digits = digits.substring(0, i) + maxSecondDigit + digits.substring(i + 1);
            }
          }
        }
      }
      
      formatted += digits[i];
    }
    
    if (formatted != _dateText) {
      _dateText = formatted;
      _birthDateController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  bool _isValidDate(String dayStr, String monthStr, String yearStr) {
    try {
      final day = int.parse(dayStr);
      final month = int.parse(monthStr);
      final year = int.parse(yearStr);
      
      final now = DateTime.now();
      
      if (year < 1900 || year > now.year) return false;
      if (month < 1 || month > 12) return false;
      
      final daysInMonth = _getDaysInMonth(month, year);
      if (day < 1 || day > daysInMonth) return false;
      
      final birthDate = DateTime(year, month, day);
      if (birthDate.isAfter(now)) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  void _calculateAge() {
    final text = _birthDateController.text.replaceAll('/', '');
    
    if (text.length == 8) {
      try {
        final dayStr = text.substring(0, 2);
        final monthStr = text.substring(2, 4);
        final yearStr = text.substring(4, 8);
        
        if (!_isValidDate(dayStr, monthStr, yearStr)) {
          _ageController.text = '--';
          if (mounted) {
            setState(() {});
          }
          return;
        }
        
        final day = int.parse(dayStr);
        final month = int.parse(monthStr);
        final year = int.parse(yearStr);
        
        final birthDate = DateTime(year, month, day);
        final now = DateTime.now();
        
        int age = now.year - birthDate.year;
        
        if (now.month < birthDate.month || 
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        
        if (age >= 0 && age <= 120) {
          _ageController.text = age.toString();
        } else {
          _ageController.text = '--';
        }
        
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        _ageController.text = '--';
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      _ageController.text = '--';
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _validatePhoneFirstDigit() {
    final text = _phoneController.text;
    
    if (text.isEmpty) {
      setState(() {
        _hasNineEntered = false;
      });
      return;
    }
    
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.isNotEmpty) {
      if (!_hasNineEntered && digits[0] != '9') {
        _phoneController.clear();
        setState(() {
          _hasNineEntered = false;
        });
        return;
      }
      
      if (digits[0] == '9' && !_hasNineEntered) {
        setState(() {
          _hasNineEntered = true;
        });
      }
      
      if (text != digits) {
        _phoneController.text = digits;
        _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: digits.length),
        );
      }
    }
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7c4dff).withValues(alpha: 0.1) : _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF7c4dff) : const Color(0xFFe5e7eb),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF7c4dff) : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF7c4dff) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final _phoneStartsWithNineFormatter = _PhoneStartsWithNineFormatter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registro de Paciente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_add,
                    color: _secondaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: 'Crea tu ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'cuenta',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa tus datos personales para brindarte una atención personalizada.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Nombres',
                        hintText: 'Ej. Juan',
                        controller: _nameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Apellidos',
                        hintText: 'Ej. Pérez',
                        controller: _lastNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Género',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderOption('Masculino', 'M'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGenderOption('Femenino', 'F'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de Nacimiento',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _birthDateController,
                              focusNode: _dateFocusNode,
                              decoration: InputDecoration(
                                hintText: 'DD/MM/AAAA',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  color: _iconColor,
                                  size: 20,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              inputFormatters: [
                                onlyNumbersFormatter,
                                _DateInputFormatter(),
                              ],
                              buildCounter: (
                                BuildContext context, {
                                required int currentLength,
                                required bool isFocused,
                                required int? maxLength,
                              }) {
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edad',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _ageController,
                              readOnly: true,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '--',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _ageController.text == '--' 
                                    ? Colors.grey.shade400
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                ),
                const SizedBox(height: 24),

                Text(
                  'Información de Contacto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teléfono Móvil',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
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
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '+51',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                hintText: '9XX XXX XXX',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 18,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              keyboardType: TextInputType.phone,
                              maxLength: 9,
                              inputFormatters: [
                                onlyNumbersFormatter,
                                _phoneStartsWithNineFormatter,
                              ],
                              buildCounter: (
                                BuildContext context, {
                                required int currentLength,
                                required bool isFocused,
                                required int? maxLength,
                              }) {
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'Debe comenzar con el número 9',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Correo Electrónico',
                  hintText: 'usuario@correo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contraseña',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
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
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Mínimo 8 caracteres',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: _iconColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _performRegistration(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: _secondaryColor.withValues(alpha: 0.2),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CREAR CUENTA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            _isLoginButtonHovered = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _isLoginButtonHovered = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isLoginButtonHovered
                                ? _secondaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            splashColor: _secondaryColor.withValues(alpha: 0.3),
                            highlightColor:
                                _secondaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isLoginButtonHovered
                                      ? _secondaryColor.withValues(alpha: 0.9)
                                      : _secondaryColor,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _secondaryColor,
                                  decorationThickness: 1.5,
                                ),
                                child: const Text('Volver al inicio de sesión'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty) {
      _showErrorDialog('Por favor, ingresa tus nombres');
      return false;
    }
    
    if (_lastNameController.text.isEmpty) {
      _showErrorDialog('Por favor, ingresa tus apellidos');
      return false;
    }
    
    if (_selectedGender == null) {
      _showErrorDialog('Por favor, selecciona tu género');
      return false;
    }
    
    if (_birthDateController.text.length != 10) {
      _showErrorDialog('Por favor, ingresa una fecha de nacimiento válida (DD/MM/AAAA)');
      return false;
    }
    
    if (_phoneController.text.length != 9) {
      _showErrorDialog('El teléfono debe tener 9 dígitos');
      return false;
    }
    
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showErrorDialog('Por favor, ingresa un correo electrónico válido');
      return false;
    }
    
    if (_passwordController.text.length < 8) {
      _showErrorDialog('La contraseña debe tener al menos 8 caracteres');
      return false;
    }
    
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de validación'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            keyboardType: keyboardType,
          ),
        ),
      ],
    );
  }
}

class _PhoneStartsWithNineFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return oldValue;
    }

    String formattedText;
    
    if (oldValue.text.isEmpty) {
      if (digits[0] != '9') {
        return oldValue;
      }
      formattedText = digits.substring(0, digits.length.clamp(0, 9));
    } else {
      final oldDigits = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      final hasNineAtStart = oldDigits.isNotEmpty && oldDigits[0] == '9';
      
      if (hasNineAtStart) {
        formattedText = digits.substring(0, digits.length.clamp(0, 9));
      } else {
        if (digits.isNotEmpty && digits[0] == '9') {
          formattedText = digits.substring(0, digits.length.clamp(0, 9));
        } else {
          return oldValue;
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }

    for (int i = 0; i < digits.length; i++) {
      final char = digits[i];
      final intValue = int.parse(char);
      
      if (i == 0) {
        if (intValue > 3) {
          digits = _replaceCharAt(digits, i, '3');
        }
      } else if (i == 1) {
        if (digits.isNotEmpty) {
          final firstDayDigit = int.parse(digits[0]);
          if (firstDayDigit == 0) {
            if (intValue < 1) {
              digits = _replaceCharAt(digits, i, '1');
            }
          } else if (firstDayDigit == 3) {
            if (intValue > 1) {
              digits = _replaceCharAt(digits, i, '1');
            }
          }
        }
      } else if (i == 2) {
        if (intValue > 1) {
          digits = _replaceCharAt(digits, i, '1');
        }
      } else if (i == 3) {
        if (digits.length > 2) {
          final firstMonthDigit = int.parse(digits[2]);
          if (firstMonthDigit == 0) {
            if (intValue < 1) {
              digits = _replaceCharAt(digits, i, '1');
            }
          } else if (firstMonthDigit == 1) {
            if (intValue > 2) {
              digits = _replaceCharAt(digits, i, '2');
            }
          }
        }
      } else if (i == 4) {
        if (intValue < 1) {
          digits = _replaceCharAt(digits, i, '1');
        } else if (intValue > 2) {
          digits = _replaceCharAt(digits, i, '2');
        }
      }
    }

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _replaceCharAt(String str, int index, String newChar) {
    return str.substring(0, index) + newChar + str.substring(index + 1);
  }
}
