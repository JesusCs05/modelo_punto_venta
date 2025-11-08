// Archivo: lib/presentation/widgets/pos/cart_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../models/cart_item_model.dart';
import '../../theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../pos/modal_cobro.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import 'modal_cerrar_turno.dart';
import 'package:intl/intl.dart'; // <<< AÑADE ESTA LÍNEA

// --- NUEVAS IMPORTACIONES PARA PDF Y PRINTING ---
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// --- FIN NUEVAS IMPORTACIONES ---

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
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
                      'Carrito (${cart.items.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Icon(Icons.shopping_cart, color: AppColors.primary),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(child: _CartList(cart: cart)),
              _CartTotal(cart: cart),
              _CartActions(cart: cart),
            ],
          ),
        );
      },
    );
  }
}

// ... (_CartList y _CartTotal no cambian) ...
class _CartList extends StatelessWidget {
  final CartProvider cart;
  const _CartList({required this.cart});

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
        // Precio unitario efectivo (puede ser promocional)
        final effectiveUnitPrice =
            cart.getSubtotalForItem(item) / item.cantidad;
        // calcular disponibilidad y si puede incrementarse
        final disponible = item.producto.stockActual;
        final puedeAumentar = item.cantidad < disponible;

        return ListTile(
          leading: SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.accentDanger,
                  onPressed: () {
                    final ok = cart.decrementQuantity(item.producto);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No se pudo disminuir la cantidad.'),
                          backgroundColor: AppColors.accentDanger,
                        ),
                      );
                    }
                  },
                  tooltip: 'Disminuir',
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                ),
                // Cantidad editable: al tocar abre un diálogo para ingresar un número
                InkWell(
                  onTap: () async {
                    final controller = TextEditingController(
                      text: item.cantidad.toString(),
                    );
                    final result = await showDialog<int>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: const Text('Editar cantidad'),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Stock insuficiente. Stock actual: ${item.producto.stockActual}',
                            ),
                            backgroundColor: AppColors.accentDanger,
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
                  color: puedeAumentar ? AppColors.primary : Colors.grey,
                  onPressed: puedeAumentar
                      ? () {
                          final ok = cart.incrementQuantity(item.producto);
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Stock insuficiente. Stock actual: ${item.producto.stockActual}',
                                ),
                                backgroundColor: AppColors.accentDanger,
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
          subtitle: Text(
            '\$${effectiveUnitPrice.toStringAsFixed(2)} c/u',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$${cart.getSubtotalForItem(item).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: AppColors.secondary,
                onPressed: () => cart.removeProduct(item.producto),
                tooltip: 'Eliminar producto',
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 34,
                  height: 34,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartTotal extends StatelessWidget {
  final CartProvider cart;
  const _CartTotal({required this.cart});

  @override
  Widget build(BuildContext context) {
    final double total = cart.total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentDanger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- CLASE _CartActions CON LA LÓGICA DE IMPRESIÓN ---
class _CartActions extends StatelessWidget {
  final CartProvider cart;
  const _CartActions({required this.cart});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 65,
            child: ElevatedButton(
              // --- LÓGICA DE onPressed CORREGIDA ---
              onPressed: cart.items.isEmpty
                  ? null
                  : () async {
                      // 1. Guardar el context que SÍ PUEDE mostrar diálogos
                      final currentContext = context;

                      // 2. Mostrar modal de cobro y esperar resultado
                      final resultado = await mostrarModalCobro(
                        currentContext,
                        cart.total,
                      );

                      // 3. Verificar 'mounted' DESPUÉS del primer await
                      if (!currentContext.mounted) return;

                      // 4. Si el cobro fue exitoso, preguntar por impresión
                      if (resultado == CobroResultado.exitoso) {
                        debugPrint('Cobro exitoso. Preguntando por ticket...');

                        final imprimir = await _mostrarOpcionImprimir(
                          currentContext,
                        ); // Usa el context guardado

                        // 5. Verificar 'mounted' DESPUÉS del segundo await
                        if (!currentContext.mounted) return;

                        if (imprimir ?? false) {
                          await _imprimirTicket(
                            currentContext,
                          ); // Usa el context guardado
                        }
                      } else {
                        debugPrint('Cobro cancelado.');
                      }
                    },
              // --- FIN LÓGICA DE onPressed ---
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentDanger,
                foregroundColor: AppColors.textInverted,
              ),
              child: const Text(
                'COBRAR',
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
            // Cancelar Venta
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
                'Cancelar Venta',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          TextButton.icon(
            // Cerrar Turno
            icon: Icon(Icons.logout, color: AppColors.accentDanger),
            label: Text(
              'Cerrar Turno (${authProvider.currentUser?.username ?? "Cajero"})',
              style: TextStyle(color: AppColors.primary),
            ),
            onPressed: () {
              mostrarModalCerrarTurno(context);
            },
          ),
        ],
      ),
    );
  }

  // --- FUNCIONES DE IMPRESIÓN MOVIDAS AQUÍ ---

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
    // Usamos context.read() para obtener la instancia más reciente
    final cart = context.read<CartProvider>();
    final items = cart.lastSaleItems;
    final total = cart.lastSaleTotal;
    final cajero = cart.lastSaleUser?.nombre ?? 'N/A';
    final businessInfo = context.read<BusinessProvider>().info;

    if (items.isEmpty) {
      debugPrint("No hay items en la última venta para imprimir.");
      return;
    }

    final Uint8List pdfData = await _generateTicketPdf(
      items,
      total,
      cajero,
      businessInfo,
    );

    try {
      // Esta función mostrará el diálogo de impresión de Windows
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: 'Ticket_Venta_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      debugPrint("Error al imprimir: $e");
      if (context.mounted) {
        // Verificación de context
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
    dynamic businessInfo,
  ) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    const double ticketWidthPoints = 80 * (72 / 25.4);
    const double marginPoints = 3 * (72 / 25.4);

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
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
                  (businessInfo?.nombre ?? 'Mi Negocio'),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if ((businessInfo?.razonSocial ?? '').isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    businessInfo.razonSocial,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              if ((businessInfo?.telefono ?? '').isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    'Tel: ${businessInfo.telefono}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              pw.Center(
                child: pw.Text(
                  'Ticket de Venta',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Cajero: $cajero',
                style: const pw.TextStyle(fontSize: 8),
              ),
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
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            item.cantidad.toString(),
                            style: const pw.TextStyle(fontSize: 8),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            currencyFormat.format(
                              cart.getSubtotalForItem(item),
                            ),
                            style: const pw.TextStyle(fontSize: 8),
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
                    currencyFormat.format(total),
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
}
