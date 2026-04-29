import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Map<String, dynamic>> _clientes = [];
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _deudaController = TextEditingController();
  bool _debe = false;
  int _idUsuario = 0;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYClientes();
  }

  Future<void> _cargarUsuarioYClientes() async {
    final prefs = await SharedPreferences.getInstance();
    _idUsuario = prefs.getInt('usuario_id') ?? 0;
    await _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    final data = await DBHelper.getClientes(_idUsuario);
    setState(() => _clientes = data);
  }

  void _mostrarFormulario({Map<String, dynamic>? cliente}) {
    if (cliente != null) {
      _nombreController.text = cliente['nombre'];
      _telefonoController.text = cliente['telefono'];
      _debe = cliente['debe'] == 1;
      _deudaController.text = cliente['monto_deuda'] != null
          ? cliente['monto_deuda'].toString()
          : '';
    } else {
      _nombreController.clear();
      _telefonoController.clear();
      _deudaController.clear();
      _debe = false;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF2D1F5E),
          title: Text(
            cliente != null ? 'Editar Cliente' : 'Nuevo Cliente',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                  ),
                ),
                TextField(
                  controller: _telefonoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('¿Debe algo?',
                        style: TextStyle(color: Color(0xFFA78BFA))),
                    Switch(
                      value: _debe,
                      activeColor: const Color(0xFFE13C6C),
                      onChanged: (val) =>
                          setStateDialog(() => _debe = val),
                    ),
                  ],
                ),
                if (_debe) ...[
                  TextField(
                    controller: _deudaController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto que debe (\$)',
                      labelStyle: TextStyle(color: Color(0xFFE13C6C)),
                      prefixIcon: Icon(Icons.attach_money,
                          color: Color(0xFFE13C6C)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFFA78BFA))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3CE1)),
              onPressed: () async {
                if (cliente != null) {
                  await DBHelper.updateCliente(cliente['id'], {
                    'nombre': _nombreController.text,
                    'telefono': _telefonoController.text,
                    'debe': _debe ? 1 : 0,
                    'monto_deuda': _debe
                        ? double.tryParse(_deudaController.text) ?? 0.0
                        : 0.0,
                  });
                } else {
                  await DBHelper.insertCliente({
                    'id_usuario': _idUsuario,
                    'nombre': _nombreController.text,
                    'telefono': _telefonoController.text,
                    'debe': _debe ? 1 : 0,
                    'monto_deuda': _debe
                        ? double.tryParse(_deudaController.text) ?? 0.0
                        : 0.0,
                  });
                }
                _nombreController.clear();
                _telefonoController.clear();
                _deudaController.clear();
                _debe = false;
                await _cargarClientes();
                Navigator.pop(context);
              },
              child: Text(
                cliente != null ? 'Actualizar' : 'Guardar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1F5E),
        title: const Text('Clientes',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
      ),
      body: _clientes.isEmpty
          ? const Center(
              child: Text('No hay clientes aún.',
                  style: TextStyle(color: Color(0xFFA78BFA))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _clientes.length,
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: const Color(0xFF2D1F5E),
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const Icon(Icons.person,
                      color: Color(0xFFA78BFA)),
                  title: Text(_clientes[i]['nombre'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_clientes[i]['telefono'],
                          style: const TextStyle(
                              color: Color(0xFF8B7EC8))),
                      if (_clientes[i]['debe'] == 1 &&
                          _clientes[i]['monto_deuda'] != null &&
                          _clientes[i]['monto_deuda'] > 0)
                        Text(
                          'Debe: \$${_clientes[i]['monto_deuda']}',
                          style: const TextStyle(
                              color: Color(0xFFE13C6C),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _clientes[i]['debe'] == 1
                              ? const Color(0xFFE13C6C)
                              : const Color(0xFF3CE16C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _clientes[i]['debe'] == 1 ? 'Debe' : 'Al día',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Color(0xFFA78BFA)),
                        onPressed: () =>
                            _mostrarFormulario(cliente: _clientes[i]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Color(0xFFE13C6C)),
                        onPressed: () async {
                          await DBHelper.deleteCliente(_clientes[i]['id']);
                          await _cargarClientes();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C3CE1),
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}