// screens/package_detail_screen.dart (Contenido completo de la clase)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart'; 

class PackageDetailScreen extends StatefulWidget {
  final Map package;
  const PackageDetailScreen({super.key, required this.package});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  // Las variables de funcionalidad (no modificadas)
  XFile? _photoXFile; 
  bool _sending = false;
  Position? _position;
  final ImagePicker _picker = ImagePicker();
  String? _statusMsg;

  // Las funciones de funcionalidad (no modificadas)
  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null) {
      setState(() { 
        _photoXFile = image; 
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _statusMsg = 'Activa ubicación'; });
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _statusMsg = 'Permiso de ubicación denegado'; });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() { _statusMsg = 'Permiso denegado permanentemente'; });
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() { _position = pos; });
  }

  Future<void> _deliver() async {
    if (_photoXFile == null) { 
      setState(() { _statusMsg = 'Toma una foto antes de entregar'; });
      return;
    }
    if (_position == null) {
      setState(() { _statusMsg = 'Obten la ubicación antes de entregar'; });
      return;
    }
    setState(() { _sending = true; _statusMsg = null; });
    
    // La funcionalidad de la API se mantiene
    final success = await ApiService.deliverPackage(
      packageId: widget.package['id'],
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      photoFile: _photoXFile!, 
      notes: 'Entregado desde app'
    );
    
    setState(() { _sending = false; });
    
    if (success) {
      setState(() { _statusMsg = 'Entrega registrada'; });
    } else {
      setState(() { _statusMsg = 'Error al registrar entrega'; });
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.package;
    // Usamos el color primario del tema para la marca
    final primaryColor = Theme.of(context).primaryColor; 

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Entrega: ${p['package_uid']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- DETALLES DE LA DIRECCIÓN (Tarjeta de Información) ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dirección de Entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const Divider(),
                    Text('${p['address']}', style: const TextStyle(fontSize: 16)),
                    Text('${p['city']}, ${p['state']} ${p['postal_code']}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- SECCIÓN DE ACCIÓN (FOTO Y UBICACIÓN) ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Evidencia y Posición', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const Divider(),
                    
                    // 1. VISTA PREVIA DE LA FOTO
                    if (_photoXFile != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // Uso de ternario para elegir el widget Image.
                          child: kIsWeb 
                            ? Image.network(_photoXFile!.path, fit: BoxFit.cover) 
                            : Image.file(File(_photoXFile!.path), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // 2. BOTONES DE ACCIÓN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón Tomar Foto
                        OutlinedButton.icon(
                          onPressed: _takePhoto, 
                          icon: const Icon(Icons.camera_alt), 
                          label: const Text('Tomar foto')
                        ),
                        // Botón Obtener Ubicación
                        ElevatedButton.icon(
                          onPressed: _getLocation, 
                          icon: const Icon(Icons.my_location), 
                          label: _position == null ? const Text('Obtener ubicación') : const Text('Ubicación OK'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _position != null ? Colors.green.shade600 : primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- SECCIÓN DEL MAPA ---
            if (_position != null) ...[
              const Text('Posición Actual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FlutterMap(
                    options: MapOptions(center: LatLng(_position!.latitude, _position!.longitude), zoom: 16.0),
                    children: [
                      TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
                      MarkerLayer(markers: [
                        Marker(point: LatLng(_position!.latitude, _position!.longitude), width: 80, height: 80, builder: (ctx) => Icon(Icons.location_pin, size: 40, color: primaryColor)),
                      ])
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // --- BOTÓN DE ENTREGA FINAL ---
            if (_statusMsg != null) 
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_statusMsg!, style: TextStyle(color: _statusMsg == 'Entrega registrada' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ),
              
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _deliver,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _sending 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('FINALIZAR ENTREGA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}