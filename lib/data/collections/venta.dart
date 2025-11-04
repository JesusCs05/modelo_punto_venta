// Archivo: lib/data/collections/venta.dart
import 'package:isar/isar.dart';
import 'usuario.dart';
import 'venta_detalle.dart';

part 'venta.g.dart';

@collection
class Venta {
  Id id = Isar.autoIncrement;

  late DateTime fechaHora;
  late String metodoPago; // 'Efectivo', 'Tarjeta'
  late double total;

  String? referenciaTarjeta; // Opcional, para pagos con tarjeta

  // Link to the User who made the sale
  final usuario = IsarLink<Usuario>();

  // Backlink to VentaDetalles
  @Backlink(to: "venta")
  final detalles = IsarLinks<VentaDetalle>();
}