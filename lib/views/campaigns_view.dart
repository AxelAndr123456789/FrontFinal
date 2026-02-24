import 'package:flutter/material.dart';
import 'home_view.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  IconData _obtenerIconoCampana(int id) {
    switch (id) {
      case 1:
        return Icons.female;
      case 2:
        return Icons.vaccines;
      case 3:
        return Icons.child_care;
      default:
        return Icons.local_hospital;
    }
  }

  final List<Map<String, dynamic>> _campanas = [
    {
      'id': 1,
      'titulo': 'Feliz Día de la Mujer',
      'subtitulo': 'Campaña de salud - ¡Ven y Hazte tu descarte!',
      'imagen': 'assets/images/campanas/campa.jpg',
      'servicios': ['Toma de PAP', 'IVAA', 'Planificación Familiar', 'Tamizaje VIH', 'Sífilis', 'Hepatitis B', 'Atención Adolescente'],
      'fecha': 'Marzo 2024',
      'lugar': 'Hospital Regional El Carmen',
      'horario': '8:00 AM - 4:00 PM',
      'telefono': '064-231234',
    },
    {
      'id': 2,
      'titulo': 'Campaña contra Hepatitis B',
      'subtitulo': 'Vacunación y prevención gratuita',
      'imagen': 'assets/images/campanas/hepatitis.jpg',
      'servicios': ['Vacunación gratuita', 'Pruebas rápidas', 'Consultas médicas', 'Entrega de medicamentos'],
      'fecha': 'Todo el año',
      'lugar': 'Vacunatorio - Piso 2',
      'horario': 'Lunes a Viernes: 8:00 AM - 3:00 PM',
      'telefono': '064-231567',
    },
    {
      'id': 3,
      'titulo': 'Lactancia Materna',
      'subtitulo': 'Apoyo integral para madres',
      'imagen': 'assets/images/campanas/lactancia.jpg',
      'servicios': ['Talleres educativos', 'Asesoría personalizada', 'Grupos de apoyo', 'Control de crecimiento'],
      'fecha': 'Programa permanente',
      'lugar': 'Pediatría - Piso 3',
      'horario': 'Martes y Jueves: 9:00 AM - 1:00 PM',
      'telefono': '064-231890',
    },
  ];

  Widget _construirCampana(Map<String, dynamic> campana) {
    final int id = campana['id'] is int ? campana['id'] as int : int.tryParse(campana['id'].toString()) ?? 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 160,
              color: const Color(0xFFf3f0ff),
              child: Image.asset(
                campana['imagen'] as String,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFf3f0ff),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _obtenerIconoCampana(id),
                            size: 48,
                            color: const Color(0xFF7c4dff),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              campana['titulo'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7c4dff),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campana['titulo'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7c4dff),
                  ),
                ),
                
                const SizedBox(height: 6),
                
                Text(
                  campana['subtitulo'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF651fff),
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: (campana['servicios'] as List<dynamic>).map((servicio) {
                    return Chip(
                      label: Text(
                        servicio.toString(),
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: const Color(0xFFf3f0ff),
                      labelStyle: const TextStyle(color: Color(0xFF7c4dff)),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7c4dff)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  campana['fecha'] as String,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Color(0xFF7c4dff)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  campana['lugar'] as String,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _verDetallesCampana(campana),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7c4dff),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
 child: const Text(
                        'Más Información',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _verDetallesCampana(Map<String, dynamic> campana) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        campana['titulo'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7c4dff),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  campana['subtitulo'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF651fff),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(campana['imagen'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Servicios incluidos:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                ...(campana['servicios'] as List<dynamic>).map((servicio) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF7c4dff), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            servicio.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf3f0ff),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    children: [
                      _detalleCampanaItem(Icons.calendar_today, 'Fecha:', campana['fecha'] as String),
                      const SizedBox(height: 6),
                      _detalleCampanaItem(Icons.access_time, 'Horario:', campana['horario'] as String),
                      const SizedBox(height: 6),
                      _detalleCampanaItem(Icons.location_on, 'Lugar:', campana['lugar'] as String),
                      const SizedBox(height: 6),
                      _detalleCampanaItem(Icons.phone, 'Teléfono:', campana['telefono'] as String),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7c4dff),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detalleCampanaItem(IconData icon, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7c4dff)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7c4dff),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
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
        title: const Text('Campañas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campañas de Salud 2026',
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
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7c4dff),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Participa en nuestras campañas de salud gratuitas y mejora tu calidad de vida.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 20),
            
            ..._campanas.map((campana) => _construirCampana(campana)),
            
            const SizedBox(height: 30),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
