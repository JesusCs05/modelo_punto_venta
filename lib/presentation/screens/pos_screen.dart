// Archivo: lib/presentation/screens/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/pos/catalog_widget.dart';
import '../widgets/pos/cart_widget.dart';
import '../services/window_close_service.dart';
import '../providers/cart_provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
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
          autofocus: true,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: CartWidget(key: cartWidgetKey)),
                Expanded(flex: 3, child: CatalogWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleIncrementProduct(BuildContext context) {
    cartWidgetKey.currentState?.incrementSelected();
  }

  void _handleDecrementProduct(BuildContext context) {
    cartWidgetKey.currentState?.decrementSelected();
  }

  Future<void> _handleCharge(BuildContext context) async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;
    await procesarCobroCompleto(context, cart);
  }

  void _handleCancelSale(BuildContext context) {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;
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
