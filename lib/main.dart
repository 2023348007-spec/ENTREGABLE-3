// main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/packages_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PaquexpressApp());
}

class PaquexpressApp extends StatelessWidget {
  const PaquexpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paquexpress',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/packages': (context) => const PackagesScreen(),
      },
    );
  }
}
