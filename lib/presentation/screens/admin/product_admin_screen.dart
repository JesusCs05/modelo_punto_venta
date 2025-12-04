// Archivo: lib/presentation/screens/admin/product_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../main.dart';
import '../../../data/collections/producto.dart';
import '../../../data/collections/tipo_producto.dart';
import '../../theme/app_colors.dart';
import '../../screens/admin/product_form_modal.dart';
import 'dart:async';

class ProductAdminScreen extends StatefulWidget {
  const ProductAdminScreen({super.key});

  @override
  State<ProductAdminScreen> createState() => _ProductAdminScreenState();
}

class _ProductAdminScreenState extends State<ProductAdminScreen> {
  static const int _pageSize = 50;
  int _currentPage = 0;
  String _busqueda = '';
  Id? _tipoProductoFiltro;
  final TextEditingController _busquedaController = TextEditingController();
  Timer? _debounceTimer;

  List<Producto> _productos = [];
  List<TipoProducto> _tiposProducto = [];
  bool _isLoading = false;
  int _totalProductos = 0;

  @override
  void initState() {
    super.initState();
    _cargarTiposProducto();
    _cargarProductos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarTiposProducto() async {
    try {
      _tiposProducto = await isar.tipoProductos
          .where()
          .sortByNombre()
          .findAll();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar tipos: $e')));
      }
    }
  }

  Future<void> _cargarProductos() async {
    setState(() => _isLoading = true);

    try {
      var allProductos = await isar.productos.where().sortByNombre().findAll();

      // Filtrar por tipo de producto
      if (_tipoProductoFiltro != null) {
        allProductos = allProductos.where((p) {
          p.tipoProducto.loadSync();
          return p.tipoProducto.value?.id == _tipoProductoFiltro;
        }).toList();
      }

      // Filtrar por búsqueda
      if (_busqueda.isNotEmpty) {
        allProductos = allProductos.where((p) {
          final nombreMatch = p.nombre.toLowerCase().contains(
            _busqueda.toLowerCase(),
          );
          final skuMatch = (p.sku ?? '').toLowerCase().contains(
            _busqueda.toLowerCase(),
          );
          return nombreMatch || skuMatch;
        }).toList();
      }

      _totalProductos = allProductos.length;

      // Paginar
      final startIndex = _currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, allProductos.length);
      _productos = allProductos.sublist(
        startIndex.clamp(0, allProductos.length),
        endIndex,
      );

      // Cargar tipos
      for (var producto in _productos) {
        await producto.tipoProducto.load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _siguientePagina() {
    if ((_currentPage + 1) * _pageSize < _totalProductos) {
      setState(() => _currentPage++);
      _cargarProductos();
    }
  }

  void _paginaAnterior() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _cargarProductos();
    }
  }

  void _onBusquedaChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _busqueda = value;
        _currentPage = 0;
      });
      _cargarProductos();
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _busqueda = '';
      _tipoProductoFiltro = null;
      _busquedaController.clear();
      _currentPage = 0;
    });
    _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    final paginaActual = _currentPage + 1;
    final totalPaginas = (_totalProductos / _pageSize).ceil();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón crear y búsqueda
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  mostrarModalFormularioProducto(
                    context,
                    null,
                  ).then((_) => _cargarProductos());
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('Crear Nuevo Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o SKU...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _limpiarFiltros,
                          )
                        : null,
                  ),
                  onChanged: _onBusquedaChanged,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<Id?>(
                  initialValue: _tipoProductoFiltro,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Producto',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<Id?>(
                      value: null,
                      child: Text('Todos los tipos'),
                    ),
                    ..._tiposProducto.map(
                      (tipo) => DropdownMenuItem<Id?>(
                        value: tipo.id,
                        child: Text(tipo.nombre),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoProductoFiltro = value;
                      _currentPage = 0;
                    });
                    _cargarProductos();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _limpiarFiltros,
                icon: const Icon(Icons.clear_all),
                tooltip: 'Limpiar filtros',
                style: IconButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Información de paginación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mostrando ${_productos.length} de $_totalProductos productos',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              if (totalPaginas > 1)
                Text(
                  'Página $paginaActual de $totalPaginas',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Tabla de productos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _productos.isEmpty
                ? const Center(
                    child: Text(
                      'No hay productos creados.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Card(
                    color: AppColors.cardBackground,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildProductsTable(context),
                  ),
          ),

          // Controles de paginación
          if (totalPaginas > 1)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 ? _paginaAnterior : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Página anterior',
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Página $paginaActual de $totalPaginas',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: (_currentPage + 1) * _pageSize < _totalProductos
                        ? _siguientePagina
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Página siguiente',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(
                AppColors.primary.withAlpha(26),
              ),
              columns: const [
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('P. Venta')),
                DataColumn(label: Text('P. Costo')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: _productos.map((producto) {
                // Cargar el tipo de producto
                producto.tipoProducto.loadSync();
                final tipoNombre = producto.tipoProducto.value?.nombre ?? 'N/A';

                return DataRow(
                  cells: [
                    DataCell(Text(producto.sku ?? 'N/A')),
                    DataCell(Text(producto.nombre)),
                    DataCell(Text(tipoNombre)),
                    DataCell(
                      Text('\$${producto.precioVenta.toStringAsFixed(2)}'),
                    ),
                    DataCell(
                      Text('\$${producto.precioCosto.toStringAsFixed(2)}'),
                    ),
                    DataCell(Text(producto.stockActual.toString())),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              mostrarModalFormularioProducto(
                                context,
                                producto,
                              ).then((_) => _cargarProductos());
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: AppColors.accentCta,
                            ),
                            onPressed: () async {
                              final currentContext = context;
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                currentContext,
                              );

                              final confirmar = await showDialog<bool>(
                                context: currentContext,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirmar Eliminación'),
                                  content: Text(
                                    '¿Seguro que deseas eliminar "${producto.nombre}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          color: AppColors.accentCta,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (!currentContext.mounted) return;

                              if (confirmar ?? false) {
                                await isar.writeTxn(() async {
                                  await isar.productos.delete(producto.id);
                                });
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Producto "${producto.nombre}" eliminado.',
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                                if (currentContext.mounted) {
                                  _cargarProductos();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
