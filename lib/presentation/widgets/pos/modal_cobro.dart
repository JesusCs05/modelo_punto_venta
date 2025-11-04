// Archivo: lib/presentation/widgets/pos/modal_cobro.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/cart_item_model.dart'; // <<< Importa el CartItem

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

  // --- 1. AÑADIR CONTROLADOR PARA LA REFERENCIA ---
  final _referenciaController = TextEditingController();

  final _currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _efectivoController.addListener(_calcularCambio);
    _referenciaController.addListener(() {
      setState(() {});
    }); // Para refrescar el botón
  }

  @override
  void dispose() {
    _efectivoController.removeListener(_calcularCambio);
    _efectivoController.dispose();
    _referenciaController.dispose(); // <<< AÑADIR DISPOSE
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
      // --- 2. PASAR LA REFERENCIA ---
      // (Será null si el método es 'Efectivo' y el campo está oculto)
      final referencia = _metodoPago == 'Tarjeta'
          ? _referenciaController.text
          : null;
      await cart.finalizarVenta(_metodoPago, referencia);
      // --- FIN MODIFICACIÓN ---

      if (!currentContext.mounted) return;
      Navigator.of(currentContext).pop(CobroResultado.exitoso);

      final imprimir = await _mostrarOpcionImprimir(currentContext);
      if (!currentContext.mounted) return;

      if (imprimir ?? false) {
        await _imprimirTicket(currentContext);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.accentDanger,
        ),
      );
    }
  }

  // ... (_mostrarOpcionImprimir y lógica de PDF no cambian)...
  Future<bool?> _mostrarOpcionImprimir(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Venta Finalizada'),
        content: const Text('¿Desea imprimir el ticket para el cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverted,
            ),
            child: const Text('Sí, Imprimir'),
          ),
        ],
      ),
    );
  }

  Future<void> _imprimirTicket(BuildContext context) async {
    if (!mounted) return;
    final cart = context.read<CartProvider>();
    final items = cart.lastSaleItems;
    final total = cart.lastSaleTotal;
    final cajero = cart.lastSaleUser?.nombre ?? 'N/A';

    if (items.isEmpty) {
      debugPrint("No hay items en la última venta para imprimir.");
      return;
    }
    final Uint8List pdfData = await _generateTicketPdf(
      items,
      total,
      cajero,
      cart,
    );
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: 'Ticket_Venta_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      debugPrint("Error al imprimir: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al imprimir: $e'),
            backgroundColor: AppColors.accentDanger,
          ),
        );
      }
    }
  }

  Future<Uint8List> _generateTicketPdf(
    List<CartItem> items,
    double total,
    String cajero,
    CartProvider cart,
  ) async {
    final pdf = pw.Document();
    const double ticketWidthPoints = 80 * (72 / 25.4);
    const double marginPoints = 3 * (72 / 25.4);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          ticketWidthPoints,
          double.infinity,
          marginAll: marginPoints,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Depósito de Cerveza',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Ticket de Venta',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 8),
              ),
              pw.Text('Cajero: $cajero', style: pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Producto',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Cant.',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Subtotal',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            item.producto.nombre,
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            item.cantidad.toString(),
                            style: pw.TextStyle(fontSize: 8),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            _currencyFormat.format(
                              cart.getSubtotalForItem(item),
                            ),
                            style: pw.TextStyle(fontSize: 8),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    _currencyFormat.format(total),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  '¡Gracias por su compra!',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    // --- 3. LÓGICA PARA HABILITAR/DESHABILITAR EL BOTÓN DE PAGO ---
    bool pagoInvalidoEfectivo =
        (_metodoPago == 'Efectivo' && _pagaCon < widget.totalAPagar);
    bool pagoInvalidoTarjeta =
        (_metodoPago == 'Tarjeta' && _referenciaController.text.isEmpty);
    bool deshabilitarBoton =
        _isSaving || pagoInvalidoEfectivo || pagoInvalidoTarjeta;
    // --- FIN LÓGICA ---

    return AlertDialog(
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
            // ... (Total a Pagar, sin cambios) ...
            Text(
              'Total a Pagar:',
              style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
            ),
            Text(
              '\$${widget.totalAPagar.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.accentDanger,
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

            // --- 4. MOSTRAR CAMPO DE REFERENCIA SI ES TARJETA ---
            if (_metodoPago == 'Tarjeta')
              _buildLogicaTarjeta()
            else
              _buildLogicaEfectivo(),
            // --- FIN MODIFICACIÓN ---
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
            style: TextStyle(color: AppColors.accentDanger),
          ),
        ),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverted,
            ),
            // --- 5. USAR LA NUEVA LÓGICA DE HABILITACIÓN ---
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
    );
  }

  Widget _buildMetodoPagoBoton(String metodo, IconData icon) {
    // ... (Sin cambios) ...
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
              _referenciaController.clear(); // Limpia la referencia al cambiar
              _calcularCambio(); // Recalcula (pone cambio en 0)
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

  // --- 6. AÑADIR NUEVO HELPER PARA TARJETA ---
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
    // ... (Sin cambios) ...
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
