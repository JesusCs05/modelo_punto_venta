// Archivo: lib/presentation/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart'; // Importa el modelo (ahora simplificado)
import '../../main.dart';
import '../../data/collections/producto.dart';
import '../../data/collections/venta.dart';
import '../../data/collections/venta_detalle.dart';
import '../../data/collections/movimiento_inventario.dart';
import '../../data/collections/usuario.dart';
import 'auth_provider.dart';

class CartProvider with ChangeNotifier {
  final AuthProvider authProvider;
  CartProvider({required this.authProvider});

  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  // --- INICIO DE LA MODIFICACIÓN (Paso 3) ---

  /// Calcula el subtotal para UN item del carrito, APLICANDO la lógica de promoción.
  double getSubtotalForItem(CartItem item) {
    final producto = item.producto;
    final cantidad = item.cantidad;
    double subtotal = 0.0;

    // Obtenemos los datos de la promoción del producto
    final promoCant = producto.promoCantidadMinima;
    final promoPrecio = producto.promoPrecioEspecial;

    // Verificamos si la promoción es válida y si el cliente compró la cantidad mínima
    if (promoCant != null &&
        promoPrecio != null &&
        promoCant > 0 &&
        cantidad >= promoCant) {
      // Lógica de "7 items" (ej: promo de 6-pack)

      // 1. ¿Cuántos items alcanzan el precio de promoción?
      // (cantidad ~/ promoCant) -> División entera. (7 ~/ 6) = 1 (compró 1 six-pack)
      // (1 * promoCant) = 6. (Seis items van a precio de promo)
      int cantEnPromo = (cantidad ~/ promoCant) * promoCant;

      // 2. ¿Cuántos items "sobran" y van a precio normal?
      // (cantidad % promoCant) -> Módulo. (7 % 6) = 1 (Un item sobra)
      int cantNormal = cantidad % promoCant;

      // 3. Calcular el subtotal
      subtotal += (cantEnPromo * promoPrecio); // 6 * $30.00
      subtotal += (cantNormal * producto.precioVenta); // 1 * $35.00
    } else {
      // No hay promoción o no alcanzó la cantidad mínima.
      // Todos los items van a precio normal (menudeo).
      subtotal = cantidad * producto.precioVenta;
    }

    return subtotal;
  }

  /// El 'get total' ahora usa la nueva lógica para sumar los subtotales
  double get total {
    double grandTotal = 0.0;
    for (final item in _items) {
      // Llama a nuestra nueva función para cada item
      grandTotal += getSubtotalForItem(item);
    }
    return grandTotal;
  }
  // --- FIN DE LA MODIFICACIÓN ---

  // --- (El resto del archivo no cambia) ---

  List<CartItem> _lastSaleItems = [];
  double _lastSaleTotal = 0.0;
  String _lastSalePaymentMethod = '';
  Usuario? _lastSaleUser;

  List<CartItem> get lastSaleItems => _lastSaleItems;
  double get lastSaleTotal => _lastSaleTotal;
  String get lastSalePaymentMethod => _lastSalePaymentMethod;
  Usuario? get lastSaleUser => _lastSaleUser;

  Future<void> addProduct(Producto producto, {bool withEnvase = false}) async {
    if (withEnvase) {
      await producto.envaseAsociado.load();
      final envase = producto.envaseAsociado.value;
      if (envase != null) {
        _addOrUpdate(envase);
      }
    }
    _addOrUpdate(producto);
    notifyListeners();
  }

