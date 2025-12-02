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
import '../../../services/printer_win32.dart';
// dart:convert not needed after switching to safe bytes helper
// --- FIN NUEVAS IMPORTACIONES ---

// Encode text for ESC/POS printer using a CP1252-like mapping. This preserves
// common Western European characters (accented letters, ñ, inverted
// punctuation) while replacing unsupported runes with '?'. Also normalizes
// the ellipsis to three dots.
List<int> _encodeForPrinter(String input) {
  if (input.isEmpty) return <int>[];
  var s = input.replaceAll('…', '...');

  // Small mapping for characters outside 0..255 that are common in receipts.
  const Map<int, int> extraMap = {
    0x20AC: 0x80, // Euro sign
    0x201A: 0x82,
    0x0192: 0x83,
    0x201E: 0x84,
    0x2026: 0x85,
    0x2020: 0x86,
    0x2021: 0x87,
    0x02C6: 0x88,
    0x2030: 0x89,
    0x0160: 0x8A,
    0x2039: 0x8B,
    0x0152: 0x8C,
    0x017D: 0x8E,
    0x2018: 0x91,
    0x2019: 0x92,
    0x201C: 0x93,
    0x201D: 0x94,
    0x2022: 0x95,
    0x2013: 0x96,
    0x2014: 0x97,
    0x02DC: 0x98,
    0x2122: 0x99,
    0x0161: 0x9A,
    0x203A: 0x9B,
    0x0153: 0x9C,
    0x017E: 0x9E,
    0x0178: 0x9F,
  };

  final out = <int>[];
  for (final r in s.runes) {
    if (r <= 0xFF) {
      out.add(r);
    } else if (extraMap.containsKey(r)) {
      out.add(extraMap[r]!);
    } else {
      out.add(63); // '?'
    }
  }
  return out;
}

// Función helper para manejar el proceso completo de cobro e impresión
Future<void> procesarCobroCompleto(
  BuildContext context,
  CartProvider cart,
) async {
  final currentContext = context;

  // Mostrar modal de cobro y esperar resultado
  final resultado = await mostrarModalCobro(currentContext, cart.total);

  if (!currentContext.mounted) return;

  // Si el cobro fue exitoso, preguntar por impresión
  if (resultado == CobroResultado.exitoso) {
    debugPrint('Cobro exitoso. Preguntando por ticket...');

    final imprimir = await _mostrarOpcionImprimirHelper(currentContext);

    if (!currentContext.mounted) return;

    if (imprimir ?? false) {
      await _imprimirTicketHelper(currentContext, cart);
    }
  } else {
    debugPrint('Cobro cancelado.');
  }
}

