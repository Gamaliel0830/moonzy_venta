import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import 'clientes_screen.dart';
import 'ventas_screen.dart';
import 'gastos_screen.dart';
import 'tandas_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _nombreUsuario = '';
int _idUsuario = 0;
  double _totalVentas = 0;
  double _totalGastos = 0;
  double _totalDeudas = 0;
  double _ganancias = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    _idUsuario = prefs.getInt('usuario_id') ?? 0;
    final ventas = await DBHelper.getTotalVentas(_idUsuario);
final gastos = await DBHelper.getTotalGastos(_idUsuario);
final deudas = await DBHelper.getTotalDeudas(_idUsuario);
    setState(() {
      _nombreUsuario = prefs.getString('usuario_nombre') ?? 'Usuario';
      _totalVentas = ventas;
      _totalGastos = gastos;
      _totalDeudas = deudas;
      _ganancias = ventas - gastos;
    });
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1F5E),
        title: const Text('Cerrar sesión',
            style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro que quieres cerrar sesión?',
            style: TextStyle(color: Color(0xFFA78BFA))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFFA78BFA))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE13C6C)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1F5E),
        title: const Text('🌙 Moonzy Ventas',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFE13C6C)),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¡Hola, ${_nombreUsuario.isEmpty ? "Usuario" : _nombreUsuario}! 👋',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Text('Resumen de tu negocio',
                  style: TextStyle(color: Color(0xFFA78BFA))),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ResumenCard(
                    titulo: 'Ventas del mes',
                    valor: '\$${_totalVentas.toStringAsFixed(2)}',
                    color: const Color(0xFF6C3CE1),
                    icono: Icons.trending_up,
                  ),
                  _ResumenCard(
                    titulo: 'Deudas pendientes',
                    valor: '\$${_totalDeudas.toStringAsFixed(2)}',
                    color: const Color(0xFFE13C6C),
                    icono: Icons.people,
                  ),
                  _ResumenCard(
                    titulo: 'Gastos del mes',
                    valor: '\$${_totalGastos.toStringAsFixed(2)}',
                    color: const Color(0xFFE18A3C),
                    icono: Icons.receipt,
                  ),
                  _ResumenCard(
                    titulo: 'Ganancias',
                    valor: '\$${_ganancias.toStringAsFixed(2)}',
                    color: const Color(0xFF3CE16C),
                    icono: Icons.savings,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Módulos',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 10),
              _ModuloTile(
                titulo: 'Clientes',
                subtitulo: 'Gestiona tu cartera de clientes',
                icono: Icons.people,
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ClientesScreen()));
                  _cargarDatos();
                },
              ),
              _ModuloTile(
                titulo: 'Ventas',
                subtitulo: 'Registra y controla tus ventas',
                icono: Icons.point_of_sale,
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VentasScreen()));
                  _cargarDatos();
                },
              ),
              _ModuloTile(
                titulo: 'Gastos',
                subtitulo: 'Controla los gastos de tu negocio',
                icono: Icons.receipt_long,
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GastosScreen()));
                  _cargarDatos();
                },
              ),
              _ModuloTile(
                titulo: 'Tandas',
                subtitulo: 'Administra tus tandas y pagos',
                icono: Icons.sync,
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TandasScreen()));
                  _cargarDatos();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String titulo, valor;
  final Color color;
  final IconData icono;
  const _ResumenCard(
      {required this.titulo,
      required this.valor,
      required this.color,
      required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF2D1F5E),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 28),
          const Spacer(),
          Text(valor,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(titulo,
              style: const TextStyle(fontSize: 12, color: Color(0xFFA78BFA))),
        ],
      ),
    );
  }
}

class _ModuloTile extends StatelessWidget {
  final String titulo, subtitulo;
  final IconData icono;
  final VoidCallback onTap;
  const _ModuloTile(
      {required this.titulo,
      required this.subtitulo,
      required this.icono,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF2D1F5E),
          borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icono, color: const Color(0xFFA78BFA)),
        title: Text(titulo,
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo,
            style:
                const TextStyle(color: Color(0xFF8B7EC8), fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFA78BFA)),
        onTap: onTap,
      ),
    );
  }
}