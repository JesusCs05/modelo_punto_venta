// Archivo: lib/data/collections/negocio.dart
import 'package:isar/isar.dart';

part 'negocio.g.dart';

@collection
class Negocio {
  Id id = Isar.autoIncrement;

  late String nombre;
  late String razonSocial;
  late String telefono;
  late String direccion;
  late String rfc;
}
