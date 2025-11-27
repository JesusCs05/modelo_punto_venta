// Archivo: lib/presentation/utils/backup_utils.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import '../../data/collections/rol.dart';
import '../../data/collections/usuario.dart';
import '../../data/collections/tipo_producto.dart';
import '../../data/collections/producto.dart';
import '../../data/collections/venta.dart';
import '../../data/collections/venta_detalle.dart';
import '../../data/collections/turno.dart';
import '../../data/collections/movimiento_inventario.dart';
import '../../main.dart' as app_main;

/// Utilidades para exportar e importar la base de datos Isar.
///
/// - `exportDatabase` copia el archivo actual `posDepositoDB.isar` a una
///   carpeta seleccionada por el usuario (añade timestamp al nombre).
/// - `importDatabase` permite seleccionar un archivo `.isar` y reemplaza la
///   base de datos actual por el seleccionado. Ambos procedimientos cierran
///   y reabren la instancia global `isar`.

Future<String> _getDbPath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, 'posDepositoDB.isar');
}

Future<void> _reopenIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  // Close existing if not closed
  if (app_main.isar.isOpen) {
    try {
      await app_main.isar.close();
    } catch (_) {}
  }

  app_main.isar = await Isar.open(
    [
      RolSchema,
      UsuarioSchema,
      TipoProductoSchema,
      ProductoSchema,
      VentaSchema,
      VentaDetalleSchema,
      TurnoSchema,
      MovimientoInventarioSchema,
    ],
    directory: dir.path,
    name: 'posDepositoDB',
  );
}

/// Exporta la base de datos a una carpeta seleccionada. Devuelve la ruta de
/// destino si se completó, o lanza una excepción en caso de error.
Future<String?> exportDatabase() async {
  final dbPath = await _getDbPath();
  final dbFile = File(dbPath);
  if (!await dbFile.exists()) {
    throw Exception('Archivo de base de datos no encontrado en: $dbPath');
  }

  // Pide carpeta destino (funciona en desktop y mobile según plataforma)
  final targetDir = await FilePicker.platform.getDirectoryPath();
  if (targetDir == null) return null; // usuario canceló

  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final destPath = p.join(targetDir, 'posDepositoDB_$timestamp.isar');

  try {
    // Cerrar Isar antes de copiar
    if (app_main.isar.isOpen) await app_main.isar.close();

    await dbFile.copy(destPath);

    // Reabrir Isar
    await _reopenIsar();

    return destPath;
  } catch (e) {
    // Reabrir Isar aunque haya fallado la copia (intento de recuperación)
    try {
      await _reopenIsar();
    } catch (_) {}
    rethrow;
  }
}

/// Importa una base de datos seleccionada por el usuario, reemplazando la
/// base de datos actual. Devuelve la ruta del archivo importado.
Future<String?> importDatabase() async {
  // Seleccionar archivo .isar
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['isar'],
  );
  if (result == null || result.files.isEmpty) return null; // cancelado

  final selectedPath = result.files.first.path;
  if (selectedPath == null) return null;

  final dbPath = await _getDbPath();
  final srcFile = File(selectedPath);
  if (!await srcFile.exists()) {
    throw Exception('Archivo seleccionado no existe: $selectedPath');
  }

  try {
    if (app_main.isar.isOpen) await app_main.isar.close();

    // Reemplazar (sobrescribir) el archivo de la BD
    await srcFile.copy(dbPath);

    // Reabrir Isar
    await _reopenIsar();

    return dbPath;
  } catch (e) {
    try {
      await _reopenIsar();
    } catch (_) {}
    rethrow;
  }
}
