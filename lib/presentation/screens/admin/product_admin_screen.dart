// Archivo: lib/presentation/screens/admin/product_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../../main.dart'; // Para acceso a 'isar'
import '../../../data/collections/producto.dart';
import '../../theme/app_colors.dart';
// Importa el modal de PRODUCTO
import '../../screens/admin/product_form_modal.dart';
// Quita los imports de admin que no se usan aquí
// import 'package:provider/provider.dart'; 
// import '../../providers/auth_provider.dart'; 
// import '../login_screen.dart';
// import 'inventory_admin_screen.dart';
// import 'reports_screen.dart';
// import 'user_admin_screen.dart';


class ProductAdminScreen extends StatelessWidget {
  const ProductAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // El stream debe ser de productos
    final productsStream = isar.productos.watchLazy();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Llama al modal de PRODUCTO
              mostrarModalFormularioProducto(context, null);
            },
            icon: const Icon(Icons.add_circle),
            label: const Text('Crear Nuevo Producto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverted,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              color: AppColors.cardBackground,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: StreamBuilder<void>(
                stream: productsStream, 
                builder: (context, snapshot) {
                  final productos = isar.productos.where().sortByNombre().findAllSync();
                  
                  if (productos.isEmpty) {
                    return const Center(
                      child: Text('No hay productos creados.',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    );
                  }

                  return _buildProductsTable(context, productos);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNCIÓN _buildProductsTable CORREGIDA ---
  Widget _buildProductsTable(BuildContext context, List<Producto> productos) {
    // ¡ERROR CORREGIDO!
    // Eliminamos el 'SingleChildScrollView' que envolvía al 'InteractiveViewer'.
    // El 'Expanded' en el método 'build' ya le da a este widget un tamaño finito.
    return InteractiveViewer(
      constrained: false, // Permite que la DataTable sea más ancha que la pantalla
      scaleEnabled: false, // Deshabilita el zoom, solo paneo horizontal
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.primary.withAlpha(26)),
        columns: const [
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('P. Venta')),
          DataColumn(label: Text('P. Costo')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: productos.map((producto) {
          // Cargar el tipo de producto
          producto.tipoProducto.loadSync();
          final tipoNombre = producto.tipoProducto.value?.nombre ?? 'N/A';

          return DataRow(
            cells: [
              DataCell(Text(producto.sku ?? 'N/A')),
              DataCell(Text(producto.nombre)),
              DataCell(Text(tipoNombre)),
              DataCell(Text('\$${producto.precioVenta.toStringAsFixed(2)}')),
              DataCell(Text('\$${producto.precioCosto.toStringAsFixed(2)}')),
              DataCell(Text(producto.stockActual.toString())),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () {
                      // CORRECCIÓN 2: Asegurarse que llama al modal de PRODUCTO
                      mostrarModalFormularioProducto(context, producto); 
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: AppColors.accentDanger),
                    onPressed: () async {
                      // (Lógica de eliminación con 'mounted' check)
                      final currentContext = context;
                      final scaffoldMessenger = ScaffoldMessenger.of(currentContext);

                      final confirmar = await showDialog<bool>(
                        context: currentContext,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirmar Eliminación'),
                          content: Text('¿Seguro que deseas eliminar "${producto.nombre}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar', style: TextStyle(color: AppColors.accentDanger))),
                          ],
                        ),
                      );

                      if (!currentContext.mounted) return;

                      if (confirmar ?? false) {
                        await isar.writeTxn(() async {
                          await isar.productos.delete(producto.id);
                        });
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Producto "${producto.nombre}" eliminado.'), backgroundColor: AppColors.primary)
                        );
                      }
                    },
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}