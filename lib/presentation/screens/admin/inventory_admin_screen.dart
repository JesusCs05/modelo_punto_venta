// Archivo: lib/presentation/screens/admin/inventory_admin_screen.dart
import 'package:flutter/material.dart';
// --- ISAR Imports ---
import 'package:isar/isar.dart';
import '../../../main.dart'; // Para acceso a 'isar'
// Importa las COLLECTIONS necesarias
import '../../../data/collections/movimiento_inventario.dart';
import '../../../data/collections/producto.dart'; // Necesario para filtro de link
import '../../../data/collections/usuario.dart'; // Necesario para filtro de link
// --- End ISAR Imports ---
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'inventory_movement_cart_screen.dart';

class InventoryAdminScreen extends StatefulWidget {
  const InventoryAdminScreen({super.key});

  @override
  State<InventoryAdminScreen> createState() => _InventoryAdminScreenState();
}

class _InventoryAdminScreenState extends State<InventoryAdminScreen> {
  // Estado para Paginación y Datos
  List<MovimientoInventario> _movimientos = [];
  bool _isLoading = false;
  int _totalCount = 0;
  int _currentPage = 0;
  final int _pageSize = 10;

  // Estado para Filtros
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedType; // null = Todos
  DateTimeRange? _selectedDateRange;

  // Tipos de movimiento conocidos
  final List<String> _tiposMovimiento = [
    'Compra',
    'Ajuste',
    'Venta',
    'Recepcion Envase'
  ];

  @override
  void initState() {
    super.initState();
    _fetchMovimientos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMovimientos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Construir Query base iniciando con filtro
      // Isar permite encadenar filtros si se mantiene el tipo correcto.
      // Usamos .filter() al inicio y .and() al final de cada bloque condicional.
      var q = isar.movimientoInventarios.filter();

      // Aplicar Filtro de Búsqueda (Producto o Usuario)
      if (_searchQuery.isNotEmpty) {
        q = q
            .group((g) => g
                .producto((p) =>
                    p.nombreContains(_searchQuery, caseSensitive: false))
                .or()
                .usuario((u) =>
                    u.nombreContains(_searchQuery, caseSensitive: false)))
            .and();
      }

      // Aplicar Filtro de Tipo
      if (_selectedType != null) {
        q = q.tipoMovimientoEqualTo(_selectedType!).and();
      }

      // Aplicar Filtro de Fecha
      if (_selectedDateRange != null) {
        final start = _selectedDateRange!.start;
        final end = _selectedDateRange!.end
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1)); // Final del día
        q = q.fechaBetween(start, end).and();
      }

      // Contar total (sin paginación, sobre el filtro actual)
      _totalCount = await q.count();

      // Aplicar paginación y ordenamiento
      final items = await q
          .sortByFechaDesc()
          .offset(_currentPage * _pageSize)
          .limit(_pageSize)
          .findAll();

      // Cargar links asincrónicamente
      for (final mov in items) {
        await mov.producto.load();
        await mov.usuario.load();
      }

      if (mounted) {
        setState(() {
          _movimientos = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    // Debounce simple o búsqueda al presionar enter/botón
    // Aquí actualizamos el estado y buscamos.
    // Si se desea debounce, se puede agregar Timer.
    if (_searchQuery != value.trim()) {
      setState(() {
        _searchQuery = value.trim();
        _currentPage = 0; // Reset a primera página al filtrar
      });
      _fetchMovimientos();
    }
  }

  void _onTypeChanged(String? newValue) {
    if (_selectedType != newValue) {
      setState(() {
        _selectedType = newValue;
        _currentPage = 0;
      });
      _fetchMovimientos();
    }
  }

  void _onDateRangePressed() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _selectedDateRange,
    );
    if (picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _currentPage = 0;
      });
      _fetchMovimientos();
    }
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() {
        _currentPage = page;
      });
      _fetchMovimientos();
    }
  }

  int get _totalPages => (_totalCount / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botones de Acción (Compras / Ajustes)
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
                      .then((_) => _fetchMovimientos());
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
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                      .then((_) => _fetchMovimientos());
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
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Historial de Movimientos de Inventario (Kardex)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // --- BARRA DE FILTROS Y BÚSQUEDA ---
          Card(
            elevation: 1,
            color: AppColors.cardBackground,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Buscador
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar',
                        hintText: 'Producto o Usuario...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: _onSearchChanged,
                    ),
                  ),
                  // Filtro Tipo
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Movimiento',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ..._tiposMovimiento.map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t),
                          ),
                        ),
                      ],
                      onChanged: _onTypeChanged,
                    ),
                  ),
                  // Filtro Fecha
                  OutlinedButton.icon(
                    onPressed: _onDateRangePressed,
                    icon: const Icon(Icons.date_range),
                    label: Text(_selectedDateRange == null
                        ? 'Filtrar por Fecha'
                        : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'),
                  ),
                  // Botón Limpiar Filtros
                  if (_searchQuery.isNotEmpty ||
                      _selectedType != null ||
                      _selectedDateRange != null)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _selectedType = null;
                          _selectedDateRange = null;
                          _currentPage = 0;
                        });
                        _fetchMovimientos();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpiar'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // --- TABLA DE DATOS ---
          Expanded(
            child: Card(
              color: AppColors.cardBackground,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _movimientos.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron movimientos.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: _buildMovimientosTable(
                                  _movimientos, dateFormat),
                            ),
                            // Paginación
                            _buildPaginationControls(),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientosTable(
    List<MovimientoInventario> movimientos,
    DateFormat dateFormat,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color?>(
            (states) => AppColors.primary.withAlpha(26),
          ),
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
            ),
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
          rows: movimientos.map((movimiento) {
            final productoNombre = movimiento.producto.value?.nombre ?? 'N/A';
            final usuarioNombre = movimiento.usuario.value?.nombre ?? 'N/A';

            final bool isEntrada = movimiento.cantidad > 0;
            final Color colorCantidad =
                isEntrada ? AppColors.primary : AppColors.accentCta;

            return DataRow(
              cells: [
                DataCell(Text(dateFormat.format(movimiento.fecha.toLocal()))),
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
  }

  Widget _buildPaginationControls() {
    final totalPages = _totalPages;
    if (totalPages <= 1) return const SizedBox.shrink();

    // Lógica para mostrar botones de página (ej: 1 2 3 ... 10)
    // Mostraremos máximo 5 botones numéricos
    final startPage = (_currentPage - 2).clamp(0, totalPages - 1);
    final endPage = (startPage + 4).clamp(0, totalPages - 1);
    // Ajustar start si end está al límite
    final effectiveStart = (endPage - 4).clamp(0, totalPages - 1);
    final effectiveEnd = endPage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Total: $_totalCount registros'),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          for (int i = effectiveStart; i <= effectiveEnd; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: i == _currentPage ? null : () => _goToPage(i),
                style: ElevatedButton.styleFrom(
                  backgroundColor: i == _currentPage
                      ? AppColors.primary
                      : AppColors.cardBackground,
                  foregroundColor: i == _currentPage
                      ? AppColors.textInverted
                      : AppColors.textPrimary,
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                ),
                child: Text('${i + 1}'),
              ),
            ),
          IconButton(
            onPressed: _currentPage < totalPages - 1
                ? () => _goToPage(_currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
