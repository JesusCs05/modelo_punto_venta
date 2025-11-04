// Archivo: lib/data/collections/turno.dart
import 'package:isar/isar.dart';
import 'usuario.dart';

part 'turno.g.dart';

@collection
class Turno {
  Id id = Isar.autoIncrement;

  late DateTime fechaInicio;
  DateTime? fechaFin;
  late double fondoInicial;
  double? totalVentasEfectivo;
  double? totalContadoEfectivo;
  double? diferencia;

  // Link to the User (Cajero)
  final usuario = IsarLink<Usuario>();
}