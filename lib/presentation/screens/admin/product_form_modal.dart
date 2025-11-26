// Archivo: lib/presentation/widgets/admin/product_form_modal.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../main.dart'; // Para acceso a 'isar' global
import '../../../data/collections/producto.dart';
import '../../../data/collections/tipo_producto.dart';
import '../../theme/app_colors.dart';

Future<void> mostrarModalFormularioProducto(
  BuildContext context,
  Producto? productoExistente,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return _ProductFormContenido(productoExistente: productoExistente);
    },
  );
}

class _ProductFormContenido extends StatefulWidget {
  final Producto? productoExistente;
  const _ProductFormContenido({this.productoExistente});

  bool get _esModoEdicion => productoExistente != null;

  @override
  State<_ProductFormContenido> createState() => _ProductFormContenidoState();
}

class _ProductFormContenidoState extends State<_ProductFormContenido> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _skuController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _precioCostoController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  // <<< 1. AÑADIR NUEVOS CONTROLADORES PARA PROMOCIÓN >>>
  final _promoCantidadController = TextEditingController();
  final _promoPrecioController = TextEditingController();

  List<TipoProducto> _tiposProductoList = [];
  List<Producto> _envasesDisponiblesList = [];

  Id? _tipoProductoSeleccionadoID;
  Id? _envaseAsociadoID;

  bool _isLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() { _isLoading = true; _loadingError = null; });
    try {
      final tipos = await isar.tipoProductos.where().findAll();
      final tipoEnvase = await isar.tipoProductos.filter().nombreEqualTo('Envase').findFirst();
      List<Producto> envases = [];
      if (tipoEnvase != null) {
        envases = await isar.productos.filter().tipoProducto((q) => q.idEqualTo(tipoEnvase.id)).findAll();
      }

      if (!mounted) return;

      setState(() {
        _tiposProductoList = tipos;
        _envasesDisponiblesList = envases;

        if (widget._esModoEdicion) {
          final p = widget.productoExistente!;
          _nombreController.text = p.nombre;
          _skuController.text = p.sku ?? '';
          _precioVentaController.text = p.precioVenta.toStringAsFixed(2);
          _precioCostoController.text = p.precioCosto.toStringAsFixed(2);
          _stockController.text = p.stockActual.toString();
          _imageUrlController.text = p.imageUrl ?? '';
          
          // <<< 2. PRE-LLENAR CAMPOS DE PROMOCIÓN >>>
          // Convierte 'null' a string vacío para el controlador
          _promoCantidadController.text = p.promoCantidadMinima?.toString() ?? '';
          _promoPrecioController.text = p.promoPrecioEspecial?.toStringAsFixed(2) ?? '';

          p.tipoProducto.loadSync();
          p.envaseAsociado.loadSync();
          _tipoProductoSeleccionadoID = p.tipoProducto.value?.id;
          _envaseAsociadoID = p.envaseAsociado.value?.id;
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading dropdown data: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingError = 'Error al cargar datos necesarios: $e';
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _skuController.dispose();
    _precioVentaController.dispose();
    _precioCostoController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    
    // <<< 3. AÑADIR DISPOSE DE NUEVOS CONTROLADORES >>>
    _promoCantidadController.dispose();
    _promoPrecioController.dispose();

    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final skuIngresado = _skuController.text.isEmpty ? null : _skuController.text;
      if (skuIngresado != null) {
        final productoExistente = await isar.productos.filter().skuEqualTo(skuIngresado).findFirst();
        if (productoExistente != null) {
          if (widget._esModoEdicion && widget.productoExistente!.id == productoExistente.id) {
            // No hay conflicto
          } else {
            throw Exception('El SKU "$skuIngresado" ya está en uso por "${productoExistente.nombre}".');
          }
        }
      }
      
      final tipoSeleccionado = await isar.tipoProductos.get(_tipoProductoSeleccionadoID!);
      final envaseSeleccionado = _envaseAsociadoID == null ? null : await isar.productos.get(_envaseAsociadoID!);

      // <<< 4. LEER Y PARSEAR VALORES DE PROMOCIÓN >>>
      // tryParse devuelve null si el texto está vacío o es inválido
      final int? promoCant = int.tryParse(_promoCantidadController.text);
      final double? promoPrecio = double.tryParse(_promoPrecioController.text);


      await isar.writeTxn(() async {
        final productoAGuardar = widget._esModoEdicion ? widget.productoExistente! : Producto();

        productoAGuardar
          ..nombre = _nombreController.text
          ..sku = skuIngresado
          ..precioVenta = double.tryParse(_precioVentaController.text) ?? 0.0
          ..precioCosto = double.tryParse(_precioCostoController.text) ?? 0.0
          ..stockActual = int.tryParse(_stockController.text) ?? 0
          ..imageUrl = _imageUrlController.text.isEmpty ? null : _imageUrlController.text
          ..tipoProducto.value = tipoSeleccionado
          
          // <<< 4b. GUARDAR VALORES DE PROMOCIÓN >>>
          ..promoCantidadMinima = promoCant
          ..promoPrecioEspecial = promoPrecio;

        if (tipoSeleccionado?.nombre == 'Líquido') {
          productoAGuardar.envaseAsociado.value = envaseSeleccionado;
        } else {
          productoAGuardar.envaseAsociado.value = null;
        }

        await isar.productos.put(productoAGuardar);
        await productoAGuardar.tipoProducto.save();
        await productoAGuardar.envaseAsociado.save();
      });

      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      debugPrint("Error saving product: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: AppColors.accentCta,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (AlertDialog, actions, etc. no cambian) ...
    return AlertDialog(
      title: Text(
        widget._esModoEdicion ? 'Editar Producto' : 'Crear Producto',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.cardBackground,
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadingError != null
              ? Center(
                  child: Text(
                    _loadingError!,
                    style: TextStyle(color: AppColors.accentCta),
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
                  style: TextStyle(color: AppColors.accentCta),
                ),
              ),
              ElevatedButton(
                onPressed: _guardarProducto,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverted),
                child: const Text('Guardar'),
              ),
            ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 500, 
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // Para alinear el texto de 'Promoción'
            children: [
              // Fila 1: Nombre y SKU
              Row(
                children: [
                  Expanded(flex: 3, child: _buildTextFormField(_nombreController, 'Nombre')),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildTextFormField(_skuController, 'Codigo EAN (Opcional)', isRequired: false)),
                ],
              ),
              const SizedBox(height: 16),
              // Fila 2: Tipo de Producto
              _buildTipoProductoDropdown(),
              const SizedBox(height: 16),
              // Fila 3: Envase Asociado (Condicional)
              if (_tipoProductoSeleccionadoID != null &&
                  _tiposProductoList.firstWhere((t) => t.id == _tipoProductoSeleccionadoID).nombre == 'Líquido') ...[
                _buildEnvaseAsociadoDropdown(),
                const SizedBox(height: 16),
              ],
              // Fila 4: Precios y Stock
              Row(
                children: [
                  Expanded(child: _buildTextFormField(_precioVentaController, 'P. Venta (Menudeo)', isNumeric: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextFormField(_precioCostoController, 'P. Costo', isNumeric: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextFormField(_stockController, 'Stock Inicial', isNumeric: true)),
                ],
              ),

              // <<< 5. AÑADIR NUEVOS CAMPOS A LA UI >>>
              const SizedBox(height: 16),
              const Text(
                'Promoción por Cantidad (Opcional)', 
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      _promoCantidadController, 
                      'Cant. Mínima (ej: 6)', 
                      isNumeric: true, 
                      isRequired: false
                    )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      _promoPrecioController, 
                      'Precio Promo (por unidad)', 
                      isNumeric: true, 
                      isRequired: false
                    )
                  ),
                ],
              ),
              // --- FIN MODIFICACIÓN UI ---

              const SizedBox(height: 16),
              _buildTextFormField(_imageUrlController, 'Image URL (Opcional)', isRequired: false),
            ],
          ),
        ),
      ),
    );
  }

  // Helper TextFormField (sin cambios)
  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Campo requerido';
        }
        // Validar que si un campo de promo se llena, el otro también
        if (label.contains('Cant. Mínima') && (value?.isNotEmpty ?? false) && _promoPrecioController.text.isEmpty) {
          return 'Debe fijar un precio promo';
        }
        if (label.contains('Precio Promo') && (value?.isNotEmpty ?? false) && _promoCantidadController.text.isEmpty) {
          return 'Debe fijar una cant. mínima';
        }
        // Validación numérica
        if (isNumeric && value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'Número inválido';
        }
        return null;
      },
    );
  }

  // Helper Dropdown Tipo Producto (sin cambios)
  Widget _buildTipoProductoDropdown() {
    return DropdownButtonFormField<Id>(
      initialValue: _tipoProductoSeleccionadoID,
      decoration: InputDecoration(
        labelText: 'Tipo de Producto',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: _tiposProductoList.map((tipo) {
        return DropdownMenuItem<Id>(
          value: tipo.id,
          child: Text(tipo.nombre),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _tipoProductoSeleccionadoID = value;
          final tipoNombre = value == null
              ? null
              : _tiposProductoList.firstWhere((t) => t.id == value).nombre;
          if (tipoNombre != 'Líquido') {
            _envaseAsociadoID = null;
          }
        });
      },
      validator: (value) => value == null ? 'Seleccione un rol' : null,
    );
  }

  // Helper Dropdown Envase Asociado (sin cambios)
  Widget _buildEnvaseAsociadoDropdown() {
    return DropdownButtonFormField<Id>(
      initialValue: _envaseAsociadoID,
      decoration: InputDecoration(
        labelText: 'Envase Asociado (Opcional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: [
        const DropdownMenuItem<Id>(
          value: null,
          child: Text('Ninguno', style: TextStyle(fontStyle: FontStyle.italic)),
        ),
        ..._envasesDisponiblesList.map((envase) {
          return DropdownMenuItem<Id>(
            value: envase.id,
            child: Text(envase.nombre),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _envaseAsociadoID = value;
        });
      },
    );
  }
}