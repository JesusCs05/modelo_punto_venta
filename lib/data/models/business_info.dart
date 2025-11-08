// Archivo: lib/data/models/business_info.dart
import 'dart:convert';

class BusinessInfo {
  final String nombre;
  final String razonSocial;
  final String telefono;
  final String direccion;
  final String rfc;

  BusinessInfo({
    required this.nombre,
    required this.razonSocial,
    required this.telefono,
    this.direccion = '',
    this.rfc = '',
  });

  BusinessInfo copyWith({
    String? nombre,
    String? razonSocial,
    String? telefono,
    String? direccion,
    String? rfc,
  }) {
    return BusinessInfo(
      nombre: nombre ?? this.nombre,
      razonSocial: razonSocial ?? this.razonSocial,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      rfc: rfc ?? this.rfc,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'razonSocial': razonSocial,
    'telefono': telefono,
    'direccion': direccion,
    'rfc': rfc,
  };

  factory BusinessInfo.fromJson(Map<String, dynamic> json) => BusinessInfo(
    nombre: json['nombre'] ?? '',
    razonSocial: json['razonSocial'] ?? '',
    telefono: json['telefono'] ?? '',
    direccion: json['direccion'] ?? '',
    rfc: json['rfc'] ?? '',
  );

  String toRawJson() => json.encode(toJson());

  factory BusinessInfo.fromRawJson(String str) =>
      BusinessInfo.fromJson(json.decode(str));

  static BusinessInfo defaultInfo() => BusinessInfo(
    nombre: 'Mi Negocio',
    razonSocial: 'Mi Razón Social',
    telefono: '',
    direccion: '',
    rfc: '',
  );
}