// Helper para mostrar opción de impresión
Future<bool?> _mostrarOpcionImprimirHelper(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Venta Finalizada'),
      content: const Text('¿Desea imprimir el ticket para el cliente?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('No', style: TextStyle(color: AppColors.secondary)),
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

// Helper para imprimir ticket
Future<void> _imprimirTicketHelper(
  BuildContext context,
  CartProvider cart,
) async {
  final items = cart.lastSaleItems;
  final total = cart.lastSaleTotal;
  final cajero = cart.lastSaleUser?.nombre ?? 'N/A';
  // Ensure business info is loaded from DB before printing (may be async)
  final businessProvider = context.read<BusinessProvider>();
  await businessProvider.load();
  final businessInfo = businessProvider.info;

  if (items.isEmpty) {
    debugPrint("No hay items en la última venta para imprimir.");
    return;
  }

  // Define page format for 58mm thermal roll
  const double ticketWidthMm = 58.0;
  const double marginMm = 3.0;

  // Estimate dynamic ticket height based on content:
  // base header + per-item height + footer + margins (all in mm)
  const double headerMm =
      45.0; // espacio para nombre, razón social, encabezados
  const double perItemMm = 6.5; // estimación por línea de producto
  const double footerMm = 40.0; // total, gracias, etc

  final estimatedContentMm =
      headerMm +
      (items.length * perItemMm) +
      footerMm +
      10.0; // acolchonamiento

  // Limit height to the physical roll length to avoid absurd sizes
  const double maxRollLengthMm = 3276.0;
  final ticketHeightMm = estimatedContentMm.clamp(0.0, maxRollLengthMm);

  final pageFormat = PdfPageFormat(
    ticketWidthMm * PdfPageFormat.mm,
    ticketHeightMm * PdfPageFormat.mm,
    marginAll: marginMm * PdfPageFormat.mm,
  );

  // Generate ESC/POS bytes and send directly to USB printer (Windows)
  try {
    // Build ESC/POS raw bytes manually to avoid external package conflicts.
    final List<int> bytes = [];

    // Initialize printer
    bytes.addAll([0x1B, 0x40]); // ESC @

    // Centered business name
    bytes.addAll([0x1B, 0x61, 0x01]); // ESC a 1 (center)
    bytes.addAll(_encodeForPrinter(businessInfo.nombre + '\n'));
    if (businessInfo.razonSocial.isNotEmpty) {
      bytes.addAll(_encodeForPrinter(businessInfo.razonSocial + '\n'));
    }
    if (businessInfo.telefono.isNotEmpty) {
      bytes.addAll(_encodeForPrinter('Tel: ${businessInfo.telefono}\n'));
    }
    bytes.addAll(_encodeForPrinter('Ticket de Venta\n'));
    // Separator
    bytes.addAll(_encodeForPrinter('--------------------------------\n'));

    // Items: format columns manually. 58mm paper typically ~32-34 chars per line.
    const int lineWidth = 32;
    for (final item in items) {
      final name = item.producto.nombre;
      final qty = item.cantidad.toString();
      final subtotal = NumberFormat.currency(
        locale: 'es_MX',
        symbol: '\$',
      ).format(cart.getSubtotalForItem(item));

      // Truncate name if too long
      final maxNameLen = 18;
      var displayName = name;
      if (displayName.length > maxNameLen)
        displayName = displayName.substring(0, maxNameLen - 1) + '…';

      // right align qty and subtotal
      final rightPart = qty.padLeft(3) + ' ' + subtotal.padLeft(9);
      final leftPart = displayName;
      final spaces = lineWidth - (leftPart.length + rightPart.length);
      final line =
          leftPart + (spaces > 0 ? ' ' * spaces : ' ') + rightPart + '\n';
      bytes.addAll(_encodeForPrinter(line));
    }

    bytes.addAll(_encodeForPrinter('--------------------------------\n'));
    final totalLine =
        'TOTAL: ${NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(total)}\n';
    // Bold on
    bytes.addAll([0x1B, 0x45, 0x01]);
    bytes.addAll(_encodeForPrinter(totalLine));
    // Bold off
    bytes.addAll([0x1B, 0x45, 0x00]);

    bytes.addAll(_encodeForPrinter('\nCajero: $cajero\n'));
    bytes.addAll(
      _encodeForPrinter(
        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}\n',
      ),
    );
    bytes.addAll(_encodeForPrinter('\nGracias por su compra!\n'));
    // Feed and cut
    bytes.addAll([0x1B, 0x64, 0x03]); // ESC d 3 (feed 3 lines)
    bytes.addAll([0x1D, 0x56, 0x00]); // GS V 0 (full cut)

    final u8 = Uint8List.fromList(bytes);
    final defaultPrinter = getDefaultPrinterName();
    debugPrint('Sending ${u8.length} bytes to printer: $defaultPrinter');
    final printed = await printRawToPrinter(
      u8,
      printerName: defaultPrinter,
    ).timeout(const Duration(seconds: 8), onTimeout: () => false);
    debugPrint('printRawToPrinter returned: $printed');
    if (!printed) {
      throw Exception('No se pudo enviar el ticket a la impresora');
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket enviado a la impresora')),
      );
    }
  } catch (e) {
    debugPrint("Error al imprimir ESC/POS: $e");
    // Fallback: generate PDF and show print dialog
    try {
      final pdfData = await _generateTicketPdfHelper(
        items,
        total,
        cajero,
        businessInfo,
        cart,
        pageFormat: pageFormat,
      );
      await Printing.layoutPdf(
        format: pageFormat,
        onLayout: (PdfPageFormat format) async => pdfData,
        name: 'Ticket_Venta_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e2) {
      debugPrint('Fallback PDF print failed: $e2');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al imprimir: ${e.toString()}'),
            backgroundColor: AppColors.accentCta,
          ),
        );
      }
    }
  }
}

