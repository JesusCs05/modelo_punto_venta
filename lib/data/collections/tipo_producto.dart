// Archivo: lib/data/collections/tipo_producto.dart
import 'package:isar/isar.dart';

part 'tipo_producto.g.dart';

@collection
class TipoProducto {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String nombre; // 'Normal', 'Líquido', 'Envase'
}