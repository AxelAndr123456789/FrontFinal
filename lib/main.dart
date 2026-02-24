import 'package:flutter/material.dart';
import 'views/splash_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/password_recovery_view.dart';
import 'views/profile_view.dart';
import 'views/specialties_view.dart';
import 'views/appointment_selection_view.dart';
import 'views/my_appointments_view.dart';
import 'views/hospital_info_view.dart';
import 'views/campaigns_view.dart';

void main() {
  runApp(const HealthConnectApp());
}

class HealthConnectApp extends StatelessWidget {
  const HealthConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7c4dff),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Manrope',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF333333)),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const HealthConnectLogin(),
        '/register': (context) => const PatientRegistrationScreen(),
        '/password-recovery': (context) => const PasswordRecoveryScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/specialties': (context) => const SpecialtiesScreen(),
        '/appointments': (context) => const MyAppointmentsScreen(),
        '/hospital-info': (context) => const HospitalInfoScreen(),
        '/campaigns': (context) => const CampaignsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/appointment-selection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AppointmentSelectionScreen(
              specialty: args['specialty'],
              specialtyId: args['specialtyId'],
            ),
          );
        }
        return null;
      },
    );
  }
}
