import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final usuarioId = prefs.getInt('usuario_id');
  runApp(MoonzyApp(sesionActiva: usuarioId != null));
}

class MoonzyApp extends StatelessWidget {
  final bool sesionActiva;
  const MoonzyApp({super.key, required this.sesionActiva});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moonzy Ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C3CE1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: sesionActiva ? const DashboardScreen() : const LoginScreen(),
    );
  }
}