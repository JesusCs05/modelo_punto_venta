// Archivo: lib/data/collections/usuario.dart
import 'package:isar/isar.dart';
import 'rol.dart';

part 'usuario.g.dart';

@collection
class Usuario {
  Id id = Isar.autoIncrement;

  late String nombre;

  @Index(unique: true)
  late String username;

  late String passwordHash;

  // Link to Rol
  final rol = IsarLink<Rol>();
}