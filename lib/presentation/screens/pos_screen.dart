// Archivo: lib/presentation/screens/pos_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import '../theme/app_colors.dart';
import '../widgets/pos/catalog_widget.dart';
import '../widgets/pos/cart_widget.dart';
import '../widgets/pos/modal_confirmar_envase.dart';
import '../services/window_close_service.dart';
import '../providers/cart_provider.dart';
import '../../main.dart';
import '../../data/collections/producto.dart';
import 'help_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _barcode = '';
  Timer? _barcodeTimer;
  final FocusNode _screenFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Esta lógica es ESENCIAL y está CORRECTA
    WindowCloseService.posScreenActive = true;
    debugPrint('PosScreen active set to true');
    // Evitar que el sistema cierre la ventana mientras estamos en POS
    // (seteamos preventClose proactivamente para prevenir la carrera
    // entre WM_CLOSE nativo y nuestro handler Dart).
    windowManager.setPreventClose(true).catchError((e) {
      debugPrint('Failed to setPreventClose(true): $e');
    });
  }

  @override
  void dispose() {
    _barcodeTimer?.cancel();
    _screenFocusNode.dispose();
    // Esta lógica es ESENCIAL y está CORRECTA
    WindowCloseService.posScreenActive = false;
    debugPrint('PosScreen active set to false');
    // Liberar el bloqueo de cierre cuando salimos de POS
    windowManager.setPreventClose(false).catchError((e) {
      debugPrint('Failed to setPreventClose(false): $e');
    });
    super.dispose();
  }

  // --- 1. ELIMINAR EL MÉTODO _mostrarDialogoConfirmarSalida ---
  // (La lógica ahora vive en main.dart)

  void _handleBarcodeKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // Ignorar teclas especiales que son parte de atajos
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
    if (producto == null) {
      producto = isar.productos
          .filter()
          .skuIsNotNull()
          .skuContains(code.trim(), caseSensitive: false)
          .findFirstSync();
    }

    if (producto != null && mounted) {
      final cart = context.read<CartProvider>();
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
    // --- 2. ELIMINAR EL WIDGET PopScope ---
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Aumentar producto
        LogicalKeySet(LogicalKeyboardKey.equal):
            const _IncrementProductIntent(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.equal):
            const _IncrementProductIntent(), // Para el símbolo +
        LogicalKeySet(LogicalKeyboardKey.pageUp):
            const _IncrementProductIntent(),
        // Disminuir producto
        LogicalKeySet(LogicalKeyboardKey.minus):
            const _DecrementProductIntent(),
        LogicalKeySet(LogicalKeyboardKey.pageDown):
            const _DecrementProductIntent(),
        // Cobrar
        LogicalKeySet(LogicalKeyboardKey.f1): const _ChargeIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const _ChargeIntent(),
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
          _ChargeIntent: CallbackAction<_ChargeIntent>(
            onInvoke: (_) => _handleCharge(context),
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
            backgroundColor: AppColors.background,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: CartWidget(key: cartWidgetKey)),
                Expanded(flex: 3, child: CatalogWidget()),
              ],
            ),
            // Botón de ayuda pequeño en la esquina inferior derecha
            floatingActionButton: FloatingActionButton.small(
              heroTag: 'pos_help_btn',
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HelpScreen())),
              tooltip: 'Ayuda',
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverted,
              child: const Icon(Icons.help_outline),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        ),
      ),
    );
  }

  void _handleIncrementProduct(BuildContext context) {
    (cartWidgetKey.currentState as dynamic)?.incrementSelected();
  }

  void _handleDecrementProduct(BuildContext context) {
    (cartWidgetKey.currentState as dynamic)?.decrementSelected();
  }

  Future<void> _handleCharge(BuildContext context) async {
    final cart = context.read<CartProvider>();
    if (cart.total <= 0.0) return;
    await procesarCobroCompleto(context, cart);
  }

  void _handleCancelSale(BuildContext context) {
    final cart = context.read<CartProvider>();
    if (cart.total <= 0.0) return;
    cart.clearCart();
  }
}

// Intents para los atajos de teclado
class _IncrementProductIntent extends Intent {
  const _IncrementProductIntent();
}

class _DecrementProductIntent extends Intent {
  const _DecrementProductIntent();
}

class _ChargeIntent extends Intent {
  const _ChargeIntent();
}

class _CancelSaleIntent extends Intent {
  const _CancelSaleIntent();
}
