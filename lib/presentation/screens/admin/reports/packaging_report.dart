// Archivo: lib/presentation/screens/admin/reports/packaging_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../../../main.dart'; // Para acceso a 'isar'
import '../../../../data/collections/movimiento_inventario.dart';
import '../../../../data/collections/producto.dart';
import '../../../../data/collections/tipo_producto.dart';
import '../../../theme/app_colors.dart';

class PackagingReport extends StatefulWidget {
  const PackagingReport({super.key});

  @override
  State<PackagingReport> createState() => _PackagingReportState();
}

class _PackagingReportState extends State<PackagingReport> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  List<MovimientoInventario> _movimientos = [];
  int _totalEntradas = 0;
  int _totalSalidas = 0;
  int _balanceTotal = 0;
  bool _isLoading = false;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() { _isLoading = true; });

    // --- CORRECCIÓN 'use_build_context_synchronously' ---
    // 1. Guardar el context ANTES de cualquier await
    final currentContext = context;
    // --- Fin Corrección ---

    final endDateForQuery = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);

    final tipoEnvase = await isar.tipoProductos.filter().nombreEqualTo('Envase').findFirst();
    
    // 2. Verificar 'mounted' ANTES de usar el context guardado
    if (!currentContext.mounted) return;

    if (tipoEnvase == null) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(currentContext).showSnackBar( // 3. Usar el context guardado
        const SnackBar(content: Text('Error: No se encontró el Tipo de Producto "Envase"'), backgroundColor: AppColors.accentCta),
      );
      return;
    }
    
    final idEnvase = tipoEnvase.id;

    final movimientos = await isar.movimientoInventarios
        .filter()
        .fechaBetween(_startDate, endDateForQuery)
        .producto((q) => q.tipoProducto((t) => t.idEqualTo(idEnvase)))
        .sortByFechaDesc()
        .findAll();

    int entradas = 0;
    int salidas = 0;

    for (final mov in movimientos) {
      if (mov.cantidad > 0) {
        entradas += mov.cantidad;
      } else {
        salidas += mov.cantidad;
      }
      await mov.producto.load();
      await mov.usuario.load();
    }

    if (!mounted) return; // Verificar mounted antes de setState

    setState(() {
      _movimientos = movimientos;
      _totalEntradas = entradas;
      _totalSalidas = salidas;
      _balanceTotal = entradas + salidas;
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (!mounted) return; // Verificar mounted después del await

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDateSelectors(),
            const SizedBox(height: 16),
            _isLoading ? const CircularProgressIndicator() : _buildSummary(),
            const Divider(height: 24, thickness: 1),
            _isLoading ? const Expanded(child: Center(child: Text("Generando reporte..."))) : _buildDetailedTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectors() {
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text('Desde: ${_dateFormat.format(_startDate)}'),
          onPressed: () => _selectDate(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.textInverted),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text('Hasta: ${_dateFormat.format(_endDate)}'),
          onPressed: () => _selectDate(context, false),
           style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.textInverted),
        ),
        const Spacer(),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('Generar Reporte'),
          onPressed: _isLoading ? null : _generateReport,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.textInverted, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // --- CORRECCIÓN 'unnecessary_brace_in_string_interps' ---
        _buildSummaryCard('Envases Entrantes', '+$_totalEntradas', AppColors.primary),
        _buildSummaryCard('Envases Salientes', '$_totalSalidas', AppColors.accentCta),
        // Esta SÍ necesita llaves porque es una expresión compleja
        _buildSummaryCard('Balance Total', '${_balanceTotal > 0 ? '+' : ''}$_balanceTotal', AppColors.secondary),
        // --- Fin Corrección ---
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      color: color.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTable() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primary.withAlpha(26)),
          columns: const [
            DataColumn(label: Text('Fecha y Hora')),
            DataColumn(label: Text('Producto Envase')),
            DataColumn(label: Text('Tipo Movimiento')),
            DataColumn(label: Text('Cantidad')),
            DataColumn(label: Text('Usuario')),
          ],
          rows: _movimientos.map((mov) {
            final productoNombre = mov.producto.value?.nombre ?? 'N/A';
            final usuarioNombre = mov.usuario.value?.nombre ?? 'N/A';
            final bool isEntrada = mov.cantidad > 0;
            final Color colorCantidad = isEntrada ? AppColors.primary : AppColors.accentCta;

            return DataRow(cells: [
              DataCell(Text(DateFormat('dd/MM/yy HH:mm').format(mov.fecha.toLocal()))),
              DataCell(Text(productoNombre)),
              DataCell(Text(mov.tipoMovimiento)),
              DataCell(Text(
                (isEntrada ? '+' : '') + mov.cantidad.toString(),
                style: TextStyle(color: colorCantidad, fontWeight: FontWeight.bold),
              )),
              DataCell(Text(usuarioNombre)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}