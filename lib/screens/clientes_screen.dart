import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    final data = await DBHelper.getClientes();
    setState(() => _clientes = data);
  }

  void _mostrarFormulario({Map<String, dynamic>? cliente}) {
    if (cliente != null) {
      _nombreController.text = cliente['nombre'];
      _telefonoController.text = cliente['telefono'];
    } else {
      _nombreController.clear();
      _telefonoController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1F5E),
        title: Text(
          cliente != null ? 'Editar Cliente' : 'Nuevo Cliente',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
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
          ],
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
                });
              } else {
                await DBHelper.insertCliente({
                  'nombre': _nombreController.text,
                  'telefono': _telefonoController.text,
                });
              }
              _nombreController.clear();
              _telefonoController.clear();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1F5E),
        title: const Text('Clientes', style: TextStyle(color: Colors.white)),
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
                  leading:
                      const Icon(Icons.person, color: Color(0xFFA78BFA)),
                  title: Text(_clientes[i]['nombre'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(_clientes[i]['telefono'],
                      style: const TextStyle(color: Color(0xFF8B7EC8))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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