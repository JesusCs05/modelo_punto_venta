// Archivo: lib/presentation/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../data/collections/usuario.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _currentUser;

  /// Devuelve el objeto Usuario completo si está logueado.
  Usuario? get currentUser => _currentUser;

  /// Devuelve true si hay un usuario en sesión.
  bool get isLoggedIn => _currentUser != null;

  /// Devuelve el ID de Isar del usuario actual.
  Id? get currentUserId => _currentUser?.id;

  /// Devuelve true si el usuario actual es Administrador.
  bool get isAdmin {
    if (_currentUser == null) return false;
    // Asume que el rol ya fue cargado durante el login
    return _currentUser!.rol.value?.nombre == 'Administrador';
  }

  /// Almacena el usuario en el estado y notifica a los listeners.
  /// Carga el rol del usuario para que 'isAdmin' funcione.
  Future<void> login(Usuario usuario) async {
    // Carga la relación de Rol desde Isar
    await usuario.rol.load();
    _currentUser = usuario;
    
    // Notifica a todos los widgets que escuchan este provider
    notifyListeners(); 
  }

  /// Limpia la sesión del usuario y notifica.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}