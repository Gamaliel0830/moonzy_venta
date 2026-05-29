import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Map<String, dynamic>> _ventas = [];
  List<Map<String, dynamic>> _inventario = [];
  final _productoController = TextEditingController();
  final _montoController = TextEditingController();
  String _tipoSeleccionado = 'Contado';
  int _idUsuario = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    _idUsuario = prefs.getInt('usuario_id') ?? 0;
    final ventas = await DBHelper.getVentas(_idUsuario);
    final inventario = await DBHelper.getInventario(_idUsuario);
    setState(() {
      _ventas = ventas;
      _inventario = inventario;
    });
  }

  void _mostrarFormulario({Map<String, dynamic>? venta}) {
    // Usar ID en lugar de objeto para el dropdown
    int? idProductoSeleccionado;

    if (venta != null) {
      _productoController.text = venta['producto'];
      _montoController.text = venta['monto'].toString();
      _tipoSeleccionado = venta['tipo'];
      idProductoSeleccionado = venta['id_producto'];
    } else {
      _productoController.clear();
      _montoController.clear();
      _tipoSeleccionado = 'Contado';
      idProductoSeleccionado = null;
    }

    // Helper para obtener producto por ID
    Map<String, dynamic>? getProducto(int? id) {
      if (id == null) return null;
      try {
        return _inventario.firstWhere((p) => p['id'] == id);
      } catch (_) {
        return null;
      }
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final productoActual = getProducto(idProductoSeleccionado);
          return AlertDialog(
            backgroundColor: const Color(0xFF2D1F5E),
            title: Text(
              venta != null ? 'Editar Venta' : 'Nueva Venta',
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de producto del inventario
                  if (_inventario.isNotEmpty) ...[
                    const Text('Producto del inventario:',
                        style: TextStyle(
                            color: Color(0xFFA78BFA), fontSize: 12)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      value: idProductoSeleccionado,
                      dropdownColor: const Color(0xFF2D1F5E),
                      hint: const Text('Seleccionar del inventario',
                          style: TextStyle(
                              color: Color(0xFF8B7EC8), fontSize: 13)),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFA78BFA)),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('— Escribir manualmente',
                              style: TextStyle(
                                  color: Color(0xFF8B7EC8),
                                  fontSize: 13)),
                        ),
                        ..._inventario.map((p) => DropdownMenuItem<int>(
                              value: p['id'] as int,
                              child: Text(
                                '${p['nombre']} — \$${(p['precio_venta'] as double).toStringAsFixed(2)} (stock: ${p['stock']})',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            )),
                      ],
                      onChanged: (val) {
                        setStateDialog(() {
                          idProductoSeleccionado = val;
                          final prod = getProducto(val);
                          if (prod != null) {
                            _productoController.text = prod['nombre'];
                            _montoController.text =
                                (prod['precio_venta'] as double)
                                    .toStringAsFixed(2);
                          } else {
                            _productoController.clear();
                            _montoController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    if (productoActual != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1035),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Color(0xFF3CE16C), size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Ganancia por pieza: \$${((productoActual['precio_venta'] as double) - (productoActual['costo'] as double)).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Color(0xFF3CE16C),
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(color: Color(0xFF3D2870)),
                  ],

                  TextField(
                    controller: _productoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Producto',
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
                  Row(
                    children: ['Contado', 'Crédito']
                        .map((tipo) => Expanded(
                              child: GestureDetector(
                                onTap: () => setStateDialog(
                                    () => _tipoSeleccionado = tipo),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _tipoSeleccionado == tipo
                                        ? const Color(0xFF6C3CE1)
                                        : const Color(0xFF1A1035),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(tipo,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13)),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
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
                  final nombre = _productoController.text.trim();
                  final monto =
                      double.tryParse(_montoController.text) ?? 0.0;
                  if (nombre.isEmpty) return;

                  final prod = getProducto(idProductoSeleccionado);

                  // Verificar stock si viene del inventario y es venta nueva
                  if (prod != null && venta == null) {
                    final stock = prod['stock'] as int;
                    if (stock <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Sin stock disponible para este producto'),
                          backgroundColor: Color(0xFFE13C6C),
                        ),
                      );
                      return;
                    }
                  }

                  if (venta != null) {
                    await DBHelper.updateVenta(venta['id'], {
                      'producto': nombre,
                      'monto': monto,
                      'tipo': _tipoSeleccionado,
                      'id_producto': idProductoSeleccionado,
                    });
                  } else {
                    await DBHelper.insertVenta({
                      'id_usuario': _idUsuario,
                      'producto': nombre,
                      'monto': monto,
                      'tipo': _tipoSeleccionado,
                      'id_producto': idProductoSeleccionado,
                    });
                    if (prod != null) {
                      await DBHelper.descontarStock(prod['id'] as int, 1);
                    }
                  }
                  _productoController.clear();
                  _montoController.clear();
                  _tipoSeleccionado = 'Contado';
                  await _cargarDatos();
                  Navigator.pop(context);
                },
                child: Text(
                  venta != null ? 'Actualizar' : 'Guardar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1F5E),
        title: const Text('Ventas', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
      ),
      body: _ventas.isEmpty
          ? const Center(
              child: Text('No hay ventas aún.',
                  style: TextStyle(color: Color(0xFFA78BFA))))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ventas.length,
              itemBuilder: (_, i) {
                final v = _ventas[i];
                final tieneInventario = v['id_producto'] != null;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFF2D1F5E),
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: const Icon(Icons.point_of_sale,
                        color: Color(0xFFA78BFA)),
                    title: Text(v['producto'],
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Row(
                      children: [
                        Text(v['tipo'],
                            style: const TextStyle(
                                color: Color(0xFF8B7EC8))),
                        if (tieneInventario) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3CE16C)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Inventario',
                                style: TextStyle(
                                    color: Color(0xFF3CE16C),
                                    fontSize: 10)),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${v['monto']}',
                            style: const TextStyle(
                                color: Color(0xFF3CE16C),
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Color(0xFFA78BFA)),
                          onPressed: () =>
                              _mostrarFormulario(venta: v),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color(0xFFE13C6C)),
                          onPressed: () async {
                            await DBHelper.deleteVenta(v['id']);
                            await _cargarDatos();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C3CE1),
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}