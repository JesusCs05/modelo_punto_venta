// ignore_for_file: use_build_context_synchronously

// Archivo: lib/presentation/widgets/pos/catalog_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _snackShownNoProducts = false;
  bool _snackShownAllOutOfStock = false;
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _scanFocusNode = FocusNode();
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    // Asegurar que el campo de escaneo tenga foco al entrar a POS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scanFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _scanController.dispose();
    _scanFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onProductoSeleccionado(
    BuildContext context,
    Producto producto,
  ) async {
    final cart = context.read<CartProvider>();

    await producto.tipoProducto.load();
    final tipoNombre = producto.tipoProducto.value?.nombre;

    if (tipoNombre == 'Líquido') {
      final resultado = await mostrarModalConfirmarEnvase(
        context,
        producto.nombre,
      );

      if (!mounted) return;

      bool added = false;
      if (resultado == ConfirmacionEnvaseResultado.siTraeEnvase) {
        added = await cart.addProduct(producto, withEnvase: false);
      } else if (resultado == ConfirmacionEnvaseResultado.noTraeEnvase) {
        added = await cart.addProduct(producto, withEnvase: true);
      }

      if (!added && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock insuficiente. Stock actual: ${producto.stockActual}',
            ),
            backgroundColor: AppColors.accentCta,
          ),
        );
      }
    } else {
      final added = await cart.addProduct(producto, withEnvase: false);
      if (!added && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock insuficiente. Stock actual: ${producto.stockActual}',
            ),
            backgroundColor: AppColors.accentCta,
          ),
        );
      }
    }
  }

  Future<void> _procesarEscaneo(String code) async {
    if (code.isEmpty) return;

    // Buscar por SKU exacto primero (ignorando mayúsculas/minúsculas)
    Producto? producto = isar.productos
        .filter()
        .skuEqualTo(code, caseSensitive: false)
        .findFirstSync();

    // Si no encontró por SKU exacto, buscar con CONTAINS por si hay espacios o formato diferente
    if (producto == null) {
      producto = isar.productos
          .filter()
          .skuIsNotNull()
          .skuContains(code, caseSensitive: false)
          .findFirstSync();
    }

    // Si aún no encontró, buscar por nombre
    if (producto == null) {
      final resultados = isar.productos
          .filter()
          .nombreContains(code, caseSensitive: false)
          .findAllSync();

      // Si solo hay un resultado, usarlo automáticamente
      if (resultados.length == 1) {
        producto = resultados.first;
      }
    }

    if (producto != null && mounted) {
      // Si ya está en el carrito, incrementa cantidad y evita modal
      final cart = context.read<CartProvider>();
      final existsInCart = cart.items.any(
        (it) => it.producto.id == producto!.id,
      );
      if (existsInCart) {
        final ok = cart.incrementQuantity(producto);
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Stock insuficiente. Stock actual: ${producto.stockActual}',
              ),
              backgroundColor: AppColors.accentCta,
            ),
          );
        }
      } else {
        await _onProductoSeleccionado(context, producto);
      }
      // Limpiar y mantener el enfoque para el próximo escaneo
      _scanController.clear();
      setState(() {
        _searchTerm = '';
      });
      // Re-enfocar después del frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scanFocusNode.requestFocus();
        }
      });
    } else if (mounted) {
      // Si no coincide, dejamos el término para búsqueda manual
      // No limpiamos para que el usuario vea qué código se escaneó
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Producto no encontrado. Verifica el código SKU en la base de datos.',
            ),
            backgroundColor: AppColors.accentCta,
            duration: Duration(seconds: 2),
          ),
        );
      }
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
                  // Mostrar mensaje en UI y un SnackBar una sola vez
                  if (!_snackShownNoProducts) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se encontraron productos.'),
                          backgroundColor: AppColors.accentCta,
                        ),
                      );
                    });
                    _snackShownNoProducts = true;
                  }

                  return const Center(
                    child: Text(
                      'No se encontraron productos.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Si hay productos pero ninguno tiene stock disponible,
                // mostramos un SnackBar informando que no hay existencias.
                final anyAvailable = productos.any((p) => p.stockActual > 0);
                if (!anyAvailable && !_snackShownAllOutOfStock) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No hay productos con existencia.'),
                        backgroundColor: AppColors.accentCta,
                      ),
                    );
                  });
                  _snackShownAllOutOfStock = true;
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0, // Relación de aspecto para el Card
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
    return Focus(
      focusNode: _scanFocusNode,
      onKeyEvent: (node, event) {
        // Consumir Enter para que no active el atajo global de cobro
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: _scanController,
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

          // Cancelar timer anterior si existe
          _scanTimer?.cancel();

          // Si el texto tiene longitud de código de barras típica (8+ caracteres)
          // y no está vacío, asumir que es un escaneo y procesarlo automáticamente
          if (value.trim().length >= 8) {
            _scanTimer = Timer(const Duration(milliseconds: 300), () {
              if (mounted && _scanController.text.trim() == value.trim()) {
                _procesarEscaneo(value.trim());
              }
            });
          }
        },
        onSubmitted: (value) async {
          // Procesar el escaneo cuando se presiona Enter manualmente
          await _procesarEscaneo(value.trim());
        },
      ),
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

    final available = producto.stockActual > 0;

    return Opacity(
      opacity: available ? 1.0 : 0.45,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              if (available) {
                onTap();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Stock insuficiente. Stock actual: ${producto.stockActual}',
                    ),
                    backgroundColor: AppColors.accentCta,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Card(
              elevation: 2,
              color: color,
              clipBehavior:
                  Clip.antiAlias, // <<< Importante para recortar la imagen
              child: Column(
                // Usamos Column para poner el texto debajo
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Alinea el texto abajo
                children: [
                  // --- INICIO LÓGICA DE IMAGEN ---
                  Expanded(
                    // Verifica si la URL existe y no está vacía
                    child:
                        (producto.imageUrl != null &&
                            producto.imageUrl!.isNotEmpty)
                        // OPCIÓN 1: Si hay URL, muestra Image.network
                        ? Image.network(
                            producto.imageUrl!,
                            fit: BoxFit.cover, // Cubre el espacio disponible
                            width: double.infinity,

                            // Muestra un indicador de carga
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },

                            // Muestra el ícono de fallback si la imagen falla
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                fallbackIcon,
                                size: 40,
                                color: AppColors.textInverted.withAlpha(150),
                              );
                            },
                          )
                        // OPCIÓN 2: Si no hay URL, muestra el ícono de fallback
                        : Center(
                            child: Icon(
                              fallbackIcon,
                              size: 40,
                              color: AppColors.textInverted,
                            ),
                          ),
                  ),
                  // --- FIN LÓGICA DE IMAGEN ---

                  // Texto del producto
                  Container(
                    color: Colors.black.withAlpha(
                      128,
                    ), // Fondo oscuro para legibilidad
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
          ),
          // Overlay de 'Agotado' cuando no hay stock
          if (!available)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                color: Colors.black.withValues(alpha: 0.25),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AGOTADO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
