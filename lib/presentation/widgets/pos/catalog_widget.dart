// Archivo: lib/presentation/widgets/pos/catalog_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'modal_confirmar_envase.dart';
import 'package:isar/isar.dart';
import '../../../main.dart';
import '../../../data/collections/producto.dart';
import '../../providers/cart_provider.dart';
import 'modal_recibir_envases.dart';

class CatalogWidget extends StatefulWidget {
  const CatalogWidget({super.key});

  @override
  State<CatalogWidget> createState() => _CatalogWidgetState();
}

class _CatalogWidgetState extends State<CatalogWidget> {
  String _searchTerm = '';

  void _onProductoSeleccionado(BuildContext context, Producto producto) async {
    final cart = context.read<CartProvider>();
    final currentContext = context;

    await producto.tipoProducto.load();
    final tipoNombre = producto.tipoProducto.value?.nombre;

    if (tipoNombre == 'Líquido') {
      final resultado = await mostrarModalConfirmarEnvase(
        currentContext,
        producto.nombre,
      );

      if (!currentContext.mounted) return;

      if (resultado == ConfirmacionEnvaseResultado.siTraeEnvase) {
        cart.addProduct(producto, withEnvase: false);
      } else if (resultado == ConfirmacionEnvaseResultado.noTraeEnvase) {
        cart.addProduct(producto, withEnvase: true);
      }
    } else {
      cart.addProduct(producto, withEnvase: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsStream = isar.productos.watchLazy();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildReceiveBottlesButton(),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<void>(
              stream: productsStream,
              builder: (context, snapshot) {
                late List<Producto> productos;
                if (_searchTerm.isEmpty) {
                  productos = isar.productos
                      .where()
                      .sortByNombre()
                      .findAllSync();
                } else {
                  productos = isar.productos
                      .filter()
                      .nombreContains(_searchTerm, caseSensitive: false)
                      .or()
                      .skuContains(_searchTerm, caseSensitive: false)
                      .sortByNombre()
                      .findAllSync();
                }
                if (productos.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron productos.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2, // Relación de aspecto para el Card
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    final color = (index % 2 == 0)
                        ? AppColors.primary
                        : AppColors.secondary;

                    // --- INICIO DE LA MODIFICACIÓN ---
                    // Ahora pasamos el objeto 'Producto' completo
                    return _ProductGridItem(
                      producto: producto,
                      color: color,
                      onTap: () {
                        _onProductoSeleccionado(context, producto);
                      },
                    );
                    // --- FIN DE LA MODIFICACIÓN ---
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Escanear o buscar producto...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchTerm = value;
        });
      },
    );
  }

  Widget _buildReceiveBottlesButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.recycling, size: 28),
        label: const Text(
          'RECIBIR ENVASES VACÍOS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          mostrarModalRecibirEnvases(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverted,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// --- WIDGET _ProductGridItem ACTUALIZADO CON IMÁGENES ---

class _ProductGridItem extends StatelessWidget {
  final Producto producto; // <<< AHORA RECIBE EL PRODUCTO COMPLETO
  final Color color;
  final VoidCallback onTap;

  const _ProductGridItem({
    required this.producto,
    required this.color,
    required this.onTap,
  });

  // Función de fallback para obtener el ícono por tipo
  IconData _getIconForProduct(String tipo) {
    switch (tipo) {
      case 'Líquido':
        return Icons.local_drink;
      case 'Envase':
        return Icons.recycling;
      case 'Normal':
        return Icons.fastfood;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cargar el tipo de producto (necesario para el ícono de fallback)
    producto.tipoProducto.loadSync();
    final tipoNombre = producto.tipoProducto.value?.nombre ?? 'Normal';
    final fallbackIcon = _getIconForProduct(tipoNombre);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 2,
        color: color,
        clipBehavior: Clip.antiAlias, // <<< Importante para recortar la imagen
        child: Column( // Usamos Column para poner el texto debajo
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinea el texto abajo
          children: [
            // --- INICIO LÓGICA DE IMAGEN ---
            Expanded(
              // Verifica si la URL existe y no está vacía
              child: (producto.imageUrl != null && producto.imageUrl!.isNotEmpty)
                  
                  // OPCIÓN 1: Si hay URL, muestra Image.network
                  ? Image.network(
                      producto.imageUrl!,
                      fit: BoxFit.cover, // Cubre el espacio disponible
                      width: double.infinity,
                      
                      // Muestra un indicador de carga
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                      
                      // Muestra el ícono de fallback si la imagen falla
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(fallbackIcon, size: 40, color: AppColors.textInverted.withAlpha(150));
                      },
                    )
                  
                  // OPCIÓN 2: Si no hay URL, muestra el ícono de fallback
                  : Center(
                      child: Icon(fallbackIcon, size: 40, color: AppColors.textInverted),
                    ),
            ),
            // --- FIN LÓGICA DE IMAGEN ---
            
            // Texto del producto
            Container(
              color: Colors.black.withValues(alpha: 128), // Fondo oscuro para legibilidad
              width: double.infinity,
              padding: const EdgeInsets.all(4.0),
              child: Text(
                producto.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textInverted,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}