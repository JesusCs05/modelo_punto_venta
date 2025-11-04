// Archivo: lib/presentation/models/cart_item_model.dart
import '../../data/collections/producto.dart';

class CartItem {
  final Producto producto;
  int cantidad;

  CartItem({required this.producto, this.cantidad = 1});

  // --- MODIFICACIÓN ---
  // Eliminamos 'get subtotal'.
  // El CartProvider ahora se encargará de este cálculo.
  // double get subtotal => producto.precioVenta * cantidad; // <<< ELIMINADO
}