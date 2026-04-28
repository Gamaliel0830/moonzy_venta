import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Map<String, dynamic>> _ventas = [];
  final _productoController = TextEditingController();
  final _montoController = TextEditingController();
  String _tipoSeleccionado = 'Contado';

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    final data = await DBHelper.getVentas();
    setState(() => _ventas = data);
  }

  void _mostrarFormulario({Map<String, dynamic>? venta}) {
    if (venta != null) {
      _productoController.text = venta['producto'];
      _montoController.text = venta['monto'].toString();
      _tipoSeleccionado = venta['tipo'];
    } else {
      _productoController.clear();
      _montoController.clear();
      _tipoSeleccionado = 'Contado';
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF2D1F5E),
          title: Text(
            venta != null ? 'Editar Venta' : 'Nueva Venta',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                children: ['Contado', 'Crédito'].map((tipo) => Expanded(
                  child: GestureDetector(
                    onTap: () => setStateDialog(() => _tipoSeleccionado = tipo),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _tipoSeleccionado == tipo
                            ? const Color(0xFF6C3CE1)
                            : const Color(0xFF1A1035),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(tipo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ),
                  ),
                )).toList(),
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
                if (venta != null) {
                  await DBHelper.updateVenta(venta['id'], {
                    'producto': _productoController.text,
                    'monto': double.tryParse(_montoController.text) ?? 0.0,
                    'tipo': _tipoSeleccionado,
                  });
                } else {
                  await DBHelper.insertVenta({
                    'producto': _productoController.text,
                    'monto': double.tryParse(_montoController.text) ?? 0.0,
                    'tipo': _tipoSeleccionado,
                  });
                }
                _productoController.clear();
                _montoController.clear();
                _tipoSeleccionado = 'Contado';
                await _cargarVentas();
                Navigator.pop(context);
              },
              child: Text(
                venta != null ? 'Actualizar' : 'Guardar',
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
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: const Color(0xFF2D1F5E),
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const Icon(Icons.point_of_sale,
                      color: Color(0xFFA78BFA)),
                  title: Text(_ventas[i]['producto'],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(_ventas[i]['tipo'],
                      style: const TextStyle(color: Color(0xFF8B7EC8))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${_ventas[i]['monto']}',
                          style: const TextStyle(
                              color: Color(0xFF3CE16C),
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Color(0xFFA78BFA)),
                        onPressed: () =>
                            _mostrarFormulario(venta: _ventas[i]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Color(0xFFE13C6C)),
                        onPressed: () async {
                          await DBHelper.deleteVenta(_ventas[i]['id']);
                          await _cargarVentas();
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