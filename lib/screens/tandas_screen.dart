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
                  leading: const Icon(Icons.sync,
                      color: Color(0xFFA78BFA)),
                  title: Text(_tandas[i]['nombre'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                      '${_tandas[i]['participantes']} participantes — \$${_tandas[i]['monto']}/sem',
                      style: const TextStyle(color: Color(0xFF8B7EC8))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.people,
                            color: Color(0xFF3CE16C)),
                        tooltip: 'Gestionar tanda',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GestionTandaScreen(
                                  tanda: _tandas[i]),
                            ),
                          );
                          await _cargarTandas();
                        },
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
// PANTALLA DE GESTIÓN DE TANDA
// ════════════════════════════════════════════════════
class GestionTandaScreen extends StatefulWidget {
  final Map<String, dynamic> tanda;
  const GestionTandaScreen({super.key, required this.tanda});

  @override
  State<GestionTandaScreen> createState() => _GestionTandaScreenState();
}

class _GestionTandaScreenState extends State<GestionTandaScreen> {
  List<Map<String, dynamic>> _participantes = [];
  List<Map<String, dynamic>> _semanaActual = [];
  final _nombreController = TextEditingController();
  int _semana = 1;
  int _maxParticipantes = 0;
  int _ultimaSemanaCreada = 0;

  @override
  void initState() {
    super.initState();
    _maxParticipantes = widget.tanda['participantes'];
    _cargarDatos();
  }

  Future<void> _cargarDatos({bool resetSemana = false}) async {
    final participantes =
        await DBHelper.getParticipantes(widget.tanda['id']);
    final ultimaSemana =
        await DBHelper.getUltimaSemana(widget.tanda['id']);
    if (ultimaSemana == 0) {
      setState(() {
        _participantes = participantes;
        _semana = 1;
        _semanaActual = [];
        _ultimaSemanaCreada = 0;
      });
      return;
    }
    // Solo resetear a la última semana si se pide explícitamente (ej: al iniciar nueva semana)
    // En cualquier otro caso, mantener la semana en la que el usuario está navegando
    final semanaACargar = resetSemana ? ultimaSemana : _semana;
    final semanaData = await DBHelper.getParticipantesConSemana(
        widget.tanda['id'], semanaACargar);
    setState(() {
      _participantes = participantes;
      _semanaActual = semanaData;
      _semana = semanaACargar;
      _ultimaSemanaCreada = ultimaSemana;
    });
  }

  Future<void> _cargarSemana(int semana) async {
    final semanaData = await DBHelper.getParticipantesConSemana(
        widget.tanda['id'], semana);
    setState(() {
      _semana = semana;
      _semanaActual = semanaData;
    });
  }

