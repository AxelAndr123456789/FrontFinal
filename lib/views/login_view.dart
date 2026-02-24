import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'password_recovery_view.dart';
import 'register_view.dart';
import 'home_view.dart';

class HealthConnectLogin extends StatefulWidget {
  const HealthConnectLogin({super.key});

  @override
  State<HealthConnectLogin> createState() => _HealthConnectLoginState();
}

class _HealthConnectLoginState extends State<HealthConnectLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showPassword = false;

  Future<void> _attemptLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _errorMessage = 'Ingresa un correo válido';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await ApiService.login(email, password);
      
      if (!mounted) return;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1c1122),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final imageHeight = availableHeight * 0.32;
            final isSmallScreen = availableHeight < 600;
            
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                  child: Column(
                    children: [
                      Container(
                        height: imageHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://lh3.googleusercontent.com/aida-public/AB6AXuA0jwzYyobfTj0yOxpgXwbEMXRuc9YlJ0fFYXCo6rN3-rnNKLzvJaHK0UqtzNL8h9J3oEzluHK9hNQTgU76AASFQYfreV55JEotgolUH6WGVyF8cmaObzCIJjJNLxCa9zcks9xSUTozmSdBnSv5Y80Dk3BA_xklUGa_WaYlAXQ_ZqqZ8JjeQj7f9hMcwnS9JXol2A4h027zxdtoKjQs_nfV73yXKeB-CqVhdnXse8NOsTJIacB9YHIKnWH51BuGscRwpzVETsvZ80o",
                            ),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.3),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: const Text(
                              "HealthConnect",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 15 : 30),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Bienvenido a HealthConnect",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 15 : 30),

                      if (_errorMessage.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4a1f1f),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFff6b6b)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFff6b6b),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Color(0xFFffb8b8),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _errorMessage = '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFFff6b6b),
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),

                      if (_errorMessage.isNotEmpty) SizedBox(height: isSmallScreen ? 10 : 20),

                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF3c2348),
                          hintText: "Correo electrónico o nombre de usuario",
                          hintStyle: const TextStyle(color: Color(0xFFb792c9)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Color(0xFFb792c9),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 20),

                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF3c2348),
                          hintText: "Contraseña",
                          hintStyle: const TextStyle(color: Color(0xFFb792c9)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFFb792c9),
                          ),
                          suffixIcon: IconButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFFb792c9),
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _isLoading ? null : _attemptLogin(context),
                        enabled: !_isLoading,
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _attemptLogin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7c4dff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Verificando...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  "Iniciar sesión",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 8 : 10),

                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PasswordRecoveryScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          "¿Olvidaste tu contraseña?",
                          style: TextStyle(
                            color: _isLoading
                                ? const Color(0xFFb792c9).withValues(alpha: 0.5)
                                : const Color(0xFFb792c9),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PatientRegistrationScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          "Crear una cuenta",
                          style: TextStyle(
                            color: _isLoading
                                ? const Color(0xFFb792c9).withValues(alpha: 0.5)
                                : const Color(0xFFb792c9),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
