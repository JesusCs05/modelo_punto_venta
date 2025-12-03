// Archivo: lib/presentation/providers/delivery_cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../../main.dart';
import '../../data/collections/producto.dart';
import '../../data/collections/venta.dart';
import '../../data/collections/venta_detalle.dart';
import '../../data/collections/movimiento_inventario.dart';
import '../../data/collections/usuario.dart';
import 'auth_provider.dart';

class DeliveryCartProvider with ChangeNotifier {
  final AuthProvider authProvider;
  DeliveryCartProvider({required this.authProvider});

  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  /// Intenta agregar un producto al carrito de domicilio.
  Future<bool> addProduct(Producto producto, {bool withEnvase = false}) async {
    if (withEnvase) {
      await producto.envaseAsociado.load();
      final envase = producto.envaseAsociado.value;
      if (envase != null) {
        _addOrUpdate(envase);
      }
    }

    // Validar stock antes de agregar
    if (producto.stockActual <= 0) {
      return false;
    }

    _addOrUpdate(producto);
    notifyListeners();
    return true;
  }

  void _addOrUpdate(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index != -1) {
      final current = _items[index];
      if (current.cantidad + 1 > producto.stockActual) return;
      current.cantidad++;
    } else {
      if (producto.stockActual <= 0) return;
      _items.add(CartItem(producto: producto));
    }
  }

  void removeProduct(Producto producto) {
    _items.removeWhere((item) => item.producto.id == producto.id);
    notifyListeners();
  }

  bool setQuantity(Producto producto, int cantidad) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index == -1) return false;
    if (cantidad <= 0) {
      _items.removeAt(index);
      notifyListeners();
      return true;
    }

    final disponible = producto.stockActual;
    if (cantidad > disponible) {
      return false;
    }

    _items[index].cantidad = cantidad;
    notifyListeners();
    return true;
  }

  bool incrementQuantity(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index != -1) {
      final current = _items[index];
      final disponible = producto.stockActual;
      if (current.cantidad + 1 > disponible) return false;
      current.cantidad++;
    } else {
      if (producto.stockActual <= 0) return false;
      _items.add(CartItem(producto: producto));
    }
    notifyListeners();
    return true;
  }

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

  /// Registrar pedido a domicilio (sin precios)
  Future<void> registrarPedidoDomicilio() async {
    final int? usuarioID = authProvider.currentUserId;
    if (usuarioID == null) {
      throw Exception('Usuario no logueado. No se puede registrar el pedido.');
    }
    if (_items.isEmpty) return;

    try {
      await isar.writeTxn(() async {
        final usuarioActual = await isar.usuarios.get(usuarioID);
        if (usuarioActual == null) {
          throw Exception('Usuario ID $usuarioID no encontrado.');
        }

        final nuevaVenta = Venta()
          ..fechaHora = DateTime.now()
          ..metodoPago = 'Domicilio'
          ..total =
              0.0 // Sin precio
          ..referenciaTarjeta = null
          ..usuario.value = usuarioActual;
        await isar.ventas.put(nuevaVenta);
        await nuevaVenta.usuario.save();

        for (final item in _items) {
          final producto = item.producto;

          final detalle = VentaDetalle()
            ..cantidad = item.cantidad
            ..precioUnitarioVenta =
                0.0 // Sin precio
            ..venta.value = nuevaVenta
            ..producto.value = producto;
          await isar.ventaDetalles.put(detalle);
          await detalle.venta.save();
          await detalle.producto.save();

          // Actualizar stock
          final productoActual = await isar.productos.get(producto.id);
          if (productoActual != null) {
            productoActual.stockActual -= item.cantidad;
            await isar.productos.put(productoActual);
          } else {
            throw Exception('Producto ID ${producto.id} no encontrado.');
          }

          // Registrar movimiento de inventario
          final movimiento = MovimientoInventario()
            ..fecha = DateTime.now()
            ..cantidad = -item.cantidad
            ..tipoMovimiento = 'Venta Domicilio'
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
      debugPrint('Error al guardar pedido a domicilio: $e');
      throw Exception('Error al registrar el pedido. ${e.toString()}');
    }
  }
}