// Helper para generar PDF del ticket
Future<Uint8List> _generateTicketPdfHelper(
  List<CartItem> items,
  double total,
  String cajero,
  dynamic businessInfo,
  CartProvider cart, {
  required PdfPageFormat pageFormat,
}) async {
  final pdf = pw.Document();
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                businessInfo.nombre,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (businessInfo.razonSocial.isNotEmpty)
              pw.Center(
                child: pw.Text(
                  businessInfo.razonSocial,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            if (businessInfo.telefono.isNotEmpty)
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
            pw.Text('Cajero: $cajero', style: const pw.TextStyle(fontSize: 8)),
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
                          currencyFormat.format(cart.getSubtotalForItem(item)),
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

class CartWidget extends StatefulWidget {
  const CartWidget({super.key});

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

// Clave global para acceder al estado del CartWidget desde fuera
// Se usa `GlobalKey` sin parametrizar para evitar exponer el tipo privado
final GlobalKey cartWidgetKey = GlobalKey();

class _CartWidgetState extends State<CartWidget> {
  int? _selectedIndex;

  // Exponer métodos para atajos de teclado
  void incrementSelected() => incrementSelectedProduct();
  void decrementSelected() => decrementSelectedProduct();

  // Métodos públicos para ser llamados desde atajos de teclado
  void incrementSelectedProduct() {
    final cart = context.read<CartProvider>();
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
    final cart = context.read<CartProvider>();
    if (_selectedIndex != null && _selectedIndex! < cart.items.length) {
      final item = cart.items[_selectedIndex!];
      final ok = cart.decrementQuantity(item.producto);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo disminuir la cantidad.'),
            backgroundColor: AppColors.accentCta,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        // Asegurar que el índice seleccionado sea válido
        if (cart.items.isEmpty) {
          _selectedIndex = null;
        } else if (_selectedIndex == null ||
            _selectedIndex! >= cart.items.length) {
          _selectedIndex = 0;
        }
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
              Expanded(
                child: _CartList(
                  cart: cart,
                  selectedIndex: _selectedIndex,
                  onSelectionChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
              _CartTotal(cart: cart),
              _CartActions(cart: cart, selectedIndex: _selectedIndex),
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
  final int? selectedIndex;
  final ValueChanged<int?> onSelectionChanged;
  const _CartList({
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
        // Precio unitario efectivo (puede ser promocional)
        final effectiveUnitPrice =
            cart.getSubtotalForItem(item) / item.cantidad;
        // calcular disponibilidad y si puede incrementarse
        final disponible = item.producto.stockActual;
        final puedeAumentar = item.cantidad < disponible;

        final isSelected = selectedIndex == index;
        return ListTile(
          selected: isSelected,
          selectedTileColor: AppColors.primary.withAlpha(26),
          onTap: () => onSelectionChanged(index),
          leading: SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.accentCta,
                  onPressed: () {
                    final ok = cart.decrementQuantity(item.producto);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No se pudo disminuir la cantidad.'),
                          backgroundColor: AppColors.accentCta,
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
                    final scaffold = ScaffoldMessenger.of(context);
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
                  color: AppColors.accentCta,
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
  final int? selectedIndex;
  const _CartActions({required this.cart, this.selectedIndex});

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
                      await procesarCobroCompleto(context, cart);
                    },
              // --- FIN LÓGICA DE onPressed ---
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCta,
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
            icon: Icon(Icons.logout, color: AppColors.accentCta),
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
}
