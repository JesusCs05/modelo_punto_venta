// Archivo: lib/presentation/screens/admin/inventory_movement_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../main.dart';
import '../../../data/collections/producto.dart';
import '../../../data/collections/movimiento_inventario.dart';
import '../../../data/collections/usuario.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';

class InventoryMovementCartScreen extends StatefulWidget {
  final String tipoMovimiento; // 'Compra' o 'Ajuste'
  const InventoryMovementCartScreen({super.key, required this.tipoMovimiento});

  @override
  State<InventoryMovementCartScreen> createState() =>
      _InventoryMovementCartScreenState();
}

class _InventoryMovementCartScreenState
    extends State<InventoryMovementCartScreen> {
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController(
    text: '1',
  );
  final TextEditingController _nameController = TextEditingController();

  // Línea del carrito
  // productoId -> cantidad (puede ser negativa si tipoMovimiento == 'Ajuste')
  final Map<Id, int> _lines = {};
  List<Producto> _nameResults = [];
  int _namePage = 0; // paginación para resultados de nombre
  static const int _pageSize = 20;

  Producto? _selectedProducto; // Producto encontrado por SKU
  bool _isSaving = false;

  @override
  void dispose() {
    _skuController.dispose();
    _cantidadController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _searchSku(String value) {
    if (value.trim().isEmpty) {
      setState(() => _selectedProducto = null);
      return;
    }
    // Buscar exacto y luego contains
    Producto? producto = isar.productos
        .filter()
        .skuEqualTo(value.trim(), caseSensitive: false)
        .findFirstSync();
    producto ??= isar.productos
        .filter()
        .skuIsNotNull()
        .skuContains(value.trim(), caseSensitive: false)
        .findFirstSync();
    setState(() {
      _selectedProducto = producto;
    });
  }

  void _searchByName(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _selectedProducto = null;
        _nameResults = [];
        _namePage = 0;
      });
      return;
    }
    // Buscar por nombre contains, si hay un único resultado, seleccionar
    final encontrados = isar.productos
        .filter()
        .nombreContains(value.trim(), caseSensitive: false)
        .findAllSync();
    setState(() {
      _nameResults = encontrados;
      _namePage = 0; // reset página al buscar
      if (encontrados.length == 1) {
        _selectedProducto = encontrados.first;
        // Rellenar el SKU si existe para referencia
        if (_selectedProducto?.sku != null) {
          _skuController.text = _selectedProducto!.sku!;
        }
      } else {
        _selectedProducto = encontrados.isNotEmpty ? encontrados.first : null;
      }
    });
  }

  void _addLine() {
    if (_selectedProducto == null) return;
    final qty = int.tryParse(_cantidadController.text.trim()) ?? 0;
    if (qty == 0) return;
    if (widget.tipoMovimiento == 'Compra' && qty < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En entrada (compra) use cantidad positiva'),
          backgroundColor: AppColors.accentCta,
        ),
      );
      return;
    }
    final id = _selectedProducto!.id;
    _lines.update(id, (prev) => prev + qty, ifAbsent: () => qty);
    // limpiar cantidad y SKU para siguiente captura rápida
    _cantidadController.text = '1';
    _skuController.clear();
    setState(() {
      _selectedProducto = null;
    });
  }

  Future<void> _saveAll() async {
    if (_lines.isEmpty) return;
    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final usuarioId = auth.currentUserId;
    if (usuarioId == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario no autenticado'),
          backgroundColor: AppColors.accentCta,
        ),
      );
      return;
    }
    try {
      await isar.writeTxn(() async {
        for (final entry in _lines.entries) {
          final producto = await isar.productos.get(entry.key);
          final usuario = await isar.usuarios.get(usuarioId);
          if (producto == null || usuario == null) continue;
          producto.stockActual += entry.value; // puede ser negativo si Ajuste
          await isar.productos.put(producto);
          final mov = MovimientoInventario()
            ..fecha = DateTime.now()
            ..cantidad = entry.value
            ..tipoMovimiento = widget.tipoMovimiento
            ..producto.value = producto
            ..usuario.value = usuario;
          await isar.movimientoInventarios.put(mov);
          await mov.producto.save();
          await mov.usuario.save();
        }
      });
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movimientos guardados'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppColors.accentCta,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          widget.tipoMovimiento == 'Compra'
              ? 'Entrada (Compra)'
              : 'Ajuste de Inventario',
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _skuController,
                    decoration: InputDecoration(
                      labelText: 'SKU',
                      hintText: 'Escanee o escriba SKU',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _searchSku,
                    onSubmitted: _searchSku,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de producto',
                      hintText: 'Buscar por nombre (contiene)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _searchByName,
                    onSubmitted: _searchByName,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cantidadController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      hintText: widget.tipoMovimiento == 'Compra'
                          ? '+10'
                          : '+/-10',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedProducto != null)
              Card(
                color: AppColors.cardBackground,
                child: ListTile(
                  title: Text(_selectedProducto!.nombre),
                  subtitle: Text(
                    'Stock actual: ${_selectedProducto!.stockActual}',
                  ),
                ),
              ),
            // Selector de resultados por nombre (cuando hay múltiples coincidencias)
            if (_nameResults.length > 1)
              Card(
                color: AppColors.cardBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Coincidencias por nombre:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Lista paginada (20 por página)
                    Builder(
                      builder: (context) {
                        final start = _namePage * _pageSize;
                        final end = (start + _pageSize) > _nameResults.length
                            ? _nameResults.length
                            : (start + _pageSize);
                        final slice = _nameResults.sublist(start, end);
                        final totalPages = (_nameResults.length / _pageSize)
                            .ceil();
                        return Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: slice.length,
                                itemBuilder: (context, idx) {
                                  final p = slice[idx];
                                  return ListTile(
                                    title: Text(p.nombre),
                                    subtitle: Text(
                                      'SKU: ${p.sku ?? 'N/A'} • Stock: ${p.stockActual}',
                                    ),
                                    trailing: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedProducto = p;
                                          _skuController.text = p.sku ?? '';
                                        });
                                      },
                                      child: const Text('Seleccionar'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Página ${_namePage + 1} de $totalPages',
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Anterior',
                                    onPressed: _namePage > 0
                                        ? () {
                                            setState(() {
                                              _namePage -= 1;
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                  IconButton(
                                    tooltip: 'Siguiente',
                                    onPressed: end < _nameResults.length
                                        ? () {
                                            setState(() {
                                              _namePage += 1;
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                color: AppColors.cardBackground,
                child: ListView(
                  children: _lines.entries.map((e) {
                    final p = isar.productos.getSync(e.key);
                    final nombre = p?.nombre ?? 'Producto ${e.key}';
                    final stock = p?.stockActual ?? 0;
                    return ListTile(
                      title: Text(nombre),
                      subtitle: Text(
                        'En carrito: ${e.value}  •  Stock actual: $stock',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                final curr = _lines[e.key] ?? 0;
                                if (curr <= 1) {
                                  _lines.remove(e.key);
                                } else {
                                  _lines[e.key] = curr - 1;
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                _lines[e.key] = (_lines[e.key] ?? 0) + 1;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                _lines.remove(e.key);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Summary bar
            Builder(
              builder: (context) {
                final totalLines = _lines.length;
                final netQty = _lines.values.fold<int>(0, (sum, v) => sum + v);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Líneas: $totalLines',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Cantidad neta: $netQty',
                          style: TextStyle(
                            color: netQty >= 0
                                ? AppColors.primary
                                : AppColors.accentCta,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (_lines.isEmpty) return;
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirmar guardado'),
                                content: const Text(
                                  '¿Guardar todos los movimientos en el inventario?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('No'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Sí'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await _saveAll();
                            }
                          },
                    icon: const Icon(Icons.save),
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Guardar Movimientos',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
