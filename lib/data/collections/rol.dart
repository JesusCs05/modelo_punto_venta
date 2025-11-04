// Archivo: lib/data/collections/rol.dart
import 'package:isar/isar.dart';

part 'rol.g.dart'; // File will be generated

@collection
class Rol {
  Id id = Isar.autoIncrement; // Auto increment ID

  @Index(unique: true) // Ensure names are unique
  late String nombre; // 'Administrador', 'Cajero'
}