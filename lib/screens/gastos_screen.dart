import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  List<Map<String, dynamic>> _gastos = [];
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  String _categoriaSeleccionada = 'Mercancía';
  int _idUsuario = 0;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYGastos();
  }

  Future<void> _cargarUsuarioYGastos() async {
    final prefs = await SharedPreferences.getInstance();
    _idUsuario = prefs.getInt('usuario_id') ?? 0;
    await _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    final data = await DBHelper.getGastos(_idUsuario);
    setState(() => _gastos = data);
  }

  void _mostrarFormulario({Map<String, dynamic>? gasto}) {
    if (gasto != null) {
      _descripcionController.text = gasto['descripcion'];
      _montoController.text = gasto['monto'].toString();
      _categoriaSeleccionada = gasto['categoria'];
    } else {
      _descripcionController.clear();
      _montoController.clear();
      _categoriaSeleccionada = 'Mercancía';
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF2D1F5E),
          title: Text(
            gasto != null ? 'Editar Gasto' : 'Nuevo Gasto',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descripcionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                ),
              ),
              TextField(
                controller: _montoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto (\$)',
                  labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                dropdownColor: const Color(0xFF2D1F5E),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                ),
                items: ['Mercancía', 'Transporte', 'Empaque', 'Otros']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) =>
                    setStateDialog(() => _categoriaSeleccionada = val!),
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
                if (gasto != null) {
                  await DBHelper.updateGasto(gasto['id'], {
                    'descripcion': _descripcionController.text,
                    'monto':
                        double.tryParse(_montoController.text) ?? 0.0,
                    'categoria': _categoriaSeleccionada,
                  });
                } else {
                  await DBHelper.insertGasto({
                    'id_usuario': _idUsuario,
                    'descripcion': _descripcionController.text,
                    'monto':
                        double.tryParse(_montoController.text) ?? 0.0,
                    'categoria': _categoriaSeleccionada,
                  });
                }
                _descripcionController.clear();
                _montoController.clear();
                _categoriaSeleccionada = 'Mercancía';
                await _cargarGastos();
                Navigator.pop(context);
              },
              child: Text(
                gasto != null ? 'Actualizar' : 'Guardar',
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
        title: const Text('Gastos',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
      ),
      body: _gastos.isEmpty
          ? const Center(
              child: Text('No hay gastos aún.',
                  style: TextStyle(color: Color(0xFFA78BFA))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _gastos.length,
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: const Color(0xFF2D1F5E),
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long,
                      color: Color(0xFFA78BFA)),
                  title: Text(_gastos[i]['descripcion'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(_gastos[i]['categoria'],
                      style:
                          const TextStyle(color: Color(0xFF8B7EC8))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('-\$${_gastos[i]['monto']}',
                          style: const TextStyle(
                              color: Color(0xFFE13C6C),
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Color(0xFFA78BFA)),
                        onPressed: () =>
                            _mostrarFormulario(gasto: _gastos[i]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Color(0xFFE13C6C)),
                        onPressed: () async {
                          await DBHelper.deleteGasto(_gastos[i]['id']);
                          await _cargarGastos();
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