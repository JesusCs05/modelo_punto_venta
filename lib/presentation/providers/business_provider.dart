// Archivo: lib/presentation/providers/business_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/business_info.dart';

class BusinessProvider extends ChangeNotifier {
  static const _prefsKey = 'business_info_v1';

  BusinessInfo _info = BusinessInfo.defaultInfo();

  BusinessInfo get info => _info;

  bool get isDefault => _info.nombre == BusinessInfo.defaultInfo().nombre;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _info = BusinessInfo.fromRawJson(raw);
      } catch (_) {
        _info = BusinessInfo.defaultInfo();
      }
    } else {
      _info = BusinessInfo.defaultInfo();
    }
    notifyListeners();
  }

  Future<void> save(BusinessInfo info) async {
    _info = info;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, info.toRawJson());
    notifyListeners();
  }

  Future<void> updateField({
    String? nombre,
    String? razonSocial,
    String? telefono,
    String? direccion,
    String? rfc,
  }) async {
    _info = _info.copyWith(
      nombre: nombre,
      razonSocial: razonSocial,
      telefono: telefono,
      direccion: direccion,
      rfc: rfc,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _info.toRawJson());
    notifyListeners();
  }

  Future<void> reset() async {
    _info = BusinessInfo.defaultInfo();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }
}
