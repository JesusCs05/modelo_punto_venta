// Archivo: lib/presentation/widgets/pos/modal_recibir_envases.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import '../../../main.dart'; // Para acceso a 'isar'
import '../../../data/collections/producto.dart';
import '../../../data/collections/movimiento_inventario.dart';
import '../../../data/collections/usuario.dart';
import '../../../data/collections/tipo_producto.dart'; // Necesario para filtro
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/theme/app_colors.dart';

/// Muestra el modal para registrar la recepción de envases vacíos (RF3.4)
Future<void> mostrarModalRecibirEnvases(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      // No necesitamos pasar el AuthProvider, lo leerá desde el context
      return const _ReceiveBottlesForm();
    },
  );
}

class _ReceiveBottlesForm extends StatefulWidget {
  const _ReceiveBottlesForm();

  @override
  State<_ReceiveBottlesForm> createState() => _ReceiveBottlesFormState();
}

class _ReceiveBottlesFormState extends State<_ReceiveBottlesForm> {
  final _formKey = GlobalKey<FormState>();

  List<Producto> _envasesList = []; // Solo productos tipo "Envase"
  Id? _productoSeleccionadoID;
  final _cantidadController = TextEditingController();
  bool _isLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _cargarEnvases();
  }

  /// Carga SOLO productos de tipo 'Envase'
  Future<void> _cargarEnvases() async {
    setState(() { _isLoading = true; _loadingError = null;});
    try {
      // 1. Encontrar el TipoProducto 'Envase'
      final tipoEnvase = await isar.tipoProductos.filter().nombreEqualTo('Envase').findFirst();
      if (tipoEnvase == null) {
        throw Exception('No se encontró el Tipo de Producto "Envase" en la BD.');
      }

      // 2. Cargar solo productos de ese tipo
      final envases = await isar.productos
          .filter()
          .tipoProducto((q) => q.idEqualTo(tipoEnvase.id))
          .sortByNombre()
          .findAll();
      
      if (!mounted) return;
      setState(() {
        _envasesList = envases;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading envases: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError = 'Error al cargar envases: $e';
      });
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  /// Guarda el movimiento de entrada de envase
  Future<void> _guardarRecepcion() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 1. Leer el AuthProvider
    final auth = context.read<AuthProvider>();
    final usuarioID = auth.currentUserId;
    if (usuarioID == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error: Usuario no identificado.'), backgroundColor: AppColors.accentCta,)
       );
       return;
    }
    
    setState(() { _isLoading = true; });

    try {
      final int cantidad = int.parse(_cantidadController.text);
      if (_productoSeleccionadoID == null) return;
      
      // La cantidad DEBE ser positiva
      if (cantidad <= 0) {
         setState(() { _isLoading = false; });
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('La cantidad debe ser un número positivo.'), backgroundColor: AppColors.accentCta,)
         );
         return;
      }

      // 2. Usar la misma transacción de 'registrarMovimientoInventario'
      // que creamos para entradas y ajustes.
      await isar.writeTxn(() async {
        final producto = await isar.productos.get(_productoSeleccionadoID!);
        final usuario = await isar.usuarios.get(usuarioID);

        if (producto == null || usuario == null) {
          throw Exception('Producto o Usuario no encontrado.');
        }
        
        // RF4.2: El stock de Envase aumenta
        producto.stockActual += cantidad; 
        await isar.productos.put(producto);

        final movimiento = MovimientoInventario()
          ..fecha = DateTime.now()
          ..cantidad = cantidad // Cantidad positiva
          ..tipoMovimiento = 'Recepcion Envase' // Tipo específico RF3.4
          ..producto.value = producto
          ..usuario.value = usuario;

        await isar.movimientoInventarios.put(movimiento);
        await movimiento.producto.save();
        await movimiento.usuario.save();
      });

      if (mounted) Navigator.of(context).pop();

    } catch (e) {
       debugPrint("Error saving envase reception: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar recepción: $e'), backgroundColor: AppColors.accentCta,));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recibir Envases Vacíos',
          style: TextStyle(color: AppColors.textPrimary)),
      backgroundColor: AppColors.cardBackground,
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadingError != null
             ? Center(child: Text(_loadingError!, style: TextStyle(color: AppColors.accentCta)))
             : _buildForm(),
      actions: (_isLoading || _loadingError != null)
          ? [ TextButton( onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')) ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.accentCta)),
              ),
              ElevatedButton(
                onPressed: _guardarRecepcion,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverted),
                child: const Text('Registrar Entrada'),
              ),
            ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Selector de Producto (Solo Envases)
              DropdownButtonFormField<Id>(
                initialValue: _productoSeleccionadoID,
                decoration: InputDecoration(
                  labelText: 'Seleccionar Tipo de Envase',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _envasesList.map((envase) {
                  return DropdownMenuItem<Id>(
                    value: envase.id,
                    child: Text(envase.nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _productoSeleccionadoID = value;
                  });
                },
                validator: (value) => value == null ? 'Seleccione un envase' : null,
              ),
              const SizedBox(height: 16),

              // 2. Cantidad (Solo positivos)
              TextFormField(
                controller: _cantidadController,
                decoration: InputDecoration(
                  labelText: 'Cantidad Recibida',
                  hintText: 'Ej: 10',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number, // Teclado numérico simple
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  final numero = int.tryParse(value);
                  if (numero == null) return 'Ingrese un número válido';
                  if (numero <= 0) return 'La cantidad debe ser positiva';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}