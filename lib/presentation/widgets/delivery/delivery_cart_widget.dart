// Archivo: lib/presentation/widgets/delivery/delivery_cart_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../providers/delivery_cart_provider.dart';

class DeliveryCartWidget extends StatefulWidget {
  const DeliveryCartWidget({super.key});

  @override
  State<DeliveryCartWidget> createState() => _DeliveryCartWidgetState();
}

class _DeliveryCartWidgetState extends State<DeliveryCartWidget> {
  int? _selectedIndex;

  void incrementSelected() => incrementSelectedProduct();
  void decrementSelected() => decrementSelectedProduct();

  void incrementSelectedProduct() {
    final cart = context.read<DeliveryCartProvider>();
    if (_selectedIndex != null && _selectedIndex! < cart.items.length) {
      final item = cart.items[_selectedIndex!];
      final ok = cart.incrementQuantity(item.producto);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock insuficiente. Stock actual: ${item.producto.stockActual}',
            ),
            backgroundColor: AppColors.accentCta,
          ),
        );
      }
    }
  }

  void decrementSelectedProduct() {
    final cart = context.read<DeliveryCartProvider>();
    if (_selectedIndex != null && _selectedIndex! < cart.items.length) {
      final item = cart.items[_selectedIndex!];
      cart.decrementQuantity(item.producto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryCartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          _selectedIndex = null;
        } else if (_selectedIndex == null ||
            _selectedIndex! >= cart.items.length) {
          _selectedIndex = 0;
        }

        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pedido Domicilio (${cart.items.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Icon(Icons.delivery_dining, color: Colors.orange),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _DeliveryCartList(
                  cart: cart,
                  selectedIndex: _selectedIndex,
                  onSelectionChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
              _DeliveryCartActions(cart: cart),
            ],
          ),
        );
      },
    );
  }
}

class _DeliveryCartList extends StatelessWidget {
  final DeliveryCartProvider cart;
  final int? selectedIndex;
  final ValueChanged<int?> onSelectionChanged;

  const _DeliveryCartList({
    required this.cart,
    this.selectedIndex,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = cart.items;
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Agregue productos...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final disponible = item.producto.stockActual;
        final puedeAumentar = item.cantidad < disponible;
        final isSelected = selectedIndex == index;

        return ListTile(
          selected: isSelected,
          selectedTileColor: Colors.orange.withAlpha(51),
          onTap: () => onSelectionChanged(index),
          leading: SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.deepOrange,
                  onPressed: () => cart.decrementQuantity(item.producto),
                  tooltip: 'Disminuir',
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final controller = TextEditingController(
                      text: item.cantidad.toString(),
                    );
                    final scaffold = ScaffoldMessenger.of(context);
                    final result = await showDialog<int>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text(
                            'Editar cantidad',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          content: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r"\d+")),
                            ],
                            decoration: const InputDecoration(
                              hintText: 'Ingrese cantidad',
                              hintStyle: TextStyle(color: Colors.black54),
                            ),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(null),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final value =
                                    int.tryParse(controller.text) ?? 0;
                                Navigator.of(ctx).pop(value);
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (result != null) {
                      final ok = cart.setQuantity(item.producto, result);
                      if (!ok) {
                        scaffold.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Stock insuficiente. Stock actual: ${item.producto.stockActual}',
                            ),
                            backgroundColor: AppColors.accentCta,
                          ),
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      item.cantidad.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: puedeAumentar ? Colors.orange : Colors.grey,
                  onPressed: puedeAumentar
                      ? () {
                          final ok = cart.incrementQuantity(item.producto);
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Stock insuficiente. Stock actual: ${item.producto.stockActual}',
                                ),
                                backgroundColor: AppColors.accentCta,
                              ),
                            );
                          }
                        }
                      : null,
                  tooltip: 'Aumentar',
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            item.producto.nombre,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: const Text(
            'Sin precio',
            style: TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.secondary,
            onPressed: () => cart.removeProduct(item.producto),
            tooltip: 'Eliminar producto',
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          ),
        );
      },
    );
  }
}

class _DeliveryCartActions extends StatelessWidget {
  final DeliveryCartProvider cart;

  const _DeliveryCartActions({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'PEDIDO A DOMICILIO',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.orange,
            ),
          ),
          const Text(
            '(Sin aplicar precios)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 65,
            child: ElevatedButton(
              onPressed: cart.items.isEmpty
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Registrar Pedido'),
                          content: const Text(
                            '¿Confirmar registro de productos sin precio?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Confirmar'),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      try {
                        await cart.registrarPedidoDomicilio();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pedido a domicilio registrado'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'REGISTRAR PEDIDO',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: ElevatedButton(
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      cart.clearCart();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.textInverted,
              ),
              child: const Text(
                'Cancelar Pedido',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
