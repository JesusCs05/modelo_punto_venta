// Archivo: lib/presentation/screens/admin/reports/top_products_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../../../main.dart'; // Para acceso a 'isar'
import '../../../../data/collections/venta.dart';
import '../../../../data/collections/producto.dart';
import '../../../theme/app_colors.dart';

// Clase auxiliar para guardar los resultados agrupados
class TopProductData {
  final Producto producto;
  int totalVendido;

  TopProductData({required this.producto, required this.totalVendido});
}

class TopProductsReport extends StatefulWidget {
  const TopProductsReport({super.key});

  @override
  State<TopProductsReport> createState() => _TopProductsReportState();
}

class _TopProductsReportState extends State<TopProductsReport> {
  // Estado para el rango de fechas
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  // Estado para los resultados
  List<TopProductData> _topProducts = [];
  bool _isLoading = false;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  /// Consulta Isar, agrupa y ordena los productos más vendidos
  Future<void> _generateReport() async {
    setState(() { _isLoading = true; });

    final endDateForQuery = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);

    // 1. Encontrar las ventas en el rango de fechas
    final ventas = await isar.ventas
        .filter()
        .fechaHoraBetween(_startDate, endDateForQuery)
        .findAll();
    
    // 2. Usar un Map para agrupar y sumar cantidades por Producto ID
    final Map<Id, TopProductData> productosSumados = {};

    for (final venta in ventas) {
      // Cargar los detalles de cada venta
      await venta.detalles.load();
      
      for (final detalle in venta.detalles) {
        // Cargar el producto de cada detalle
        await detalle.producto.load();
        final producto = detalle.producto.value;

        if (producto != null) {
          final productoId = producto.id;
          
          if (productosSumados.containsKey(productoId)) {
            // Si ya está en el mapa, solo suma la cantidad
            productosSumados[productoId]!.totalVendido += detalle.cantidad;
          } else {
            // Si es nuevo, lo añade al mapa
            productosSumados[productoId] = TopProductData(
              producto: producto,
              totalVendido: detalle.cantidad,
            );
          }
        }
      }
    }

    // 3. Convertir el mapa a una lista y ordenarla
    final sortedList = productosSumados.values.toList();
    // Ordenar de mayor a menor cantidad vendida
    sortedList.sort((a, b) => b.totalVendido.compareTo(a.totalVendido));

    setState(() {
      _topProducts = sortedList;
      _isLoading = false;
    });
  }

  // --- Funciones para seleccionar fecha (idénticas a SalesReport) ---
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
            const Divider(height: 24, thickness: 1),
            // 2. Lista de Productos
            _isLoading 
              ? const Expanded(child: Center(child: CircularProgressIndicator())) 
              : _buildTopProductsList(),
          ],
        ),
      ),
    );
  }

  // Widget para los selectores de fecha
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

  // Widget para la lista de productos
  Widget _buildTopProductsList() {
    if (_topProducts.isEmpty) {
      return const Expanded(child: Center(child: Text('No hay datos de ventas en este rango.')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _topProducts.length,
        itemBuilder: (context, index) {
          final item = _topProducts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                '#${index + 1}',
                style: const TextStyle(color: AppColors.textInverted, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(item.producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('SKU: ${item.producto.sku ?? 'N/A'}'),
            trailing: Text(
              '${item.totalVendido} Uds.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentCta),
            ),
          );
        },
      ),
    );
  }
}