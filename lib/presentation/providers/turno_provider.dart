// Archivo: lib/presentation/providers/turno_provider.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../main.dart'; // Para 'isar'
import '../../data/collections/turno.dart';
import '../../data/collections/usuario.dart';

class TurnoProvider with ChangeNotifier {
  Turno? _turnoActivo;

  /// Devuelve el turno activo.
  Turno? get turnoActivo => _turnoActivo;

  /// Devuelve true si hay un turno abierto.
  bool get hayTurnoAbierto => _turnoActivo != null;

  /// Devuelve el ID de Isar del turno activo.
  Id? get turnoActivoId => _turnoActivo?.id;

  /// Inicia un nuevo turno en la base de datos (RF3.1)
  Future<void> abrirTurno(Usuario usuario, double fondoInicial) async {
    try {
      final nuevoTurno = Turno()
        ..fechaInicio = DateTime.now()
        ..fondoInicial = fondoInicial
        ..usuario.value = usuario;

      // Guardar en la base de datos
      await isar.writeTxn(() async {
        await isar.turnos.put(nuevoTurno);
        await nuevoTurno.usuario.save();
      });

      // Establecer como turno activo en el provider
      _turnoActivo = nuevoTurno;
      
      debugPrint('Turno ${nuevoTurno.id} abierto para ${usuario.nombre} con fondo de $fondoInicial');
      notifyListeners();
    } catch (e) {
      debugPrint('Error al abrir turno: $e');
      throw Exception('No se pudo iniciar el turno.');
    }
  }

  /// Cierra el turno (Corte X)
  /// (Implementaremos la lógica completa de cálculo más adelante)
  Future<void> cerrarTurno({
    required double ventasEfectivo,
      required double ventasTarjeta,
      required double conteoFisicoEfectivo,
  }) async {
      
    if (_turnoActivo == null) throw Exception('No hay un turno activo para cerrar.');

    try {
      // --- Lógica de Corte X (RF3.9) ---
      final conteoEfectivo = conteoFisicoEfectivo;
      double ventasEfectivoCalculadas = 0.0; 
      
      final turnoACerrar = _turnoActivo!;
      turnoACerrar
        ..fechaFin = DateTime.now()
        ..totalVentasEfectivo = ventasEfectivoCalculadas // Total calculado
        ..totalContadoEfectivo = conteoEfectivo // Total físico
        ..diferencia = conteoEfectivo - (turnoACerrar.fondoInicial + ventasEfectivoCalculadas);

      // Guardar en la base de datos
      await isar.writeTxn(() async {
        await isar.turnos.put(turnoACerrar);
      });
      
      debugPrint('Turno ${turnoACerrar.id} cerrado. Diferencia: ${turnoACerrar.diferencia}');

      // Limpiar el estado del provider
      _turnoActivo = null;
      notifyListeners();

    } catch (e) {
      debugPrint('Error al cerrar turno: $e');
      throw Exception('No se pudo cerrar el turno.');
    }
  }
}