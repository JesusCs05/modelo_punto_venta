// Archivo: lib/presentation/screens/admin/inventory_movement_modal.dart
import 'package:flutter/material.dart';
// --- ISAR Imports ---
import 'package:isar/isar.dart';
import '../../../main.dart'; // Para acceso a 'isar'
// Importa las COLLECTIONS necesarias
import '../../../data/collections/producto.dart';
import '../../../data/collections/movimiento_inventario.dart';
import '../../../data/collections/usuario.dart';
// --- End ISAR Imports ---
import '../../theme/app_colors.dart';

import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

Future<void> mostrarModalMovimientoInventario(
  BuildContext context, {
  required String titulo,
  required String tipoMovimiento, // 'Compra', 'Ajuste'
}) {
  // Ya no se necesita Provider.value para la DB
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return _InventoryMovementForm(
        titulo: titulo,
        tipoMovimiento: tipoMovimiento,
      );
    },
  );
}

class _InventoryMovementForm extends StatefulWidget {
  final String titulo;
  final String tipoMovimiento;

  const _InventoryMovementForm({
    required this.titulo,
    required this.tipoMovimiento,
  });

  @override
  State<_InventoryMovementForm> createState() => _InventoryMovementFormState();
}

class _InventoryMovementFormState extends State<_InventoryMovementForm> {
  final _formKey = GlobalKey<FormState>();

  List<Producto> _productosList = [];
  Id? _productoSeleccionadoID; // Id es int
  final _cantidadController = TextEditingController();
  bool _isLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });
    try {
      // Cargar todos los productos usando Isar
      final productos = await isar.productos.where().sortByNombre().findAll();
      if (!mounted) return; // Chequeo async
      setState(() {
        _productosList = productos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading products for inventory modal: $e");
      if (!mounted) return; // Chequeo async
      setState(() {
        _isLoading = false;
        _loadingError = 'Error al cargar productos: $e';
      });
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  /// Guarda el movimiento usando una transacción Isar (RF4.3, RF4.4)
  Future<void> _guardarMovimiento() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final usuarioID = auth.currentUserId;

    if (usuarioID == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no autenticado.'),
            backgroundColor: AppColors.accentDanger,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final int cantidad = int.parse(_cantidadController.text);
      if (_productoSeleccionadoID == null) return; // Seguridad extra

      await isar.writeTxn(() async {
        // 1. Obtener el producto y el usuario
        final producto = await isar.productos.get(_productoSeleccionadoID!);
        final usuario = await isar.usuarios.get(usuarioID);

        if (producto == null || usuario == null) {
          throw Exception('Producto o Usuario no encontrado.');
        }

        // 2. Actualizar el stock del producto
        producto.stockActual +=
            cantidad; // Suma la cantidad (puede ser negativa)
        await isar.productos.put(producto); // Guarda el producto actualizado

        // 3. Crear y guardar el registro de MovimientoInventario
        final movimiento = MovimientoInventario()
          ..fecha = DateTime.now()
          ..cantidad = cantidad
          ..tipoMovimiento = widget.tipoMovimiento
          ..producto.value =
              producto // Link al producto
          ..usuario.value = usuario; // Link al usuario

        await isar.movimientoInventarios.put(movimiento);
        // Guardar links
        await movimiento.producto.save();
        await movimiento.usuario.save();
      });

      if (mounted) Navigator.of(context).pop(); // Cerrar modal
    } catch (e) {
      debugPrint("Error saving inventory movement: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar movimiento: $e'),
            backgroundColor: AppColors.accentDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.titulo,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.cardBackground,
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadingError != null
          ? Center(
              child: Text(
                _loadingError!,
                style: TextStyle(color: AppColors.accentDanger),
              ),
            )
          : _buildForm(),
      actions: (_isLoading || _loadingError != null)
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.accentDanger),
                ),
              ),
              ElevatedButton(
                onPressed: _guardarMovimiento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverted,
                ),
                child: const Text('Guardar Movimiento'),
              ),
            ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        // FIX: Usar SizedBox en lugar de Container
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Selector de Producto (adaptado a Isar Id)
              DropdownButtonFormField<Id>(
                // FIX: Usar initialValue
                initialValue: _productoSeleccionadoID,
                decoration: InputDecoration(
                  labelText: 'Seleccionar Producto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _productosList.map((producto) {
                  return DropdownMenuItem<Id>(
                    value: producto.id, // Usa Id de Isar
                    child: Text(producto.nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _productoSeleccionadoID = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione un producto' : null,
              ),
              const SizedBox(height: 16),

              // 2. Cantidad (sin cambios lógicos)
              TextFormField(
                controller: _cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  hintText: 'Ej: 100 (Entrada) ó -5 (Merma)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  final numero = int.tryParse(value);
                  if (numero == null) return 'Ingrese un número válido';
                  if (numero == 0) return 'La cantidad no puede ser cero';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Nota: Ingrese un número positivo (+) para entradas o compras. Ingrese un número negativo (-) para salidas, mermas o robos.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