  void _addOrUpdate(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index != -1) {
      _items[index].cantidad++;
    } else {
      _items.add(CartItem(producto: producto));
    }
  }

  /// Elimina un producto por su instancia (si existe en el carrito).
  void removeProduct(Producto producto) {
    _items.removeWhere((item) => item.producto.id == producto.id);
    notifyListeners();
  }

  /// Establece la cantidad exacta para un producto. Si la cantidad es <= 0 se elimina.
  /// Devuelve true si la operación fue exitosa, false si excede el stock disponible.
  bool setQuantity(Producto producto, int cantidad) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index == -1) return false;
    if (cantidad <= 0) {
      _items.removeAt(index);
      notifyListeners();
      return true;
    }

    // Validación de stock
    final disponible = producto.stockActual;
    if (cantidad > disponible) {
      return false;
    }

    _items[index].cantidad = cantidad;
    notifyListeners();
    return true;
  }

  /// Incrementa la cantidad del producto en 1. Si no existe lo agrega.
  /// Devuelve true si se pudo incrementar (no excede stock), false si no hay suficiente stock.
  bool incrementQuantity(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index != -1) {
      final current = _items[index];
      final disponible = producto.stockActual;
      if (current.cantidad + 1 > disponible) return false;
      current.cantidad++;
    } else {
      // Agregar con cantidad 1 sólo si hay stock
      if (producto.stockActual <= 0) return false;
      _items.add(CartItem(producto: producto));
    }
    notifyListeners();
    return true;
  }

  /// Decrementa la cantidad del producto en 1. Si llega a 0 lo elimina.
  /// Devuelve true si la operación se realizó.
  bool decrementQuantity(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index == -1) return false;
    final current = _items[index];
    if (current.cantidad <= 1) {
      _items.removeAt(index);
    } else {
      current.cantidad--;
    }
    notifyListeners();
    return true;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> finalizarVenta(
    String metodoPago,
    String? referenciaTarjeta,
  ) async {
    final int? usuarioID = authProvider.currentUserId;
    if (usuarioID == null) {
      throw Exception('Usuario no logueado. No se puede registrar la venta.');
    }
    if (_items.isEmpty) return;

    // Guardar copia de los datos (AHORA usa el 'get total' recalculado)
    _lastSaleItems = List.from(_items);
    _lastSaleTotal = total; // <<< Llama al 'get total' con la nueva lógica
    _lastSalePaymentMethod = metodoPago;
    _lastSaleUser = authProvider.currentUser;

    try {
      await isar.writeTxn(() async {
        final usuarioActual = await isar.usuarios.get(usuarioID);
        if (usuarioActual == null) {
          throw Exception('Usuario ID $usuarioID no encontrado.');
        }

        final nuevaVenta = Venta()
          ..fechaHora = DateTime.now()
          ..metodoPago = metodoPago
          ..total =
              total // <<< Guarda el total con la nueva lógica
          ..referenciaTarjeta = referenciaTarjeta
          ..usuario.value = usuarioActual;
        await isar.ventas.put(nuevaVenta);
        await nuevaVenta.usuario.save();

        for (final item in _items) {
          final producto = item.producto;

          // --- IMPORTANTE: Guardar el precio de venta unitario ---
          // Debemos guardar el precio PROMEDIO por unidad de esta línea de venta.
          final subtotalItem = getSubtotalForItem(item);
          final precioUnitarioPromedio = subtotalItem / item.cantidad;

          final detalle = VentaDetalle()
            ..cantidad = item.cantidad
            // Guardamos el precio unitario promedio de esta transacción
            ..precioUnitarioVenta = precioUnitarioPromedio
            ..venta.value = nuevaVenta
            ..producto.value = producto;
          await isar.ventaDetalles.put(detalle);
          await detalle.venta.save();
          await detalle.producto.save();

          final productoActual = await isar.productos.get(producto.id);
          if (productoActual != null) {
            productoActual.stockActual -= item.cantidad;
            await isar.productos.put(productoActual);
          } else {
            throw Exception('Producto ID ${producto.id} no encontrado.');
          }

          final movimiento = MovimientoInventario()
            ..fecha = DateTime.now()
            ..cantidad = -item.cantidad
            ..tipoMovimiento = 'Venta'
            ..producto.value = productoActual
            ..usuario.value = usuarioActual
            ..venta.value = nuevaVenta;
          await isar.movimientoInventarios.put(movimiento);
          await movimiento.producto.save();
          await movimiento.usuario.save();
          await movimiento.venta.save();
        }
      });

      clearCart();
    } catch (e) {
      _lastSaleItems = [];
      _lastSaleTotal = 0.0;
      _lastSalePaymentMethod = '';
      _lastSaleUser = null;
      debugPrint('Error al guardar la venta en Isar: $e');
      throw Exception('Error al registrar la venta. ${e.toString()}');
    }
  }
}
