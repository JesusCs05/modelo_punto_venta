// Archivo: lib/presentation/widgets/pos/modal_cobro.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:intl/intl.dart';

enum CobroResultado { exitoso, cancelado }

Future<CobroResultado?> mostrarModalCobro(
  BuildContext context,
  double totalAPagar,
) {
  return showDialog<CobroResultado>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return _ModalCobroContenido(totalAPagar: totalAPagar);
    },
  );
}

class _ModalCobroContenido extends StatefulWidget {
  final double totalAPagar;
  const _ModalCobroContenido({required this.totalAPagar});

  @override
  State<_ModalCobroContenido> createState() => _ModalCobroContenidoState();
}

class _ModalCobroContenidoState extends State<_ModalCobroContenido> {
  String _metodoPago = 'Efectivo';
  double _pagaCon = 0.0;
  double _cambio = 0.0;
  final _efectivoController = TextEditingController();
  bool _isSaving = false;
  final _referenciaController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _efectivoController.addListener(_calcularCambio);
    _referenciaController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _efectivoController.removeListener(_calcularCambio);
    _efectivoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  void _calcularCambio() {
    setState(() {
      _pagaCon = double.tryParse(_efectivoController.text) ?? 0.0;
      if (_pagaCon > widget.totalAPagar) {
        _cambio = _pagaCon - widget.totalAPagar;
      } else {
        _cambio = 0.0;
      }
    });
  }

  Future<void> _finalizarVenta() async {
    final cart = context.read<CartProvider>();
    setState(() {
      _isSaving = true;
    });
    final currentContext = context;

    try {
      final referencia = _metodoPago == 'Tarjeta'
          ? _referenciaController.text
          : null;
      await cart.finalizarVenta(_metodoPago, referencia);

      if (!currentContext.mounted) return;
      Navigator.of(currentContext).pop(CobroResultado.exitoso);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.accentCta,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool pagoInvalidoEfectivo =
        (_metodoPago == 'Efectivo' && _pagaCon < widget.totalAPagar);
    bool pagoInvalidoTarjeta =
        (_metodoPago == 'Tarjeta' && _referenciaController.text.isEmpty);
    bool deshabilitarBoton =
        _isSaving || pagoInvalidoEfectivo || pagoInvalidoTarjeta;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): const _CancelCobroIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _CancelCobroIntent: CallbackAction<_CancelCobroIntent>(
            onInvoke: (_) {
              if (!_isSaving) {
                Navigator.of(context).pop(CobroResultado.cancelado);
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Realizar Cobro',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total a Pagar:',
              style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
            ),
            Text(
              '\$${widget.totalAPagar.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.accentCta,
              ),
            ),
            const Divider(height: 32),
            Row(
              children: [
                _buildMetodoPagoBoton('Efectivo', Icons.money),
                const SizedBox(width: 12),
                _buildMetodoPagoBoton('Tarjeta', Icons.credit_card),
              ],
            ),
            const SizedBox(height: 24),

            if (_metodoPago == 'Tarjeta')
              _buildLogicaTarjeta()
            else
              _buildLogicaEfectivo(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(CobroResultado.cancelado),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.accentCta),
          ),
        ),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverted,
            ),
            onPressed: deshabilitarBoton ? null : _finalizarVenta,
            child: _isSaving
                ? const CircularProgressIndicator(color: AppColors.textInverted)
                : const Text(
                    'Finalizar Venta',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetodoPagoBoton(String metodo, IconData icon) {
    final bool seleccionado = _metodoPago == metodo;
    return Expanded(
      child: SizedBox(
        height: 65,
        child: OutlinedButton.icon(
          icon: Icon(icon, size: 28),
          label: Text(metodo, style: const TextStyle(fontSize: 18)),
          onPressed: () {
            setState(() {
              _metodoPago = metodo;
              _efectivoController.clear();
              _referenciaController.clear();
              _calcularCambio();
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: seleccionado
                ? AppColors.primary.withAlpha(26)
                : Colors.transparent,
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: AppColors.primary,
              width: seleccionado ? 3.0 : 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogicaTarjeta() {
    return Column(
      children: [
        TextFormField(
          controller: _referenciaController,
          decoration: InputDecoration(
            labelText: 'Referencia / Autorización',
            hintText: 'Ingrese los 4 últimos dígitos o el ID',
            prefixIcon: const Icon(Icons.receipt_long),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d+'))],
        ),
        const SizedBox(height: 16),
        const Text(
          'El campo de referencia es obligatorio para pagos con tarjeta.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLogicaEfectivo() {
    return Column(
      children: [
        TextField(
          controller: _efectivoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          style: const TextStyle(fontSize: 20, color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Paga con:',
            prefixText: '\$',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Cambio:',
          style: TextStyle(fontSize: 20, color: AppColors.textPrimary),
        ),
        Text(
          _currencyFormat.format(_cambio),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// Intent para cancelar cobro con Escape
class _CancelCobroIntent extends Intent {
  const _CancelCobroIntent();
}
