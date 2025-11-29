// screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'packages_screen.dart'; // Asumiendo que esta es la pantalla de destino

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'justin'); // Puedes dejar el valor predeterminado para pruebas
  final _passwordController = TextEditingController(text: '12345');
  bool _isSending = false;
  String? _errorMsg;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isSending = true;
      _errorMsg = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Llama a la API
    final token = await ApiService.login(username, password);

    setState(() {
      _isSending = false;
    });

    if (token != null) {
      // Navegación exitosa a la siguiente pantalla
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const PackagesScreen()),
        );
      }
    } else {
      // Error de credenciales o de red
      setState(() {
        _errorMsg = 'Error de credenciales o conexión. Inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // CORRECCIÓN CLAVE: Usamos un color fijo de la paleta Material para garantizar los sombreados.
    final MaterialColor brandColor = Colors.indigo; // Usamos Indigo como color de marca

    // Obtenemos el color principal del tema (para el texto del encabezado)
    final Color primaryColor = Theme.of(context).primaryColor;


    return Scaffold(
      // 1. FONDO DEGRADADO ATRACTIVO
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // USAMOS brandColor.shadeXXX para el degradado
            colors: [brandColor.shade500, brandColor.shade900], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- ENCABEZADO LLAMATIVO ---
                    Text(
                      'Paquexpress',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        // Usamos el color de la marca para el encabezado
                        color: brandColor, 
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Acceso para Agentes', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 30),

                    // --- CAMPO DE TEXTO: USUARIO ---
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO DE TEXTO: CONTRASEÑA ---
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),

                    // --- MENSAJE DE ERROR ---
                    if (_errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),

                    // --- BOTÓN DE LOGIN ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor, // Usa el color fijo
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                        ),
                        child: _isSending
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('INGRESAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}