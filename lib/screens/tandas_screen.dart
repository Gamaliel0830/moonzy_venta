import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class TandasScreen extends StatefulWidget {
  const TandasScreen({super.key});

  @override
  State<TandasScreen> createState() => _TandasScreenState();
}

class _TandasScreenState extends State<TandasScreen> {
  List<Map<String, dynamic>> _tandas = [];
  final _nombreController = TextEditingController();
  final _montoController = TextEditingController();
  final _participantesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarTandas();
  }

  Future<void> _cargarTandas() async {
    final data = await DBHelper.getTandas();
    setState(() => _tandas = data);
  }

  void _mostrarFormulario({Map<String, dynamic>? tanda}) {
    if (tanda != null) {
      _nombreController.text = tanda['nombre'];
      _montoController.text = tanda['monto'].toString();
      _participantesController.text = tanda['participantes'].toString();
    } else {
      _nombreController.clear();
      _montoController.clear();
      _participantesController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1F5E),
        title: Text(
          tanda != null ? 'Editar Tanda' : 'Nueva Tanda',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre de la tanda',
                labelStyle: TextStyle(color: Color(0xFFA78BFA)),
              ),
            ),
            TextField(
              controller: _montoController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto semanal (\$)',
                labelStyle: TextStyle(color: Color(0xFFA78BFA)),
              ),
            ),
            TextField(
              controller: _participantesController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de participantes',
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
              if (tanda != null) {
                await DBHelper.updateTanda(tanda['id'], {
                  'nombre': _nombreController.text,
                  'monto': double.tryParse(_montoController.text) ?? 0.0,
                  'participantes':
                      int.tryParse(_participantesController.text) ?? 0,
                });
              } else {
                await DBHelper.insertTanda({
                  'nombre': _nombreController.text,
                  'monto': double.tryParse(_montoController.text) ?? 0.0,
                  'participantes':
                      int.tryParse(_participantesController.text) ?? 0,
                });
              }
              _nombreController.clear();
              _montoController.clear();
              _participantesController.clear();
              await _cargarTandas();
              Navigator.pop(context);
            },
            child: Text(
              tanda != null ? 'Actualizar' : 'Guardar',
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
        title: const Text('Tandas', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
      ),
      body: _tandas.isEmpty
          ? const Center(
              child: Text('No hay tandas aún.',
                  style: TextStyle(color: Color(0xFFA78BFA))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tandas.length,
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: const Color(0xFF2D1F5E),
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading:
                      const Icon(Icons.sync, color: Color(0xFFA78BFA)),
                  title: Text(_tandas[i]['nombre'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                      '${_tandas[i]['participantes']} participantes',
                      style: const TextStyle(color: Color(0xFF8B7EC8))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${_tandas[i]['monto']}/sem',
                          style: const TextStyle(
                              color: Color(0xFFA78BFA),
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Color(0xFFA78BFA)),
                        onPressed: () =>
                            _mostrarFormulario(tanda: _tandas[i]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Color(0xFFE13C6C)),
                        onPressed: () async {
                          await DBHelper.deleteTanda(_tandas[i]['id']);
                          await _cargarTandas();
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