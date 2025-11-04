// Archivo: lib/data/collections/producto.dart
import 'package:isar/isar.dart';
import 'tipo_producto.dart';

part 'producto.g.dart';

@collection
class Producto {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  String? sku;

  late String nombre;
  late double precioVenta;
  late double precioCosto;
  late int stockActual;

  String? imageUrl; // Enlace a la imagen del producto

  int? promoCantidadMinima; // Cantidad mínima para aplicar promoción
  double? promoPrecioEspecial; // Precio especial bajo promoción

  
  final tipoProducto = IsarLink<TipoProducto>();
  final envaseAsociado = IsarLink<Producto>();
}
