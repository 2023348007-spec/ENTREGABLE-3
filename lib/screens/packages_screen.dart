// screens/packages_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart'; // Para el logout
import 'package_detail_screen.dart'; // Para navegar al detalle

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  List<dynamic>? _packages;
  String? _errorMsg;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final data = await ApiService.getPackages();
      setState(() {
        _packages = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al cargar paquetes: $e';
        _isLoading = false;
      });
    }
  }

  void _logout() {
    // Aquí puedes añadir lógica para eliminar el token si es necesario
    // SharedPreferences.getInstance().then((prefs) => prefs.remove('token'));

    // Navegar de vuelta a la pantalla de login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paquetes Asignados', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchPackages, // Permite recargar manualmente
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      
      // --- CUERPO PRINCIPAL ---
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? Center(child: Text(_errorMsg!))
              : _packages!.isEmpty
                  ? Center(child: Text('No tienes paquetes asignados.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _packages!.length,
                      itemBuilder: (context, index) {
                        final pkg = _packages![index];
                        final statusText = pkg['status'] ?? 'unknown';
                        final isDelivered = statusText == 'delivered';
                        
                        // Definir el color de la tarjeta según el estado
                        final statusColor = isDelivered ? Colors.green.shade700 : primaryColor;

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDelivered ? Colors.transparent : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            // Icono Principal: Color de Marca/Estado
                            leading: CircleAvatar(
                              backgroundColor: statusColor,
                              child: Icon(
                                isDelivered ? Icons.check : Icons.local_shipping,
                                color: Colors.white,
                              ),
                            ),
                            
                            // Título Principal (UID del Paquete)
                            title: Text(
                              pkg['package_uid'],
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                decoration: isDelivered ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                            
                            // Subtítulo (Dirección)
                            subtitle: Text(
                              pkg['address'] ?? 'Dirección no disponible',
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            
                            // Trailing (Etiqueta de Estado)
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusText.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            // Acción al hacer clic
                            onTap: isDelivered
                                ? null // No se puede hacer clic si ya está entregado
                                : () {
                                    // Navegar a la pantalla de detalles (PackageDetailScreen)
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => PackageDetailScreen(package: pkg),
                                      ),
                                    ).then((_) {
                                      // Refrescar la lista al regresar de la pantalla de detalle
                                      _fetchPackages();
                                    });
                                  },
                          ),
                        );
                      },
                    ),
    );
  }
}