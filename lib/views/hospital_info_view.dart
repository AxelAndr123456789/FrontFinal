import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home_view.dart';

class HospitalInfoScreen extends StatefulWidget {
  const HospitalInfoScreen({super.key});

  @override
  State<HospitalInfoScreen> createState() => _HospitalInfoScreenState();
}

class _HospitalInfoScreenState extends State<HospitalInfoScreen> {
  GoogleMapController? _mapController;
  final LatLng _hospitalPosition = const LatLng(-12.0700, -75.2144);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _configurarMapa();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _configurarMapa() {
    _markers.add(
      Marker(
        markerId: const MarkerId('hospital_principal'),
        position: _hospitalPosition,
        infoWindow: const InfoWindow(
          title: 'Hospital Regional El Carmen',
          snippet: 'Jirón Puno N° 911, Huancayo - Junín\nAltitud: 2350 m',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color.fromARGB(255, 0, 0, 0),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF7c4dff),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildServiceRow(IconData icon, String serviceName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7c4dff).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF7c4dff),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              serviceName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
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
        title: const Text('Información'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Información del Hospital'),
              
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
                child: const Text(
                  'El Hospital Regional El Carmen es una institución de salud de referencia en la región Junín, comprometida con brindar atención médica integral y de calidad a toda la población. Con más de 35 años de servicio, contamos con tecnología de vanguardia y un equipo humano altamente capacitado para el diagnóstico, tratamiento y prevención de enfermedades.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Director General'),

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
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFf3f0ff),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/campanas/doctor.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFf3f0ff),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF7c4dff),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dr. Christian Dany Matamoros Vera',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Con más de 20 años de experiencia en gestión hospitalaria, el Dr. Matamoros Vera ha liderado importantes proyectos de modernización en el Hospital Regional El Carmen. Es especialista en Medicina Interna y cuenta con una Maestría en Administración de Salud. Bajo su dirección, el hospital ha obtenido reconocimientos por su calidad de atención y mejora continua.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Ubicación'),
              
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _hospitalPosition,
                            zoom: 15.0,
                          ),
                          markers: _markers,
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          compassEnabled: false,
                          rotateGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          trafficEnabled: false,
                          indoorViewEnabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Dirección'),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Jirón Puno N° 911, Huancayo - Junín',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionHeader('Servicios Destacados'),
              
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
                child: Column(
                  children: [
                    _buildServiceRow(Icons.local_hospital, 'Emergencias 24h'),
                    _buildServiceRow(Icons.medical_services, 'Cirugía General'),
                    _buildServiceRow(Icons.child_friendly, 'Maternidad'),
                    _buildServiceRow(Icons.child_care, 'Pediatría'),
                    _buildServiceRow(Icons.science, 'Laboratorio Clínico'),
                    _buildServiceRow(Icons.image, 'Imágenes Diagnósticas'),
                    _buildServiceRow(Icons.local_pharmacy, 'Farmacia'),
                    _buildServiceRow(Icons.healing, 'Rehabilitación Física'),
                    _buildServiceRow(Icons.favorite, 'Cardiología'),
                    _buildServiceRow(Icons.psychology, 'Neurología'),
                    _buildServiceRow(Icons.accessibility_new, 'Traumatología'),
                    _buildServiceRow(Icons.wc, 'Urología'),
                    _buildServiceRow(Icons.woman, 'Ginecología'),
                    _buildServiceRow(Icons.remove_red_eye, 'Oftalmología'),
                    _buildServiceRow(Icons.spa, 'Dermatología'),
                    _buildServiceRow(Icons.psychology, 'Psiquiatría'),
                    _buildServiceRow(Icons.medical_information, 'Odontología'),
                    _buildServiceRow(Icons.restaurant, 'Nutrición'),
                    _buildServiceRow(Icons.monitor_heart, 'Endocrinología'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Para más información',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7c4dff),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 20, color: const Color(0xFF7c4dff)),
                        const SizedBox(width: 10),
                        Text(
                          'Teléfono: 939873635',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, size: 20, color: const Color(0xFF7c4dff)),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Email: luisfernando@hospitalelcarmen.gob.pe',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.language, size: 20, color: const Color(0xFF7c4dff)),
                        const SizedBox(width: 10),
                        Text(
                          'Web: www.hospitalelcarmen.gob.pe',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, size: 20, color: const Color(0xFF7c4dff)),
                        const SizedBox(width: 10),
                        Text(
                          'Horario: 24 horas / 7 días a la semana',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
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
