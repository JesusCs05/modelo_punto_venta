// Archivo: lib/presentation/providers/business_provider.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/collections/negocio.dart';
import '../../data/models/business_info.dart';

class BusinessProvider extends ChangeNotifier {
  static const _prefsKey = 'business_info_v1';
  final Isar isar;

  BusinessInfo _info = BusinessInfo.defaultInfo();

  BusinessProvider(this.isar);

  BusinessInfo get info => _info;

  bool get isDefault => _info.nombre == BusinessInfo.defaultInfo().nombre;

  Future<void> load() async {
    // 1. Try to load from Isar
    final negocio = await isar.negocios.where().findFirst();

    if (negocio != null) {
      _info = BusinessInfo(
        nombre: negocio.nombre,
        razonSocial: negocio.razonSocial,
        telefono: negocio.telefono,
        direccion: negocio.direccion,
        rfc: negocio.rfc,
      );
    } else {
      // 2. If not in Isar, try SharedPreferences (Migration)
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        try {
          _info = BusinessInfo.fromRawJson(raw);
          // Migrate to Isar
          await save(_info);
          // Optional: Clear prefs after successful migration
          // await prefs.remove(_prefsKey); 
        } catch (_) {
          _info = BusinessInfo.defaultInfo();
        }
      } else {
        _info = BusinessInfo.defaultInfo();
      }
    }
    notifyListeners();
  }

  Future<void> save(BusinessInfo info) async {
    _info = info;
    
    await isar.writeTxn(() async {
      // Check if a record exists
      final existing = await isar.negocios.where().findFirst();
      final negocio = existing ?? Negocio();
      
      negocio.nombre = info.nombre;
      negocio.razonSocial = info.razonSocial;
      negocio.telefono = info.telefono;
      negocio.direccion = info.direccion;
      negocio.rfc = info.rfc;

      await isar.negocios.put(negocio);
    });

    // Keep updating prefs for backup/compatibility if needed, or remove this.
    // For now, I'll keep it or remove it? The plan said "migrate".
    // I will stop writing to prefs to enforce Isar usage.
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(_prefsKey, info.toRawJson());
    
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
    await save(_info);
  }

  Future<void> reset() async {
    _info = BusinessInfo.defaultInfo();
    await isar.writeTxn(() async {
       await isar.negocios.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }
}
