// Archivo: lib/presentation/screens/delivery_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import '../theme/app_colors.dart';
import '../widgets/delivery/delivery_catalog_widget.dart';
import '../widgets/delivery/delivery_cart_widget.dart';
import '../widgets/pos/modal_confirmar_envase.dart';
import '../providers/delivery_cart_provider.dart';
import '../../main.dart';
import '../../data/collections/producto.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String _barcode = '';
  Timer? _barcodeTimer;
  final FocusNode _screenFocusNode = FocusNode();

  @override
  void dispose() {
    _barcodeTimer?.cancel();
    _screenFocusNode.dispose();
    super.dispose();
  }

  void _handleBarcodeKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // Ignorar teclas especiales
      if (key == LogicalKeyboardKey.escape ||
          key == LogicalKeyboardKey.f1 ||
          key == LogicalKeyboardKey.shift ||
          key == LogicalKeyboardKey.control ||
          key == LogicalKeyboardKey.alt) {
        return;
      }

      // Si es Enter, procesar el código acumulado
      if (key == LogicalKeyboardKey.enter) {
        if (_barcode.isNotEmpty) {
          _procesarCodigoBarras(_barcode);
          _barcode = '';
          _barcodeTimer?.cancel();
        }
        return;
      }

      // Acumular caracteres del código de barras
      final char = event.character;
      if (char != null && char.isNotEmpty) {
        _barcode += char;

        // Cancelar timer anterior
        _barcodeTimer?.cancel();

        // Si el código tiene longitud típica de código de barras, procesarlo automáticamente
        if (_barcode.length >= 8) {
          _barcodeTimer = Timer(const Duration(milliseconds: 300), () {
            if (_barcode.isNotEmpty) {
              _procesarCodigoBarras(_barcode);
              _barcode = '';
            }
          });
        }
      }
    }
  }

  Future<void> _procesarCodigoBarras(String code) async {
    if (code.trim().isEmpty) return;

    debugPrint('Procesando código de barras: $code');

    // Buscar producto por SKU
    Producto? producto = isar.productos
        .filter()
        .skuEqualTo(code.trim(), caseSensitive: false)
        .findFirstSync();

    // Búsqueda alternativa si no encuentra exacto
    producto ??= isar.productos
        .filter()
        .skuIsNotNull()
        .skuContains(code.trim(), caseSensitive: false)
        .findFirstSync();

    if (producto != null && mounted) {
      final cart = context.read<DeliveryCartProvider>();
      final existsInCart = cart.items.any(
        (it) => it.producto.id == producto!.id,
      );

      if (existsInCart) {
        // Incrementar cantidad si ya está en el carrito
        final ok = cart.incrementQuantity(producto);
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Stock insuficiente. Stock actual: ${producto.stockActual}',
              ),
              backgroundColor: AppColors.accentCta,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        // Agregar nuevo producto
        await producto.tipoProducto.load();
        final tipoNombre = producto.tipoProducto.value?.nombre;

        if (tipoNombre == 'Líquido') {
          if (!mounted) return;
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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto no encontrado: $code'),
          backgroundColor: AppColors.accentCta,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Aumentar producto
        LogicalKeySet(LogicalKeyboardKey.equal):
            const _IncrementProductIntent(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.equal):
            const _IncrementProductIntent(),
        LogicalKeySet(LogicalKeyboardKey.pageUp):
            const _IncrementProductIntent(),
        // Disminuir producto
        LogicalKeySet(LogicalKeyboardKey.minus):
            const _DecrementProductIntent(),
        LogicalKeySet(LogicalKeyboardKey.pageDown):
            const _DecrementProductIntent(),
        // Cancelar venta
        LogicalKeySet(LogicalKeyboardKey.escape): const _CancelSaleIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _IncrementProductIntent: CallbackAction<_IncrementProductIntent>(
            onInvoke: (_) => _handleIncrementProduct(context),
          ),
          _DecrementProductIntent: CallbackAction<_DecrementProductIntent>(
            onInvoke: (_) => _handleDecrementProduct(context),
          ),
          _CancelSaleIntent: CallbackAction<_CancelSaleIntent>(
            onInvoke: (_) => _handleCancelSale(context),
          ),
        },
        child: Focus(
          focusNode: _screenFocusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            _handleBarcodeKey(event);
            return KeyEventResult.ignored;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFFFF3E0),
            appBar: AppBar(
              title: const Text('Venta a Domicilio (Sin Precios)'),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: DeliveryCartWidget(key: deliveryCartWidgetKey),
                ),
                const Expanded(flex: 3, child: DeliveryCatalogWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleIncrementProduct(BuildContext context) {
    (deliveryCartWidgetKey.currentState as dynamic)?.incrementSelected();
  }

  void _handleDecrementProduct(BuildContext context) {
    (deliveryCartWidgetKey.currentState as dynamic)?.decrementSelected();
  }

  void _handleCancelSale(BuildContext context) {
    final cart = context.read<DeliveryCartProvider>();
    if (cart.items.isEmpty) return;
    cart.clearCart();
  }
}

// Global key para acceder al widget del carrito
final GlobalKey deliveryCartWidgetKey = GlobalKey();

// Intents para los atajos de teclado
class _IncrementProductIntent extends Intent {
  const _IncrementProductIntent();
}

class _DecrementProductIntent extends Intent {
  const _DecrementProductIntent();
}

class _CancelSaleIntent extends Intent {
  const _CancelSaleIntent();
}
