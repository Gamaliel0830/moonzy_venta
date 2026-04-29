import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _idUsuario = 0;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYTandas();
  }

  Future<void> _cargarUsuarioYTandas() async {
    final prefs = await SharedPreferences.getInstance();
    _idUsuario = prefs.getInt('usuario_id') ?? 0;
    await _cargarTandas();
  }

  Future<void> _cargarTandas() async {
    final data = await DBHelper.getTandas(_idUsuario);
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
                  'id_usuario': _idUsuario,
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

  void _verParticipantes(Map<String, dynamic> tanda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParticipantesScreen(tanda: tanda),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1F5E),
        title: const Text('Tandas',
            style: TextStyle(color: Colors.white)),
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
                      '${_tandas[i]['participantes']} participantes — \$${_tandas[i]['monto']}/sem',
                      style:
                          const TextStyle(color: Color(0xFF8B7EC8))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.people,
                            color: Color(0xFF3CE16C)),
                        tooltip: 'Ver participantes',
                        onPressed: () => _verParticipantes(_tandas[i]),
                      ),
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
                          await DBHelper.deleteParticipantesByTanda(
                              _tandas[i]['id']);
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

// ════════════════════════════════════════════════════
// PANTALLA DE PARTICIPANTES
// ════════════════════════════════════════════════════
class ParticipantesScreen extends StatefulWidget {
  final Map<String, dynamic> tanda;
  const ParticipantesScreen({super.key, required this.tanda});

  @override
  State<ParticipantesScreen> createState() => _ParticipantesScreenState();
}

class _ParticipantesScreenState extends State<ParticipantesScreen> {
  List<Map<String, dynamic>> _participantes = [];
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarParticipantes();
  }

  Future<void> _cargarParticipantes() async {
    final data = await DBHelper.getParticipantes(widget.tanda['id']);
    setState(() => _participantes = data);
  }

  void _agregarParticipante() {
    _nombreController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1F5E),
        title: const Text('Nuevo Participante',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _nombreController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(color: Color(0xFFA78BFA)),
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
              await DBHelper.insertParticipante({
                'id_tanda': widget.tanda['id'],
                'nombre': _nombreController.text,
                'pagado': 0,
              });
              await _cargarParticipantes();
              Navigator.pop(context);
            },
            child: const Text('Agregar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagados = _participantes.where((p) => p['pagado'] == 1).length;
    final total = _participantes.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1F5E),
        title: Text(widget.tanda['nombre'],
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
      ),
      body: Column(
        children: [
          // Resumen de pagos
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF2D1F5E),
                borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  Text('$pagados',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3CE16C))),
                  const Text('Pagaron',
                      style: TextStyle(color: Color(0xFF8B7EC8))),
                ]),
                Column(children: [
                  Text('${total - pagados}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE13C6C))),
                  const Text('Pendientes',
                      style: TextStyle(color: Color(0xFF8B7EC8))),
                ]),
                Column(children: [
                  Text('$total',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA78BFA))),
                  const Text('Total',
                      style: TextStyle(color: Color(0xFF8B7EC8))),
                ]),
              ],
            ),
          ),
          // Lista de participantes
          Expanded(
            child: _participantes.isEmpty
                ? const Center(
                    child: Text('No hay participantes aún.',
                        style: TextStyle(color: Color(0xFFA78BFA))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _participantes.length,
                    itemBuilder: (_, i) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xFF2D1F5E),
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: Icon(
                          _participantes[i]['pagado'] == 1
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: _participantes[i]['pagado'] == 1
                              ? const Color(0xFF3CE16C)
                              : const Color(0xFFE13C6C),
                          size: 28,
                        ),
                        title: Text(_participantes[i]['nombre'],
                            style:
                                const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          _participantes[i]['pagado'] == 1
                              ? 'Ya pagó ✅'
                              : 'Pendiente ❌',
                          style: TextStyle(
                            color: _participantes[i]['pagado'] == 1
                                ? const Color(0xFF3CE16C)
                                : const Color(0xFFE13C6C),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: _participantes[i]['pagado'] == 1,
                              activeColor: const Color(0xFF3CE16C),
                              onChanged: (val) async {
                                await DBHelper.updateParticipante(
                                    _participantes[i]['id'],
                                    {'pagado': val ? 1 : 0});
                                await _cargarParticipantes();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Color(0xFFE13C6C)),
                              onPressed: () async {
                                await DBHelper.updateParticipante(
                                    _participantes[i]['id'],
                                    {'pagado': 0});
                                final db = await DBHelper.database;
                                await db.delete('tanda_participantes',
                                    where: 'id = ?',
                                    whereArgs: [_participantes[i]['id']]);
                                await _cargarParticipantes();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C3CE1),
        onPressed: _agregarParticipante,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}