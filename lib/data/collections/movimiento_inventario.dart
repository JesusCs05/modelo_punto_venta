// Archivo: lib/data/collections/movimiento_inventario.dart
import 'package:isar/isar.dart';

import 'producto.dart';
import 'usuario.dart';
import 'venta.dart'; // Optional link to Venta

part 'movimiento_inventario.g.dart';

@collection
class MovimientoInventario {
  Id id = Isar.autoIncrement;

  late DateTime fecha;
  late int cantidad; // Positive for entries, Negative for exits
  late String tipoMovimiento; // 'Venta', 'Recepcion Envase', 'Compra', 'Ajuste'

  // Link to Producto
  final producto = IsarLink<Producto>();

  // Link to User who registered the movement
  final usuario = IsarLink<Usuario>();

  // Optional: Link to the Venta if it was a sale
  final venta = IsarLink<Venta>();
}