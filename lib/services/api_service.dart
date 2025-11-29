import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Importación necesaria para el tipo XFile
import 'package:image_picker/image_picker.dart'; 

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8001/api/v1"; 

  // --- Método Auxiliar para obtener el token guardado ---
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- 1. Método de Login (Implementación omitida por brevedad) ---
  static Future<String?> login(String username, String password) async {
    // ... tu lógica de login actual ...
    final uri = Uri.parse('$baseUrl/token');
    try {
      final response = await http.post(uri, body: {'username': username, 'password': password,});
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        return token;
      } else {
        print('Login fallido con estado: ${response.statusCode}'); return null; 
      }
    } catch (e) {
      print('Error de conexión durante el login: $e'); return null;
    }
  }


  // --- 2. getPackages() (Implementación omitida por brevedad) ---
  static Future<List<dynamic>> getPackages() async {
    final token = await getToken();
    if (token == null) return [];
    final uri = Uri.parse('$baseUrl/packages');
    try {
      final response = await http.get(uri, headers: {'Authorization': 'Bearer $token',});
      if (response.statusCode == 200) { return jsonDecode(response.body); } else { return []; }
    } catch (e) { return []; }
  }


  // --- 3. deliverPackage() (IMPLEMENTACIÓN CORREGIDA CON XFile Y BYTES) ---
  static Future<bool> deliverPackage({
    required int packageId,
    required double latitude,
    required double longitude,
    required XFile photoFile, // <--- AHORA ACEPTA EL OBJETO XFile
    required String notes,
  }) async {
    final token = await getToken();
    if (token == null) {
      print('Error 401: Token JWT no disponible.');
      return false;
    }

    // 1. Crear la solicitud Multipart
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/deliver'),
    );
    
    // 2. Añadir el token de autenticación
    request.headers['Authorization'] = 'Bearer $token';

    // 3. Añadir los campos de texto
    request.fields['package_id'] = packageId.toString();
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['notes'] = notes;

    // 4. CORRECCIÓN CLAVE: Leer los bytes del XFile (funciona en todas las plataformas)
    try {
        final bytes = await photoFile.readAsBytes();
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'file', // ¡Nombre del campo que espera FastAPI!
            bytes, 
            filename: photoFile.name, // Usar el nombre de archivo del XFile
          )
        );
    } catch (e) {
        print('Error al leer el archivo para subir: $e');
        return false;
    }
    
    // 5. Enviar la solicitud y obtener respuesta
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Entrega registrada exitosamente. ${response.body}');
        return true;
      } else {
        print('Fallo al registrar la entrega. Estado: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de red/conexión en deliverPackage: $e');
      return false;
    }
  }
}