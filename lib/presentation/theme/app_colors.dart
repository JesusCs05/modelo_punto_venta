// Archivo: lib/presentation/theme/app_colors.dart
import 'package:flutter/material.dart';

/*
 * Guía de Estilos Visuales (Paleta "Corporativa Marina/Oro")
 * Basado en la imagen proporcionada.
 */
class AppColors {
  // --- Colores de la paleta (Referencia) ---
  static const Color paletteYellowOrange = Color(0xFFF4A928);
  static const Color paletteGold = Color(0xFFDDB82F);
  static const Color paletteNavy = Color(0xFF182F4E);
  static const Color paletteSlateGray = Color(0xFF738290);
  static const Color paletteLightGray = Color(0xFFB8C2CC);
  static const Color paletteWhite = Color(0xFFFFFFFF);
  
  // --- Roles Funcionales de la App ---

  /// Fondo Principal: #B8C2CC (Gris Claro)
  static const Color background = paletteLightGray;

  /// Primario / Éxito: #182F4E (Azul Marino Oscuro)
  /// Usado para confirmación ("SÍ", "Ingresar").
  static const Color primary = paletteNavy;

  /// Acento / Peligro / CTA: #F4A928 (Naranja-Amarillo)
  /// Usado para el CTA principal ("Cobrar") y acciones de "Peligro" ("NO").
  static const Color accentDanger = paletteYellowOrange;

  /// Secundario / Acento Cálido: #738290 (Gris Pizarra)
  /// Usado para botones secundarios ("Cancelar Venta").
  static const Color secondary = paletteSlateGray;

  /// Resaltado / Información: #DDB82F (Dorado)
  static const Color highlight = paletteGold;

  // --- Colores de Texto ---
  
  /// Texto Principal (Sobre Fondo Gris Claro): #182F4E (Azul Marino)
  /// Proporciona el mejor contraste contra el fondo gris claro.
  static const Color textPrimary = paletteNavy;

  /// Texto Invertido (Sobre Azul/Amarillo/Gris): #FFFFFF
  static const Color textInverted = paletteWhite;
  
  /// Fondo de Tarjetas/Listas (Blanco)
  /// (Mantenemos blanco para mejor contraste sobre el fondo gris)
  static const Color cardBackground = paletteWhite;
}