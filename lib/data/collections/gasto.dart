import 'package:isar/isar.dart';

part 'gasto.g.dart';

@Collection()
class Gasto {
  Id id = Isar.autoIncrement;

  late double monto;
  late String descripcion;
  late DateTime fecha;
  late int turnoId; // Relación con el turno
  late int usuarioId; // Relación con el cajero
}
