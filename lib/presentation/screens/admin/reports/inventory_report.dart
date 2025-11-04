// Archivo: lib/presentation/screens/admin/reports/inventory_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../../../../main.dart'; // Para acceso a 'isar'
import '../../../../data/collections/producto.dart';
import '../../../theme/app_colors.dart';

class InventoryReport extends StatelessWidget {
  const InventoryReport({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    
    // Usamos un StreamBuilder para que el reporte se actualice en tiempo real
    // si el stock cambia (ej. por una venta o un ajuste).
    final productsStream = isar.productos.watchLazy();

    return Card(
      color: AppColors.cardBackground,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<void>(
          stream: productsStream,
          builder: (context, snapshot) {
            // Hacemos la consulta dentro del builder
            final productos = isar.productos.where().findAllSync();

            if (productos.isEmpty) {
              return const Center(child: Text('No hay productos para mostrar.'));
            }

            // --- Cálculos de Valorización ---
            double valorTotalCosto = 0.0;
            double valorTotalVenta = 0.0;
            for (final producto in productos) {
              valorTotalCosto += (producto.precioCosto * producto.stockActual);
              valorTotalVenta += (producto.precioVenta * producto.stockActual);
            }
            // --- Fin Cálculos ---

            return Column(
              children: [
                // 1. Totales
                _buildSummary(currencyFormat, valorTotalCosto, valorTotalVenta),
                const Divider(height: 24, thickness: 1),
                // 2. Tabla Detallada
                _buildInventoryTable(productos, currencyFormat),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget para los recuadros de totales
  Widget _buildSummary(NumberFormat currencyFormat, double totalCosto, double totalVenta) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryCard('Valor Total del Inventario (Costo)', 
                          currencyFormat.format(totalCosto), 
                          AppColors.accentDanger),
        _buildSummaryCard('Valor Total del Inventario (Venta)', 
                          currencyFormat.format(totalVenta), 
                          AppColors.primary),
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

  // Widget para la tabla de inventario detallado
  Widget _buildInventoryTable(List<Producto> productos, NumberFormat currencyFormat) {
    return Expanded(
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primary.withAlpha(26)),
          columns: const [
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Producto')),
            DataColumn(label: Text('Stock Actual'), numeric: true),
            DataColumn(label: Text('P. Costo'), numeric: true),
            DataColumn(label: Text('Valor Costo'), numeric: true),
            DataColumn(label: Text('P. Venta'), numeric: true),
            DataColumn(label: Text('Valor Venta'), numeric: true),
          ],
          rows: productos.map((producto) {
            final valorCosto = producto.precioCosto * producto.stockActual;
            final valorVenta = producto.precioVenta * producto.stockActual;
            
            return DataRow(cells: [
              DataCell(Text(producto.sku ?? 'N/A')),
              DataCell(Text(producto.nombre)),
              DataCell(Text(producto.stockActual.toString(), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              DataCell(Text(currencyFormat.format(producto.precioCosto))),
              DataCell(Text(currencyFormat.format(valorCosto), 
                        style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(currencyFormat.format(producto.precioVenta))),
              DataCell(Text(currencyFormat.format(valorVenta), 
                        style: const TextStyle(fontWeight: FontWeight.bold))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}