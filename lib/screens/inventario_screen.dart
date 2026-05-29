import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List<Map<String, dynamic>> _productos = [];
  final _nombreController = TextEditingController();
  final _costoController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  int _idUsuario = 0;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYProductos();
  }

  Future<void> _cargarUsuarioYProductos() async {
    final prefs = await SharedPreferences.getInstance();
    _idUsuario = prefs.getInt('usuario_id') ?? 0;
    await _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final data = await DBHelper.getInventario(_idUsuario);
    setState(() => _productos = data);
  }

  void _mostrarFormulario({Map<String, dynamic>? producto}) {
    if (producto != null) {
      _nombreController.text = producto['nombre'];
      _costoController.text = producto['costo'].toString();
      _precioController.text = producto['precio_venta'].toString();
      _stockController.text = producto['stock'].toString();
    } else {
      _nombreController.clear();
      _costoController.clear();
      _precioController.clear();
      _stockController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1F5E),
        title: Text(
          producto != null ? 'Editar Producto' : 'Nuevo Producto',
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
                  labelText: 'Nombre del producto',
                  labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                  prefixIcon: Icon(Icons.inventory_2, color: Color(0xFFA78BFA)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _costoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Costo (lo que pagaste \$)',
                  labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                  prefixIcon: Icon(Icons.money_off, color: Color(0xFFE13C6C)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _precioController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio de venta (\$)',
                  labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                  prefixIcon: Icon(Icons.attach_money, color: Color(0xFF3CE16C)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _stockController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock disponible (piezas)',
                  labelStyle: TextStyle(color: Color(0xFFA78BFA)),
                  prefixIcon: Icon(Icons.store, color: Color(0xFFA78BFA)),
                ),
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
              final nombre = _nombreController.text.trim();
              final costo = double.tryParse(_costoController.text) ?? 0.0;
              final precio = double.tryParse(_precioController.text) ?? 0.0;
              final stock = int.tryParse(_stockController.text) ?? 0;

              if (nombre.isEmpty) return;

              if (producto != null) {
                await DBHelper.updateInventario(producto['id'], {
                  'nombre': nombre,
                  'costo': costo,
                  'precio_venta': precio,
                  'stock': stock,
                });
              } else {
                await DBHelper.insertInventario({
                  'id_usuario': _idUsuario,
                  'nombre': nombre,
                  'costo': costo,
                  'precio_venta': precio,
                  'stock': stock,
                });
              }
              await _cargarProductos();
              Navigator.pop(context);
            },
            child: Text(
              producto != null ? 'Actualizar' : 'Guardar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalProductos = _productos.length;
    final stockTotal = _productos.fold<int>(0, (s, p) => s + (p['stock'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFF1A1035),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1F5E),
        title: const Text('Inventario',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
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
                  Text('$totalProductos',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA78BFA))),
                  const Text('Productos',
                      style: TextStyle(color: Color(0xFF8B7EC8))),
                ]),
                Column(children: [
                  Text('$stockTotal',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3CE16C))),
                  const Text('En stock',
                      style: TextStyle(color: Color(0xFF8B7EC8))),
                ]),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _productos.isEmpty
                ? const Center(
                    child: Text('No hay productos en el inventario.',
                        style: TextStyle(color: Color(0xFFA78BFA))))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _productos.length,
                    itemBuilder: (_, i) {
                      final p = _productos[i];
                      final ganancia =
                          (p['precio_venta'] as double) - (p['costo'] as double);
                      final stock = p['stock'] as int;
                      final sinStock = stock == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D1F5E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: sinStock
                                ? const Color(0xFFE13C6C)
                                : const Color(0xFF3D2870),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: sinStock
                                ? const Color(0xFFE13C6C).withOpacity(0.2)
                                : const Color(0xFF6C3CE1).withOpacity(0.3),
                            child: Icon(
                              sinStock ? Icons.remove_shopping_cart : Icons.inventory_2,
                              color: sinStock
                                  ? const Color(0xFFE13C6C)
                                  : const Color(0xFFA78BFA),
                              size: 20,
                            ),
                          ),
                          title: Text(p['nombre'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Costo: \$${(p['costo'] as double).toStringAsFixed(2)}  •  Venta: \$${(p['precio_venta'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Color(0xFF8B7EC8), fontSize: 12),
                              ),
                              Text(
                                'Ganancia por pieza: \$${ganancia.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: ganancia >= 0
                                        ? const Color(0xFF3CE16C)
                                        : const Color(0xFFE13C6C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$stock',
                                      style: TextStyle(
                                          color: sinStock
                                              ? const Color(0xFFE13C6C)
                                              : const Color(0xFF3CE16C),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(sinStock ? 'Agotado' : 'pzas',
                                      style: const TextStyle(
                                          color: Color(0xFF8B7EC8),
                                          fontSize: 10)),
                                ],
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFFA78BFA)),
                                onPressed: () => _mostrarFormulario(producto: p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Color(0xFFE13C6C)),
                                onPressed: () async {
                                  await DBHelper.deleteInventario(p['id']);
                                  await _cargarProductos();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C3CE1),
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}