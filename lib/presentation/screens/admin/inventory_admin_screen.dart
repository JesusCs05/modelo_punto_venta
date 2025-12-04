// Archivo: lib/presentation/screens/admin/inventory_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../main.dart';
import '../../../data/collections/movimiento_inventario.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'inventory_movement_cart_screen.dart';

class InventoryAdminScreen extends StatefulWidget {
  const InventoryAdminScreen({super.key});

  @override
  State<InventoryAdminScreen> createState() => _InventoryAdminScreenState();
}

class _InventoryAdminScreenState extends State<InventoryAdminScreen> {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Paginación
  static const int _pageSize = 50;
  int _currentPage = 0;

  // Filtros
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _tipoMovimientoFiltro;
  String _busqueda = '';

  // Controllers
  final TextEditingController _busquedaController = TextEditingController();

  List<MovimientoInventario> _movimientos = [];
  bool _isLoading = false;
  int _totalMovimientos = 0;

  @override
  void initState() {
    super.initState();
    _cargarMovimientos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarMovimientos() async {
    setState(() => _isLoading = true);

    try {
      // Obtener todos los movimientos y filtrar manualmente
      var allMovimientos = await isar.movimientoInventarios
          .where()
          .sortByFechaDesc()
          .findAll();

      // Aplicar filtros
      var resultados = allMovimientos.where((mov) {
        // Filtro de fecha inicio
        if (_fechaInicio != null && mov.fecha.isBefore(_fechaInicio!)) {
          return false;
        }

        // Filtro de fecha fin
        if (_fechaFin != null &&
            mov.fecha.isAfter(_fechaFin!.add(const Duration(days: 1)))) {
          return false;
        }

        // Filtro de tipo
        if (_tipoMovimientoFiltro != null &&
            _tipoMovimientoFiltro!.isNotEmpty &&
            mov.tipoMovimiento != _tipoMovimientoFiltro) {
          return false;
        }

        // Búsqueda por texto
        if (_busqueda.isNotEmpty) {
          mov.producto.loadSync();
          final nombreProducto = mov.producto.value?.nombre.toLowerCase() ?? '';
          final tipoMov = mov.tipoMovimiento.toLowerCase();
          final busquedaLower = _busqueda.toLowerCase();

          if (!nombreProducto.contains(busquedaLower) &&
              !tipoMov.contains(busquedaLower)) {
            return false;
          }
        }

        return true;
      }).toList();

      _totalMovimientos = resultados.length;

      // Paginar resultados
      final startIndex = _currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, resultados.length);
      _movimientos = resultados.sublist(
        startIndex.clamp(0, resultados.length),
        endIndex,
      );

      // Cargar links
      for (var mov in _movimientos) {
        await mov.producto.load();
        await mov.usuario.load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar movimientos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _siguientePagina() {
    if ((_currentPage + 1) * _pageSize < _totalMovimientos) {
      setState(() => _currentPage++);
      _cargarMovimientos();
    }
  }

  void _paginaAnterior() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _cargarMovimientos();
    }
  }

  void _aplicarFiltros() {
    setState(() => _currentPage = 0);
    _cargarMovimientos();
  }

  void _limpiarFiltros() {
    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
      _tipoMovimientoFiltro = null;
      _busqueda = '';
      _busquedaController.clear();
      _currentPage = 0;
    });
    _cargarMovimientos();
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fechaInicio = fecha);
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fechaFin = fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginaActual = _currentPage + 1;
    final totalPaginas = (_totalMovimientos / _pageSize).ceil();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botones de Acción (sin cambios lógicos, llaman al modal refactorizado)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const InventoryMovementCartScreen(
                            tipoMovimiento: 'Compra',
                          ),
                        ),
                      )
                      .then((_) => _cargarMovimientos());
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Registrar Entrada (Compra)'),
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
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const InventoryMovementCartScreen(
                            tipoMovimiento: 'Ajuste',
                          ),
                        ),
                      )
                      .then((_) => _cargarMovimientos());
                },
                icon: const Icon(Icons.sync_alt),
                label: const Text('Registrar Ajuste (Merma/Conteo)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textInverted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Título y filtros compactos en la misma línea
          Row(
            children: [
              const Text(
                'Kardex',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 24),
              // Búsqueda compacta
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto o tipo...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _busqueda.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _busquedaController.clear();
                                setState(() => _busqueda = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() => _busqueda = value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Tipo de movimiento compacto
              SizedBox(
                width: 180,
                height: 40,
                child: DropdownButtonFormField<String>(
                  initialValue: _tipoMovimientoFiltro,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: const Text('Tipo', style: TextStyle(fontSize: 14)),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'Venta', child: Text('Venta')),
                    DropdownMenuItem(
                      value: 'Venta Domicilio',
                      child: Text('V. Domicilio'),
                    ),
                    DropdownMenuItem(value: 'Compra', child: Text('Compra')),
                    DropdownMenuItem(value: 'Ajuste', child: Text('Ajuste')),
                    DropdownMenuItem(
                      value: 'Recepcion Envase',
                      child: Text('Rec. Envase'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _tipoMovimientoFiltro = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Fecha inicio
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: _seleccionarFechaInicio,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _fechaInicio == null
                        ? 'Desde'
                        : DateFormat('dd/MM').format(_fechaInicio!),
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Fecha fin
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: _seleccionarFechaFin,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _fechaFin == null
                        ? 'Hasta'
                        : DateFormat('dd/MM').format(_fechaFin!),
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón aplicar
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: _aplicarFiltros,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filtrar', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverted,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón limpiar
              SizedBox(
                height: 40,
                child: IconButton(
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Limpiar filtros',
                  style: IconButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Información de paginación compacta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_movimientos.length} de $_totalMovimientos movimientos',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              if (totalPaginas > 1)
                Text(
                  'Página $paginaActual de $totalPaginas',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Tabla de Movimientos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _movimientos.isEmpty
                ? const Center(
                    child: Text(
                      'No hay movimientos registrados.',
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
                    child: _buildMovimientosTable(),
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
                    onPressed:
                        (_currentPage + 1) * _pageSize < _totalMovimientos
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

  Widget _buildMovimientosTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            width: constraints.maxWidth,
            child: DataTable(
              columnSpacing: constraints.maxWidth * 0.05,
              // FIX: Usar MaterialStateProperty en lugar de WidgetStateProperty
              headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                (states) => AppColors.primary.withAlpha(26),
              ), // ~10% alpha
              columns: const [
                DataColumn(
                  label: Text(
                    'Fecha y Hora',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Producto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tipo Mov.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ), // Abreviado
                DataColumn(
                  label: Text(
                    'Cantidad',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Usuario',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: _movimientos.map((movimiento) {
                // Acceder a datos de links (ya cargados en el builder)
                final productoNombre =
                    movimiento.producto.value?.nombre ?? 'N/A';
                final usuarioNombre = movimiento.usuario.value?.nombre ?? 'N/A';

                final bool isEntrada = movimiento.cantidad > 0;
                final Color colorCantidad = isEntrada
                    ? AppColors.primary
                    : AppColors.accentCta;

                return DataRow(
                  cells: [
                    DataCell(
                      Text(dateFormat.format(movimiento.fecha.toLocal())),
                    ),
                    DataCell(Text(productoNombre)),
                    DataCell(Text(movimiento.tipoMovimiento)),
                    DataCell(
                      Text(
                        (isEntrada ? '+' : '') + movimiento.cantidad.toString(),
                        style: TextStyle(
                          color: colorCantidad,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(Text(usuarioNombre)),
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
