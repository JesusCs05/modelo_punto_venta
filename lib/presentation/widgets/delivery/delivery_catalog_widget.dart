// ignore_for_file: use_build_context_synchronously

// Archivo: lib/presentation/widgets/delivery/delivery_catalog_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../pos/modal_confirmar_envase.dart';
import 'package:isar/isar.dart';
import '../../../main.dart';
import '../../../data/collections/producto.dart';
import '../../providers/delivery_cart_provider.dart';
import '../pos/modal_recibir_envases.dart';

class DeliveryCatalogWidget extends StatefulWidget {
  const DeliveryCatalogWidget({super.key});

  @override
  State<DeliveryCatalogWidget> createState() => _DeliveryCatalogWidgetState();
}

class _DeliveryCatalogWidgetState extends State<DeliveryCatalogWidget> {
  String _searchTerm = '';
  bool _snackShownNoProducts = false;
  bool _snackShownAllOutOfStock = false;
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _scanFocusNode = FocusNode();
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
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
    final cart = context.read<DeliveryCartProvider>();

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

    Producto? producto = isar.productos
        .filter()
        .skuEqualTo(code, caseSensitive: false)
        .findFirstSync();

    producto ??= isar.productos
        .filter()
        .skuIsNotNull()
        .skuContains(code, caseSensitive: false)
        .findFirstSync();

    if (producto != null && mounted) {
      await _onProductoSeleccionado(context, producto);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto no encontrado: $code'),
          backgroundColor: AppColors.accentCta,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildRecibirEnvasesButton(),
          const SizedBox(height: 12),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _scanController,
      focusNode: _scanFocusNode,
      decoration: InputDecoration(
        hintText: 'Escanear o buscar producto...',
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        _scanTimer?.cancel();
        _scanTimer = Timer(const Duration(milliseconds: 300), () {
          if (value.length >= 3) {
            setState(() {
              _searchTerm = value;
            });
          } else if (value.isEmpty) {
            setState(() {
              _searchTerm = '';
            });
          }
        });
      },
      onSubmitted: (value) async {
        if (value.isNotEmpty) {
          await _procesarEscaneo(value);
          _scanController.clear();
        }
      },
    );
  }

  Widget _buildRecibirEnvasesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.recycling),
        label: const Text('RECIBIR ENVASES VACÍOS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverted,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => mostrarModalRecibirEnvases(context),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<List<Producto>>(
      stream: _searchTerm.isEmpty
          ? isar.productos.where().watch(fireImmediately: true)
          : isar.productos
                .filter()
                .nombreContains(_searchTerm, caseSensitive: false)
                .or()
                .skuContains(_searchTerm, caseSensitive: false)
                .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (!_snackShownNoProducts && _searchTerm.isNotEmpty) {
            _snackShownNoProducts = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'No se encontraron productos con "$_searchTerm"',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          }
          return const Center(child: Text('No hay productos disponibles'));
        }

        _snackShownNoProducts = false;

        final productos = snapshot.data!;
        final productosConStock = productos
            .where((p) => p.stockActual > 0)
            .toList();

        if (productosConStock.isEmpty && !_snackShownAllOutOfStock) {
          _snackShownAllOutOfStock = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos los productos están agotados'),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppColors.accentCta,
                ),
              );
            }
          });
        } else if (productosConStock.isNotEmpty) {
          _snackShownAllOutOfStock = false;
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index];
            return _ProductCard(
              producto: producto,
              onTap: () => _onProductoSeleccionado(context, producto),
            );
          },
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const _ProductCard({required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sinStock = producto.stockActual <= 0;

    return Card(
      color: sinStock ? Colors.grey.shade300 : AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: sinStock ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sinStock)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentCta,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AGOTADO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Icon(
                Icons.local_drink,
                size: 48,
                color: sinStock ? Colors.grey : AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                producto.nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: sinStock
                      ? Colors.grey.shade600
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sin precio',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (!sinStock) ...[
                const SizedBox(height: 4),
                Text(
                  'Stock: ${producto.stockActual}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
