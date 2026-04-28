import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  bool _obscurePassword = true;
  bool _esRegistro = false;
  bool _cargando = false;

  Future<void> _iniciarSesion() async {
    setState(() => _cargando = true);
    final usuario = await DBHelper.loginUsuario(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _cargando = false);

    if (usuario != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('usuario_id', usuario['id']);
      await prefs.setString('usuario_nombre', usuario['nombre']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo o contraseña incorrectos'),
          backgroundColor: Color(0xFFE13C6C),
        ),
      );
    }
  }

  Future<void> _registrarse() async {
    if (_nombreController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor llena todos los campos'),
          backgroundColor: Color(0xFFE18A3C),
        ),
      );
      return;
    }

    setState(() => _cargando = true);
    final exito = await DBHelper.registrarUsuario(
      _nombreController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _cargando = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada exitosamente. Inicia sesión.'),
          backgroundColor: Color(0xFF3CE16C),
        ),
      );
      setState(() {
        _esRegistro = false;
        _nombreController.clear();
        _emailController.clear();
        _passwordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ese correo ya está registrado'),
          backgroundColor: Color(0xFFE13C6C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text('🌙', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              const Text('Moonzy Ventas',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                _esRegistro ? 'Crea tu cuenta' : 'Bienvenido de vuelta',
                style: const TextStyle(fontSize: 14, color: Color(0xFFA78BFA)),
              ),
              const SizedBox(height: 36),

              // Campo nombre solo en registro
              if (_esRegistro) ...[
                TextField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: const TextStyle(color: Color(0xFFA78BFA)),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFA78BFA)),
                    filled: true,
                    fillColor: const Color(0xFF2D1F5E),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: const TextStyle(color: Color(0xFFA78BFA)),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFFA78BFA)),
                  filled: true,
                  fillColor: const Color(0xFF2D1F5E),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: const TextStyle(color: Color(0xFFA78BFA)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFA78BFA)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFFA78BFA)),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2D1F5E),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // Botón principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C3CE1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _cargando
                      ? null
                      : (_esRegistro ? _registrarse : _iniciarSesion),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _esRegistro ? 'Crear cuenta' : 'Iniciar Sesión',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cambiar entre login y registro
              TextButton(
                onPressed: () => setState(() {
                  _esRegistro = !_esRegistro;
                  _nombreController.clear();
                  _emailController.clear();
                  _passwordController.clear();
                }),
                child: Text(
                  _esRegistro
                      ? '¿Ya tienes cuenta? Inicia sesión'
                      : '¿No tienes cuenta? Regístrate aquí',
                  style: const TextStyle(color: Color(0xFFA78BFA)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}