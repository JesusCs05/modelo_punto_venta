// Archivo: lib/presentation/screens/admin/reports/sales_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas y moneda
import 'package:isar/isar.dart';
import '../../../../main.dart'; // Para acceso a 'isar'
import '../../../../data/collections/venta.dart';
import '../../../theme/app_colors.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  // Estado para el rango de fechas
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  // Estado para los resultados del reporte
  List<Venta> _ventas = [];
  double _totalVendido = 0.0;
  double _totalCosto = 0.0;
  double _gananciaTotal = 0.0;
  bool _isLoading = false;

  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    // Generar el reporte inicial para la última semana
    _generateReport();
  }

  /// Consulta Isar para obtener ventas y calcular totales
  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    // Ajustar la hora final para incluir todo el día
    final endDateForQuery = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );

    // 1. Consultar Ventas en el rango
    final ventas = await isar.ventas
        .filter()
        .fechaHoraBetween(_startDate, endDateForQuery)
        .sortByFechaHoraDesc()
        .findAll();

    double totalVendido = 0.0;
    double totalCosto = 0.0;

    // 2. Calcular totales (Iterar para sumar y cargar detalles)
    for (final venta in ventas) {
      totalVendido += venta.total;

      // Cargar detalles para calcular el costo (RF5.3 valorizado)
      await venta.detalles.load();
      for (final detalle in venta.detalles) {
        await detalle.producto.load();
        if (detalle.producto.value != null) {
          totalCosto +=
              (detalle.producto.value!.precioCosto * detalle.cantidad);
        }
      }

      // Cargar usuario para mostrar en la tabla
      await venta.usuario.load();
    }

    setState(() {
      _ventas = ventas;
      _totalVendido = totalVendido;
      _totalCosto = totalCosto;
      _gananciaTotal = totalVendido - totalCosto;
      _isLoading = false;
    });
  }

  // --- Funciones para seleccionar fecha ---
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      // (Opcional: generar reporte automáticamente al cambiar fecha, o dejarlo para el botón)
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
            // 1. Selector de Fechas y Botón
            _buildDateSelectors(),
            const SizedBox(height: 16),
            // 2. Totales
            _isLoading ? const CircularProgressIndicator() : _buildSummary(),
            const Divider(height: 24, thickness: 1),
            // 3. Tabla Detallada
            _isLoading
                ? const Expanded(
                    child: Center(child: Text("Generando reporte...")),
                  )
                : _buildDetailedTable(),
          ],
        ),
      ),
    );
  }

  // Widget para los selectores de fecha
  Widget _buildDateSelectors() {
    return Row(
      children: [
        // Fecha Inicio
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text('Desde: ${_dateFormat.format(_startDate)}'),
          onPressed: () => _selectDate(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textInverted,
          ),
        ),
        const SizedBox(width: 16),
        // Fecha Fin
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text('Hasta: ${_dateFormat.format(_endDate)}'),
          onPressed: () => _selectDate(context, false),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textInverted,
          ),
        ),
        const Spacer(),
        // Botón Generar
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('Generar Reporte'),
          onPressed: _isLoading ? null : _generateReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverted,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }

  // Widget para los recuadros de totales
  Widget _buildSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryCard(
          'Total Vendido',
          _currencyFormat.format(_totalVendido),
          AppColors.primary,
        ),
        _buildSummaryCard(
          'Total Costo',
          _currencyFormat.format(_totalCosto),
          AppColors.accentDanger,
        ),
        _buildSummaryCard(
          'Ganancia (Venta - Costo)',
          _currencyFormat.format(_gananciaTotal),
          AppColors.secondary,
        ),
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
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la tabla de ventas detalladas
  Widget _buildDetailedTable() {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primary.withAlpha(26),
          ),
          columns: const [
            DataColumn(label: Text('ID Venta')),
            DataColumn(label: Text('Fecha y Hora')),
            DataColumn(label: Text('Cajero')),
            DataColumn(label: Text('Método Pago')),
            DataColumn(label: Text('Referencia')),
            DataColumn(label: Text('Total')),
          ],
          rows: _ventas.map((venta) {
            final usuarioNombre = venta.usuario.value?.nombre ?? 'N/A';
            // Asegurarnos de incluir la referencia (puede ser null)
            final referencia = venta.referenciaTarjeta ?? '';
            return DataRow(
              cells: [
                DataCell(Text(venta.id.toString())),
                DataCell(
                  Text(
                    DateFormat(
                      'dd/MM/yy HH:mm',
                    ).format(venta.fechaHora.toLocal()),
                  ),
                ),
                DataCell(Text(usuarioNombre)),
                DataCell(Text(venta.metodoPago)),
                DataCell(Text(referencia)),
                DataCell(
                  Text(
                    _currencyFormat.format(venta.total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
