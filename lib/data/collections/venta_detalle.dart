// Archivo: lib/data/collections/venta_detalle.dart
import 'package:isar/isar.dart';
import 'venta.dart';
import 'producto.dart';

part 'venta_detalle.g.dart';

@collection
class VentaDetalle {
  Id id = Isar.autoIncrement;

  late int cantidad;
  late double precioUnitarioVenta;

  // Link back to the Venta
  final venta = IsarLink<Venta>();

  // Link to the Producto sold
  final producto = IsarLink<Producto>();
}