  Future<void> _agregarParticipante() async {
    if (_participantes.length >= _maxParticipantes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Límite alcanzado: máximo $_maxParticipantes participantes'),
          backgroundColor: const Color(0xFFE13C6C),
        ),
      );
      return;
    }
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
              });
              await _cargarDatos();
              Navigator.pop(context);
            },
            child: const Text('Agregar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarNuevaSemana() async {
    final totalSemanas = widget.tanda['participantes'] as int;
    final nuevaSemana = _ultimaSemanaCreada + 1;

    if (nuevaSemana > totalSemanas) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF2D1F5E),
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
              SizedBox(width: 8),
              Text('¡Tanda Concluida!',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            "La tanda \"${widget.tanda['nombre']}\" ha completado sus $totalSemanas semanas. ¡Todos los participantes recibieron su turno! 🎉",
            style: const TextStyle(color: Color(0xFFA78BFA)),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3CE1)),
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    await DBHelper.iniciarNuevaSemana(
        widget.tanda['id'], _participantes, nuevaSemana);
    await _cargarDatos(resetSemana: true);

    if (nuevaSemana == totalSemanas) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semana \$nuevaSemana iniciada — ¡Es la última semana! 🏁'),
          backgroundColor: const Color(0xFFFFD700),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semana \$nuevaSemana iniciada (\$nuevaSemana/\$totalSemanas) ✅'),
          backgroundColor: const Color(0xFF3CE16C),
        ),
      );
    }
  }

  Future<void> _togglePago(Map<String, dynamic> p, bool val) async {
    if (p['semana_id'] != null) {
      await DBHelper.updateSemana(p['semana_id'], val ? 1 : 0);
    } else {
      await DBHelper.insertSemana({
        'id_tanda': widget.tanda['id'],
        'id_participante': p['id'],
        'semana': _semana,
        'pagado': val ? 1 : 0,
      });
    }
    final semanaData = await DBHelper.getParticipantesConSemana(
        widget.tanda['id'], _semana);
    setState(() => _semanaActual = semanaData);
  }

  @override
  Widget build(BuildContext context) {
    final pagados =
        _semanaActual.where((p) => p['pagado'] == 1).length;
    final total = _semanaActual.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1F5E),
        title: Text(widget.tanda['nombre'],
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add,
                color: Color(0xFF3CE16C)),
            tooltip: 'Agregar participante',
            onPressed: _agregarParticipante,
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen
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
                  Text(
                      '${_participantes.length}/$_maxParticipantes',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA78BFA))),
                  const Text('Participantes',
                      style: TextStyle(color: Color(0xFF8B7EC8))),
                ]),
              ],
            ),
          ),

          // Selector de semana
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF2D1F5E),
                borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Color(0xFFA78BFA)),
                  onPressed:
                      _semana > 1 ? () => _cargarSemana(_semana - 1) : null,
                ),
                Column(children: [
                  Text('Semana $_semana',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text('\$${widget.tanda['monto']} por persona',
                      style: const TextStyle(
                          color: Color(0xFFA78BFA), fontSize: 12)),
                ]),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: Color(0xFFA78BFA)),
                  onPressed: _semana < _ultimaSemanaCreada
                      ? () => _cargarSemana(_semana + 1)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Lista
          Expanded(
            child: _participantes.isEmpty
                ? const Center(
                    child: Text('No hay participantes aún.',
                        style: TextStyle(color: Color(0xFFA78BFA))))
                : _semanaActual.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Semana no iniciada',
                                style: TextStyle(
                                    color: Color(0xFFA78BFA),
                                    fontSize: 16)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF6C3CE1)),
                              onPressed: () async {
                                await DBHelper.iniciarNuevaSemana(
                                    widget.tanda['id'],
                                    _participantes,
                                    1);
                                await _cargarDatos();
                              },
                              icon: const Icon(Icons.play_arrow,
                                  color: Colors.white),
                              label: const Text('Iniciar Semana 1',
                                  style:
                                      TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _semanaActual.length,
                        itemBuilder: (_, i) {
                          final p = _semanaActual[i];
                          final pagado = p['pagado'] == 1;
                          final sinRegistrar = p['semana_id'] == null;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D1F5E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: sinRegistrar
                                    ? const Color(0xFF3D2870)
                                    : pagado
                                        ? const Color(0xFF3CE16C)
                                        : const Color(0xFFE13C6C),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                sinRegistrar
                                    ? Icons.radio_button_unchecked
                                    : pagado
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                color: sinRegistrar
                                    ? const Color(0xFF8B7EC8)
                                    : pagado
                                        ? const Color(0xFF3CE16C)
                                        : const Color(0xFFE13C6C),
                                size: 28,
                              ),
                              title: Text(p['nombre'],
                                  style: const TextStyle(
                                      color: Colors.white)),
                              subtitle: Text(
                                sinRegistrar
                                    ? 'Sin registrar'
                                    : pagado
                                        ? 'Pagó ✅'
                                        : 'Pendiente ❌',
                                style: TextStyle(
                                  color: sinRegistrar
                                      ? const Color(0xFF8B7EC8)
                                      : pagado
                                          ? const Color(0xFF3CE16C)
                                          : const Color(0xFFE13C6C),
                                ),
                              ),
                              trailing: Switch(
                                value: pagado,
                                activeColor: const Color(0xFF3CE16C),
                                inactiveThumbColor:
                                    const Color(0xFF8B7EC8),
                                inactiveTrackColor:
                                    const Color(0xFF3D2870),
                                onChanged: (val) =>
                                    _togglePago(p, val),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: _semanaActual.isNotEmpty && total > 0 && _ultimaSemanaCreada < widget.tanda['participantes']
          ? FloatingActionButton.extended(
              backgroundColor: pagados == total
                  ? const Color(0xFF3CE16C)
                  : const Color(0xFF6C3CE1),
              onPressed: () async {
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF2D1F5E),
                    title: const Text('Nueva Semana',
                        style: TextStyle(color: Colors.white)),
                    content: Text(
                      pagados == total
                          ? '¿Iniciar semana ${_ultimaSemanaCreada + 1}? Todos pagaron ✅'
                          : '¿Iniciar semana ${_ultimaSemanaCreada + 1}? Hay ${total - pagados} pendientes ⚠️',
                      style: const TextStyle(
                          color: Color(0xFFA78BFA)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text('Cancelar',
                            style: TextStyle(
                                color: Color(0xFFA78BFA))),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF6C3CE1)),
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text('Iniciar',
                            style:
                                TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirmar == true) await _iniciarNuevaSemana();
              },
              icon: const Icon(Icons.skip_next, color: Colors.white),
              label: Text('Semana ${_ultimaSemanaCreada + 1}',
                  style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}