// Archivo: lib/presentation/screens/admin/inventory_admin_screen.dart
import 'package:flutter/material.dart';
// --- ISAR Imports ---
import 'package:isar/isar.dart';
import '../../../main.dart'; // Para acceso a 'isar'
// Importa las COLLECTIONS necesarias
import '../../../data/collections/movimiento_inventario.dart';
// --- End ISAR Imports ---
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
// import '../../screens/admin/inventory_movement_modal.dart'; // Ya no se usa el modal
import 'inventory_movement_cart_screen.dart';

class InventoryAdminScreen extends StatelessWidget {
  const InventoryAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Query reactivo ordenado y stream con retorno inicial
    final movimientosQuery = isar.movimientoInventarios
        .where()
        .sortByFechaDesc();

    final movimientosStream = movimientosQuery.watch(fireImmediately: true);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InventoryMovementCartScreen(
                        tipoMovimiento: 'Compra',
                      ),
                    ),
                  );
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InventoryMovementCartScreen(
                        tipoMovimiento: 'Ajuste',
                      ),
                    ),
                  );
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
          const SizedBox(height: 10),

          // Tabla de Movimientos con StreamBuilder de Isar
          Expanded(
            child: Card(
              color: AppColors.cardBackground,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              // 2. StreamBuilder escuchando el stream con datos tipados
              child: StreamBuilder<List<MovimientoInventario>>(
                stream: movimientosStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error cargando movimientos: ${snapshot.error}'),
                    );
                  }

                  final movimientos = snapshot.data ?? [];

                  // Cargar explícitamente los links necesarios
                  for (var mov in movimientos) {
                    mov.producto.loadSync();
                    mov.usuario.loadSync();
                  }

                  if (movimientos.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay movimientos registrados.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  // 4. Pasar lista de movimientos Isar a la tabla
                  return _buildMovimientosTable(movimientos, dateFormat);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir la tabla (adaptado para Isar MovimientoInventario)
  Widget _buildMovimientosTable(
    List<MovimientoInventario> movimientos,
    DateFormat dateFormat,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        // FIX: Usar MaterialStateProperty en lugar de WidgetStateProperty
        headingRowColor: MaterialStateProperty.resolveWith<Color?>(
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
        rows: movimientos.map((movimiento) {
          // Acceder a datos de links (ya cargados en el builder)
          final productoNombre = movimiento.producto.value?.nombre ?? 'N/A';
          final usuarioNombre = movimiento.usuario.value?.nombre ?? 'N/A';

          final bool isEntrada = movimiento.cantidad > 0;
          final Color colorCantidad = isEntrada
              ? AppColors.primary
              : AppColors.accentCta;

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
    );
  }
}
